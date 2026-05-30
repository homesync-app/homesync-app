import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { jwtVerify, createRemoteJWKSet } from "https://esm.sh/jose@5";
import {
  extractJsonString,
  normalizeOcrResult,
  RESPONSE_SCHEMA,
  type OcrResult,
} from "./parser.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const FIREBASE_PROJECT_ID = "homesync-prod-r7-123";

interface FirebaseJWTPayload {
  sub: string;
  email?: string;
  aud: string;
  iss: string;
}

// JWKS de Firebase. Se construye UNA sola vez a nivel de módulo para que el
// cache de claves persista entre invocaciones (el runtime reutiliza el
// isolate). Construirlo dentro del handler re-fetcheaba el set en cada request.
const FIREBASE_JWKS = createRemoteJWKSet(
  new URL(
    "https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com",
  ),
);

// OCR (monto + categoría) es gratis para todos. NO hay límite mensual por tier.
// Lo único que aplicamos es un anti-abuso liviano: como cada scan pega contra
// un endpoint pago de Gemini, un usuario autenticado no debería poder loopear
// el endpoint sin freno. Ventana corta y generosa para no molestar el uso real.
const RATE_LIMIT_WINDOW_SECONDS = 60;
const RATE_LIMIT_MAX_SCANS = 8; // por usuario, por ventana

// Modelo de OCR. Gemini 3.1 Flash-Lite reemplaza a gemini-2.5-flash (deprecado,
// shutdown 17-jun-2026). Es el sucesor más económico y de baja latencia, mejora
// a 2.5 Flash-Lite y se acerca a 2.5 Flash, con avances específicos en
// extracción de datos. OJO: la serie 3.x usa `thinkingLevel` (no `thinkingBudget`,
// que era de la 2.5 y es incompatible con 3.x).
const GEMINI_MODEL = "gemini-3.1-flash-lite";
const GEMINI_API_URL =
  `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent`;

function buildPrompt(todayIso: string): string {
  return `Sos un extractor de datos de tickets de compra.
Analizá la imagen del ticket y completá los campos del esquema de salida.

Reglas para merchant:
- Usá el nombre real del comercio si es claro y reconocible (ej: "Farmacity", "McDonald's", "Carrefour")
- Si el nombre en el ticket es un código fiscal genérico ("VARIOS VTA/CPRA", "CF", "CONSUMIDOR FINAL", "MOSTRADOR", siglas incomprensibles), NO lo uses
- En ese caso, inferí un nombre descriptivo del tipo de negocio basándote en los productos (ej: si hay alimentos para mascotas → "Tienda de mascotas", si hay medicamentos → "Farmacia", si hay ropa → "Indumentaria")
- Si no podés inferir nada útil, dejá merchant en null

Reglas para category:
- supermarket: almacén, supermercado, alimentos generales
- restaurants: restaurantes, cafés, comida para llevar, delivery
- transport: combustible, peajes, transporte público, estacionamiento
- health: farmacia, médico, dentista, óptica
- entertainment: cine, teatro, videojuegos, suscripciones digitales, salidas
- clothing: ropa, calzado, accesorios de moda
- electronics: tecnología, electrodomésticos, celulares
- pets: alimentos para mascotas, veterinaria, accesorios para animales
- education: libros, útiles, cursos, jardines/colegios
- other: todo lo que no encaje en las anteriores

Otras reglas:
- amount: número total del ticket sin signo $, punto como decimal
- date: formato YYYY-MM-DD. La fecha de HOY es ${todayIso}. La fecha del ticket nunca puede ser futura ni de hace más de un año; si no se ve claramente o es inconsistente, dejá date en null
- items: nombres limpios de productos, sin precios, cantidades ni códigos
- confidence: 0.0 a 1.0 según qué tan legible está el ticket
- NUNCA inventes datos`;
}

const sleep = (ms: number) => new Promise((r) => setTimeout(r, ms));

