import { encodeBase64 } from "https://deno.land/std@0.224.0/encoding/base64.ts";
import { createClient, SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";
import { jwtVerify, createRemoteJWKSet } from "https://esm.sh/jose@5";
import {
  extractJsonString,
  normalizeOcrResult,
  RESPONSE_SCHEMA,
  type OcrParsedInput,
  type OcrResult,
} from "./parser.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type, x-mime-type, x-today-local",
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
//
// El log del scan se inserta ANTES de llamar a Gemini (status='pending') y se
// actualiza al terminar. Así los intentos fallidos también cuentan para el
// rate limit — antes solo contaban los éxitos, y un cliente loopeando requests
// que fallaban pegaba contra Gemini sin freno.
const RATE_LIMIT_WINDOW_SECONDS = 60;
const RATE_LIMIT_MAX_SCANS = 8; // por usuario, por ventana

// Límite de imagen: 5 MB de bytes crudos (~6.7 MB en base64).
const MAX_IMAGE_BYTES = 5 * 1024 * 1024;
const MAX_BASE64_CHARS = 7_000_000;

// Timeout por intento contra Gemini. Hay hasta 3 intentos + 1 retry por
// MAX_TOKENS; sin esto un fetch colgado consume todo el wall-clock de la
// función y el usuario espera el timeout genérico del gateway.
const GEMINI_TIMEOUT_MS = 25_000;

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
- amount: el total FINAL efectivamente pagado, después de descuentos y promociones (ej: "2do al 50%"). Si el ticket incluye propina o cargo de servicio en el total impreso, incluilos. Sin signo $, punto como decimal
- date: formato YYYY-MM-DD. La fecha de HOY es ${todayIso}. La fecha del ticket nunca puede ser futura ni de hace más de un año; si no se ve claramente o es inconsistente, dejá date en null
- items: un objeto por producto del ticket, con dos campos:
  - raw: la línea del producto TAL CUAL está impresa, sin el precio ni la cantidad (ej: "QSO BARRA L3N FET FFL")
  - name: el nombre limpio del producto en español, con las abreviaturas del ticket expandidas (QSO → Queso, GALL → Galletitas, CERV → Cerveza, HAMBUR → Hamburguesas, ANTITRANS → Antitranspirante, SUAV → Suavizante), sin marca, sin tamaño, sin códigos (ej: "Queso en barra")
  - NO incluyas líneas que no sean productos: totales, subtotales, IVA, descuentos, promociones, medios de pago
- confidence: 0.0 a 1.0 según qué tan legible está el ticket
- NUNCA inventes datos`;
}

const sleep = (ms: number) => new Promise((r) => setTimeout(r, ms));

async function callGemini(
  geminiKey: string,
  prompt: string,
  imageBase64: string,
  mimeType: string,
  maxOutputTokens: number,
  maxRetries = 3,
): Promise<{ ok: true; data: unknown } | { ok: false; status: number; body: string }> {
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    let resp: Response;
    try {
      resp = await fetch(`${GEMINI_API_URL}?key=${geminiKey}`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        signal: AbortSignal.timeout(GEMINI_TIMEOUT_MS),
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
            // en tickets con muchos items. Si igual trunca, el handler reintenta
            // una vez con el doble.
            maxOutputTokens,
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
    } catch (e) {
      // Timeout (AbortSignal) o error de red: retryable.
      console.warn(`Gemini intento ${attempt}/${maxRetries} -> fetch error:`, String(e));
      if (attempt === maxRetries) return { ok: false, status: 0, body: String(e) };
      await sleep(1000 * attempt);
      continue;
    }

    if (resp.ok) return { ok: true, data: await resp.json() };

    const body = await resp.text();
    console.warn(`Gemini intento ${attempt}/${maxRetries} -> ${resp.status}:`, body.slice(0, 300));

    const retryable = resp.status === 503 || resp.status === 429 || resp.status === 500;
    if (!retryable || attempt === maxRetries) return { ok: false, status: resp.status, body };

    await sleep(1000 * attempt);
  }
  return { ok: false, status: 0, body: "unreachable" };
}

interface GeminiUsage {
  promptTokenCount?: number;
  candidatesTokenCount?: number;
  thoughtsTokenCount?: number;
}

interface OcrAttempt {
  finishReason: string | undefined;
  rawText: string;
  usage: GeminiUsage;
}

function extractAttempt(data: unknown): OcrAttempt {
  const geminiData = data as Record<string, unknown>;
  const candidate = (geminiData?.candidates as unknown[])?.[0] as Record<string, unknown> | undefined;
  const finishReason = candidate?.finishReason as string | undefined;
  const rawText: string =
    ((candidate?.content as Record<string, unknown>)?.parts as { text?: string }[])?.[0]?.text ?? "";
  const usage = (geminiData?.usageMetadata ?? {}) as GeminiUsage;
  return { finishReason, rawText, usage };
}

/// Actualiza el log de telemetría. Best-effort: nunca rompe el request.
async function finalizeLog(
  supabase: SupabaseClient,
  logId: string | null,
  fields: Record<string, unknown>,
) {
  if (!logId) return;
  try {
    await supabase.from("ocr_scan_logs").update(fields).eq("id", logId);
  } catch (e) {
    console.warn("finalizeLog falló:", e);
  }
}

/// Fecha local del dispositivo si vino y es plausible (±2 días del reloj del
/// servidor); si no, la fecha UTC del servidor. Un usuario argentino a las
/// 22:00 está en "ayer" según UTC — usar su fecha local evita decirle al
/// modelo que "hoy" es mañana.
function resolveTodayIso(todayLocal: string | null, now: Date): string {
  const serverIso = now.toISOString().slice(0, 10);
  if (!todayLocal || !/^\d{4}-\d{2}-\d{2}$/.test(todayLocal)) return serverIso;
  const parsed = Date.parse(`${todayLocal}T00:00:00Z`);
  if (Number.isNaN(parsed)) return serverIso;
  const driftMs = Math.abs(parsed - Date.parse(`${serverIso}T00:00:00Z`));
  return driftMs <= 2 * 24 * 60 * 60 * 1000 ? todayLocal : serverIso;
}

Deno.serve(async (req: Request) => {
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

    // Contexto del scan en 1 solo round-trip: user_id + household + tier +
    // conteo de rate limit (antes eran 3 queries secuenciales en el camino
    // crítico del spinner).
    interface ScanContext {
      user_id: string | null;
      household_id: string | null;
      tier: string | null;
      recent_scans: number | null;
    }
    const { data: ctxRaw, error: ctxError } = await supabase
      .rpc("get_scan_context", {
        p_firebase_uid: firebaseUid,
        p_window_seconds: RATE_LIMIT_WINDOW_SECONDS,
      })
      .maybeSingle();
    const ctx = ctxRaw as ScanContext | null;

    if (ctxError) {
      console.error("get_scan_context falló:", ctxError);
      return new Response(JSON.stringify({ error: "internal_error" }), {
        status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }
    if (!ctx?.user_id) {
      console.error("User lookup failed for firebase_uid:", firebaseUid);
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }
    if (!ctx.household_id) {
      return new Response(JSON.stringify({ error: "Household no encontrado" }), {
        status: 403, headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const userId = ctx.user_id as string;
    const householdId = ctx.household_id as string;
    const tier = (ctx.tier as string | null) ?? "free";

    if ((ctx.recent_scans ?? 0) >= RATE_LIMIT_MAX_SCANS) {
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

    // ── Leer imagen del body ─────────────────────────────────────────────────
    // Dos formatos soportados:
    // - binario (application/octet-stream / image/*): bytes crudos, mimeType en
    //   x-mime-type, fecha local en x-today-local. Ahorra el 33% de overhead de
    //   base64 en el upload del dispositivo.
    // - JSON { imageBase64, mimeType, todayLocal }: formato legado, lo siguen
    //   usando las apps viejas hasta que actualicen.
    const contentType = req.headers.get("content-type") ?? "";
    // Path binario = app nueva: la fila de ocr_scan_logs del servidor es LA
    // fila del scan (se completa con ai_* y el cliente la actualiza con
    // matcher/acción vía el logId devuelto). Path JSON = app legada: el
    // cliente inserta su propia fila como siempre; la del servidor queda solo
    // como marcador de rate limit (ai_* null, excluida de v_ocr_daily_stats).
    const isBinaryClient = !contentType.includes("application/json");
    let imageBase64: string;
    let mimeType: string;
    let todayLocal: string | null;
    let binaryBytes: Uint8Array | null = null;

    if (contentType.includes("application/json")) {
      const body = await req.json();
      const parsed = body as {
        imageBase64?: string;
        mimeType?: string;
        todayLocal?: string;
      };
      if (!parsed.imageBase64) {
        return new Response(
          JSON.stringify({ error: "imageBase64 es requerido" }),
          { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }
      if (parsed.imageBase64.length > MAX_BASE64_CHARS) {
        return new Response(
          JSON.stringify({ error: "Imagen demasiado grande. Máx 5MB." }),
          { status: 413, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }
      imageBase64 = parsed.imageBase64;
      mimeType = parsed.mimeType ?? "image/webp";
      todayLocal = parsed.todayLocal ?? null;
    } else {
      const bytes = new Uint8Array(await req.arrayBuffer());
      if (bytes.length === 0) {
        return new Response(
          JSON.stringify({ error: "Body vacío: se espera la imagen en bytes" }),
          { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }
      if (bytes.length > MAX_IMAGE_BYTES) {
        return new Response(
          JSON.stringify({ error: "Imagen demasiado grande. Máx 5MB." }),
          { status: 413, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }
      imageBase64 = encodeBase64(bytes);
      mimeType = req.headers.get("x-mime-type") ?? "image/webp";
      todayLocal = req.headers.get("x-today-local");
      binaryBytes = bytes;
    }

    const geminiKey = Deno.env.get("GEMINI_API_KEY");
    if (!geminiKey) {
      return new Response(
        JSON.stringify({ error: "GEMINI_API_KEY no configurada" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // ── Detección de ticket duplicado ────────────────────────────────────────
    // SHA-256 de los bytes recibidos (solo path binario: los legados mandan
    // base64 y no vale la pena decodificar para esto). Si el mismo household
    // ya escaneó esta imagen exacta con éxito en las últimas 48h, avisamos al
    // cliente (duplicateScan) — el 2026-06-07 un mismo ticket se procesó 6
    // veces contra el endpoint pago de Gemini. Solo aviso, no bloqueo: el
    // usuario puede tener un motivo legítimo para re-escanear.
    let imageHash: string | null = null;
    let duplicateOf: string | null = null;
    if (binaryBytes != null) {
      try {
        const digest = await crypto.subtle.digest("SHA-256", binaryBytes);
        imageHash = [...new Uint8Array(digest)]
          .map((b) => b.toString(16).padStart(2, "0"))
          .join("");
        const since = new Date(Date.now() - 48 * 60 * 60 * 1000).toISOString();
        const { data: dup } = await supabase
          .from("ocr_scan_logs")
          .select("id")
          .eq("household_id", householdId)
          .eq("image_hash", imageHash)
          .eq("status", "success")
          .gte("created_at", since)
          .order("created_at", { ascending: false })
          .limit(1)
          .maybeSingle();
        duplicateOf = (dup?.id as string | null) ?? null;
      } catch (e) {
        // Best-effort: sin hash el scan sigue igual.
        console.warn("hash/dedup falló (fail-open):", e);
      }
    }

    // ── Registrar el intento ANTES de llamar a Gemini ────────────────────────
    // Esto es lo que hace que el rate limit cuente intentos y no solo éxitos.
    // Fail-open: si el insert falla, el scan sigue (no rompemos la feature por
    // un error de telemetría).
    let logId: string | null = null;
    try {
      const { data: logRow, error: logError } = await supabase
        .from("ocr_scan_logs")
        .insert({
          household_id: householdId,
          user_id: userId,
          tier,
          status: "pending",
          model: GEMINI_MODEL,
          image_hash: imageHash,
          duplicate_of: duplicateOf,
        })
        .select("id")
        .single();
      if (logError) console.warn("insert de ocr_scan_logs falló (fail-open):", logError);
      logId = (logRow?.id as string | null) ?? null;
    } catch (e) {
      console.warn("insert de ocr_scan_logs falló (fail-open):", e);
    }

    // ── Llamar a Gemini ──────────────────────────────────────────────────────
    const now = new Date();
    const todayIso = resolveTodayIso(todayLocal, now);
    const prompt = buildPrompt(todayIso);

    const geminiStart = Date.now();
    let geminiResult = await callGemini(geminiKey, prompt, imageBase64, mimeType, 2048);

    let attempt: OcrAttempt | null = geminiResult.ok
      ? extractAttempt(geminiResult.data)
      : null;

    // JSON truncado por presupuesto de salida: un solo retry con el doble de
    // margen en vez de fallarle al usuario con un 422 genérico.
    if (attempt?.finishReason === "MAX_TOKENS") {
      console.warn("finishReason MAX_TOKENS, reintentando con maxOutputTokens=4096");
      geminiResult = await callGemini(geminiKey, prompt, imageBase64, mimeType, 4096, 1);
      if (geminiResult.ok) attempt = extractAttempt(geminiResult.data);
    }
    const geminiLatencyMs = Date.now() - geminiStart;

    if (!geminiResult.ok || !attempt) {
      const status = geminiResult.ok ? 0 : geminiResult.status;
      const body = geminiResult.ok ? "" : geminiResult.body;
      console.error("Gemini falló:", status, body.slice(0, 300));
      await finalizeLog(supabase, logId, {
        status: "failed",
        finish_reason: `http_${status}`,
        gemini_latency_ms: geminiLatencyMs,
      });
      return new Response(
        JSON.stringify({ error: "ocr_failed" }),
        { status: 502, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const { finishReason, rawText, usage } = attempt;
    console.log("Gemini finishReason:", finishReason, "rawText:", rawText.slice(0, 300));

    const telemetry = {
      finish_reason: finishReason ?? null,
      gemini_latency_ms: geminiLatencyMs,
      prompt_tokens: usage.promptTokenCount ?? null,
      output_tokens:
        (usage.candidatesTokenCount ?? 0) + (usage.thoughtsTokenCount ?? 0),
    };

    const jsonStr = extractJsonString(rawText);

    if (!jsonStr) {
      await finalizeLog(supabase, logId, { status: "failed", ...telemetry });
      return new Response(
        JSON.stringify({ error: "Gemini no devolvió JSON válido", finishReason, rawText: rawText.slice(0, 500) }),
        { status: 422, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    let parsed: OcrParsedInput;
    try {
      parsed = JSON.parse(jsonStr);
    } catch (e) {
      console.error("JSON.parse falló:", e);
      await finalizeLog(supabase, logId, { status: "failed", ...telemetry });
      return new Response(
        JSON.stringify({ error: "JSON inválido de Gemini", finishReason, rawText: rawText.slice(0, 500) }),
        { status: 422, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const result: OcrResult = normalizeOcrResult(parsed, {
      today: new Date(`${todayIso}T00:00:00Z`),
    });

    // Path binario: esta fila es LA fila del scan → completar datos de IA.
    // ai_raw_items guarda las líneas del ticket tal cual (rawItems); los
    // nombres limpios viajan en data.items y quedan en matcher_result.
    // ai_amount/ai_date/ai_category permiten medir precisión contra los
    // final_* que escribe el cliente al confirmar.
    // Path legado: dejarla como marcador (el cliente inserta la suya con ai_*).
    const aiFields = isBinaryClient
      ? {
          ai_merchant: result.merchant,
          ai_confidence: result.confidence,
          ai_raw_items: result.rawItems.length > 0 ? result.rawItems : result.items,
          ai_amount: result.amount,
          ai_date: result.date,
          ai_category: result.category,
        }
      : {};
    await finalizeLog(supabase, logId, {
      status: "success",
      ...telemetry,
      ...aiFields,
    });

    return new Response(
      JSON.stringify({
        data: result,
        tier,
        logId: isBinaryClient ? logId : null,
        // Aviso (no bloqueo): esta imagen exacta ya se escaneó con éxito en
        // las últimas 48h en este household.
        duplicateScan: duplicateOf != null,
      }),
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
