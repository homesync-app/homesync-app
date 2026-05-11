import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { jwtVerify, createRemoteJWKSet } from "https://esm.sh/jose@5";

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

interface OcrResult {
  merchant: string | null;
  amount: number | null;
  date: string | null;
  category: string | null;
  items: string[];
  confidence: number;
}

// Scan limits removed — OCR (amount + category) is free for all users.
// Premium gating for product detection → shopping list linking is handled
// on the client side via canUseReceiptShoppingLinkProvider.

const GEMINI_API_URL =
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent";

const PROMPT = `Sos un extractor de datos de tickets de compra.
Analizá la imagen y devolvé SOLO JSON válido, sin texto extra, sin bloques de código:
{
  "merchant": "nombre descriptivo del comercio",
  "amount": 1234.56,
  "date": "2026-04-11",
  "category": "supermarket|restaurants|transport|health|entertainment|clothing|electronics|pets|education|other",
  "items": ["producto 1", "producto 2"],
  "confidence": 0.95
}

Reglas para merchant:
- Usá el nombre real del comercio si es claro y reconocible (ej: "Farmacity", "McDonald's", "Carrefour")
- Si el nombre en el ticket es un código fiscal genérico ("VARIOS VTA/CPRA", "CF", "CONSUMIDOR FINAL", "MOSTRADOR", siglas incomprensibles), NO lo uses
- En ese caso, inferí un nombre descriptivo del tipo de negocio basándote en los productos (ej: si hay alimentos para mascotas → "Tienda de mascotas", si hay medicamentos → "Farmacia", si hay ropa → "Indumentaria")
- Si no podés inferir nada útil, usá null

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
- date: formato YYYY-MM-DD; si no se ve claramente usá null
- items: nombres limpios de productos, sin precios, cantidades ni códigos
- confidence: 0.0 a 1.0 según qué tan legible está el ticket
- NUNCA inventes datos`;

const sleep = (ms: number) => new Promise((r) => setTimeout(r, ms));

async function callGemini(
  geminiKey: string,
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
            { text: PROMPT },
            { inline_data: { mime_type: mimeType, data: imageBase64 } },
          ],
        }],
        generationConfig: {
          temperature: 0.1,
          maxOutputTokens: 1024,
          thinkingConfig: { thinkingBudget: 0 },
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
      const JWKS = createRemoteJWKSet(
        new URL("https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com")
      );

      const { payload } = await jwtVerify(token, JWKS, {
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

    // No scan limit — OCR is free for all. We still log scans for analytics.
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
    const geminiResult = await callGemini(geminiKey, imageBase64, mimeType);
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

    const jsonMatch = rawText.match(/```(?:json)?\s*([\s\S]*?)```/) ??
                      rawText.match(/(\{[\s\S]*\})/);
    const jsonStr = jsonMatch?.[1] ?? jsonMatch?.[0];

    if (!jsonStr) {
      return new Response(
        JSON.stringify({ error: "Gemini no devolvió JSON válido", finishReason, rawText: rawText.slice(0, 500) }),
        { status: 422, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    let parsed: OcrResult;
    try {
      parsed = JSON.parse(jsonStr);
    } catch (e) {
      console.error("JSON.parse falló:", e);
      return new Response(
        JSON.stringify({ error: "JSON inválido de Gemini", finishReason, rawText: rawText.slice(0, 500) }),
        { status: 422, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const VALID_CATEGORIES = [
      "supermarket", "restaurants", "transport", "health",
      "entertainment", "clothing", "electronics", "pets", "education", "other",
    ];

    const rawAmount = parsed.amount;
    const amount: number | null =
      typeof rawAmount === "number" && rawAmount >= 0 && isFinite(rawAmount)
        ? Math.round(rawAmount * 100) / 100 : null;

    const rawDate = parsed.date;
    const date: string | null =
      typeof rawDate === "string" && /^\d{4}-\d{2}-\d{2}$/.test(rawDate) ? rawDate : null;

    const rawCat = parsed.category;
    const category = typeof rawCat === "string" && VALID_CATEGORIES.includes(rawCat) ? rawCat : "other";

    const rawItems = Array.isArray(parsed.items) ? parsed.items : [];
    const items = [...new Set(
      rawItems.filter((i) => typeof i === "string" && i.trim().length > 0).map((i) => (i as string).trim())
    )].slice(0, 30);

    const result: OcrResult = {
      merchant: typeof parsed.merchant === "string" && parsed.merchant.trim().length > 0
        ? parsed.merchant.trim().slice(0, 100) : null,
      amount, date, category, items,
      confidence: typeof parsed.confidence === "number" ? Math.min(1, Math.max(0, parsed.confidence)) : 0,
    };

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