async function callGemini(
  geminiKey: string,
  prompt: string,
  imageBase64: string,
  mimeType: string,
  maxRetries = 3
): Promise<{ ok: true; data: unknown } | { ok: false; status: number; body: string }> {
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    const resp = await fetch(`${GEMINI_API_URL}?key=${geminiKey}`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [{
          parts: [
            { text: prompt },
            { inline_data: { mime_type: mimeType, data: imageBase64 } },
          ],
        }],
        generationConfig: {
          temperature: 0.1,
          // Margen holgado: en Gemini 3.x los thinking tokens cuentan dentro
          // del presupuesto de salida. Con thinkingLevel "minimal" el uso real
          // es bajo, pero 2048 evita truncar el JSON (finishReason MAX_TOKENS)
          // en tickets con muchos items.
          maxOutputTokens: 2048,
          // Gemini 3.x usa thinkingLevel (minimal/low/medium/high), NO
          // thinkingBudget (eso era de 2.5 y rompe en 3.x). "minimal" minimiza
          // el razonamiento interno → menor latencia y costo, ideal para una
          // extracción acotada por schema como esta.
          thinkingConfig: { thinkingLevel: "minimal" },
          // Structured output: el modelo devuelve JSON que cumple el schema,
          // sin bloques cercados ni texto extra. Elimina el modo de falla del
          // parser por prosa adicional. La normalización post-parse sigue
          // siendo el cinturón de seguridad.
          responseMimeType: "application/json",
          responseSchema: RESPONSE_SCHEMA,
        },
      }),
    });

    if (resp.ok) return { ok: true, data: await resp.json() };

    const body = await resp.text();
    console.warn(`Gemini intento ${attempt}/${maxRetries} -> ${resp.status}:`, body.slice(0, 300));

    const retryable = resp.status === 503 || resp.status === 429 || resp.status === 500;
    if (!retryable || attempt === maxRetries) return { ok: false, status: resp.status, body };

    await sleep(1000 * attempt);
  }
  return { ok: false, status: 0, body: "unreachable" };
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const token = authHeader.replace("Bearer ", "");

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
    );

    let firebaseUid: string;
    try {
      const { payload } = await jwtVerify(token, FIREBASE_JWKS, {
        issuer: `https://securetoken.google.com/${FIREBASE_PROJECT_ID}`,
        audience: FIREBASE_PROJECT_ID,
      });

      const fb = payload as FirebaseJWTPayload;
      if (!fb.sub) throw new Error("Missing sub claim");
      firebaseUid = fb.sub;
    } catch (e) {
      console.error("Firebase JWT verification failed:", e);
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const { data: userRow, error: userError } = await supabase
      .from("users")
      .select("id")
      .eq("firebase_uid", firebaseUid)
      .limit(1)
      .single();

    if (userError || !userRow) {
      console.error("User lookup failed for firebase_uid:", firebaseUid, userError);
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }
    const userId = userRow.id;

    // Obtener household y tier del usuario
    const { data: memberRow, error: memberError } = await supabase
      .from("household_members")
      .select("household_id, households(plan_tier)")
      .eq("user_id", userId)
      .limit(1)
      .single();

    if (memberError || !memberRow) {
      return new Response(JSON.stringify({ error: "Household no encontrado" }), {
        status: 403, headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const householdId = memberRow.household_id;
    const tier = (memberRow.households as { plan_tier: string } | null)?.plan_tier ?? "free";

    // Anti-abuso liviano: cada scan pega contra un endpoint pago de Gemini.
    // No es un límite por tier (el OCR es gratis), solo un freno para que un
    // usuario autenticado no pueda loopear el endpoint. Contamos los scans del
    // usuario en la ventana reciente. Falla-abierto: si el conteo falla por
    // cualquier motivo, dejamos pasar el scan (no rompemos la feature por un
    // error de telemetría).
    const windowStart = new Date(
      Date.now() - RATE_LIMIT_WINDOW_SECONDS * 1000,
    ).toISOString();
    const { count: recentScans, error: rateError } = await supabase
      .from("receipt_scan_logs")
      .select("id", { count: "exact", head: true })
      .eq("user_id", userId)
      .gte("scanned_at", windowStart);

    if (!rateError && (recentScans ?? 0) >= RATE_LIMIT_MAX_SCANS) {
      return new Response(
        JSON.stringify({
          error: "rate_limited",
          retryAfterSeconds: RATE_LIMIT_WINDOW_SECONDS,
        }),
        {
          status: 429,
          headers: {
            ...corsHeaders,
            "Content-Type": "application/json",
            "Retry-After": String(RATE_LIMIT_WINDOW_SECONDS),
          },
        },
      );
    }

    // Leer imagen del body
    const body = await req.json();
    const { imageBase64, mimeType = "image/webp" } = body as {
      imageBase64: string;
      mimeType?: string;
    };

    if (!imageBase64) {
      return new Response(
        JSON.stringify({ error: "imageBase64 es requerido" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }
    if (imageBase64.length > 7_000_000) {
      return new Response(
        JSON.stringify({ error: "Imagen demasiado grande. Máx 5MB." }),
        { status: 413, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const geminiKey = Deno.env.get("GEMINI_API_KEY");
    if (!geminiKey) {
      return new Response(
        JSON.stringify({ error: "GEMINI_API_KEY no configurada" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Llamar a Gemini con retry
    const now = new Date();
    const todayIso = now.toISOString().slice(0, 10); // YYYY-MM-DD (UTC)
    const geminiResult = await callGemini(
      geminiKey,
      buildPrompt(todayIso),
      imageBase64,
      mimeType,
    );
    if (!geminiResult.ok) {
      console.error("Gemini falló:", geminiResult.status, geminiResult.body.slice(0, 300));
      return new Response(
        JSON.stringify({ error: "ocr_failed" }),
        { status: 502, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const geminiData = geminiResult.data as Record<string, unknown>;
    const candidate = (geminiData?.candidates as unknown[])?.[0] as Record<string, unknown> | undefined;
    const finishReason = candidate?.finishReason as string | undefined;
    const rawText: string =
      ((candidate?.content as Record<string, unknown>)?.parts as { text?: string }[])?.[0]?.text ?? "";

    console.log("Gemini finishReason:", finishReason, "rawText:", rawText.slice(0, 300));

    const jsonStr = extractJsonString(rawText);

    if (!jsonStr) {
      return new Response(
        JSON.stringify({ error: "Gemini no devolvió JSON válido", finishReason, rawText: rawText.slice(0, 500) }),
        { status: 422, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    let parsed: Partial<OcrResult>;
    try {
      parsed = JSON.parse(jsonStr);
    } catch (e) {
      console.error("JSON.parse falló:", e);
      return new Response(
        JSON.stringify({ error: "JSON inválido de Gemini", finishReason, rawText: rawText.slice(0, 500) }),
        { status: 422, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const result: OcrResult = normalizeOcrResult(parsed, { today: now });

    // Registrar el scan exitoso
    await supabase.from("receipt_scan_logs").insert({
      household_id: householdId,
      user_id: userId,
    });

    return new Response(
      JSON.stringify({ data: result, tier }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (err) {
    console.error("scan-receipt error:", err);
    return new Response(
      JSON.stringify({ error: "internal_error" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
