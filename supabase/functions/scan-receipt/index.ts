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
// el endpoint sin freno. Ventana corta y generosa para no molestar el uso real,
// más un techo diario que nadie alcanza escaneando tickets de verdad.
//
// El log del scan se inserta ANTES de llamar a Gemini (status='pending') y se
// actualiza al terminar. Así los intentos fallidos también cuentan para el
// rate limit — antes solo contaban los éxitos, y un cliente loopeando requests
// que fallaban pegaba contra Gemini sin freno.
const RATE_LIMIT_WINDOW_SECONDS = 60;
const RATE_LIMIT_MAX_SCANS = 8; // por usuario, por ventana
const DAILY_MAX_SCANS = 100; // por usuario, últimas 24 h

// Límite de imagen: 5 MB de bytes crudos (~6.7 MB en base64).
const MAX_IMAGE_BYTES = 5 * 1024 * 1024;
const MAX_BASE64_CHARS = 7_000_000;

// Presupuesto de tiempo de TODA la etapa de Gemini (intentos, respaldo y
// escalado). El cliente corta a los 60 s: antes había hasta 3 intentos de 25 s
// más un retry por MAX_TOKENS (~100 s en el peor caso), y el servidor seguía
// pagando Gemini para un usuario que ya había visto el timeout.
const GEMINI_BUDGET_MS = 45_000;
const GEMINI_ATTEMPT_TIMEOUT_MS = 25_000;
// No arrancar un intento con menos margen que esto: no llegaría a responder.
const MIN_ATTEMPT_MS = 5_000;
// El escalado por monto dudoso solo corre si queda tiempo para el modelo
// grande (razona y tarda más que Flash-Lite).
const MIN_ESCALATION_MS = 15_000;

// Modelo principal. Gemini 3.5 Flash-Lite (GA 21-jul-2026) reemplaza a
// 3.1 Flash-Lite (apagado 7-may-2027): misma API, acepta thinkingLevel
// "minimal" y es el más rápido de su clase.
const PRIMARY_MODEL = "gemini-3.5-flash-lite";
// Respaldo: el mejor en extracción de datos de documentos. Se usa solo cuando
// el principal está caído/saturado (503/429/timeout) o cuando su resultado es
// dudoso (el monto no cierra con las líneas del ticket). OJO: 3.8 Flash NO
// acepta thinkingLevel "minimal" (da error); el mínimo es "low".
const FALLBACK_MODEL = "gemini-3.8-flash";

interface ModelConfig {
  id: string;
  thinkingLevel: "minimal" | "low";
  maxOutputTokens: number;
}

const PRIMARY: ModelConfig = {
  id: PRIMARY_MODEL,
  thinkingLevel: "minimal",
  // Margen holgado: los thinking tokens cuentan dentro del presupuesto de
  // salida. El uso real ronda 150–400 tokens; si igual trunca (finishReason
  // MAX_TOKENS) se reintenta una vez con el doble.
  maxOutputTokens: 2048,
};
const FALLBACK: ModelConfig = {
  id: FALLBACK_MODEL,
  thinkingLevel: "low",
  maxOutputTokens: 4096,
};

const geminiUrl = (model: string) =>
  `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent`;

function buildPrompt(todayIso: string): string {
  return `Sos un extractor de datos de tickets de compra y facturas argentinas.
Analizá la imagen de arriba y completá los campos del esquema de salida.

Cómo leer los números: en Argentina el punto separa miles y la coma separa decimales.
"$12.500" = 12500; "12.500,50" = 12500.5; "1.234.567,00" = 1234567. Nunca leas "12.500" como 12,5.

Reglas para merchant:
- Usá el nombre real del comercio si es claro y reconocible (ej: "Farmacity", "McDonald's", "Carrefour", "Edesur")
- Si el nombre en el ticket es un código fiscal genérico ("VARIOS VTA/CPRA", "CF", "CONSUMIDOR FINAL", "MOSTRADOR", siglas incomprensibles), NO lo uses
- En ese caso, inferí un nombre descriptivo del tipo de negocio basándote en los productos (ej: si hay alimentos para mascotas → "Tienda de mascotas", si hay medicamentos → "Farmacia", si hay ropa → "Indumentaria")
- Si no podés inferir nada útil, dejá merchant en null

merchant_tax_id: el CUIT del COMERCIO emisor (11 dígitos, suele estar arriba junto a la razón social). No uses el CUIT ni el DNI del cliente. Si no se ve, null.

Reglas para category:
- supermarket: almacén, supermercado, verdulería, carnicería, alimentos generales
- restaurants: restaurantes, cafés, comida para llevar, delivery
- transport: combustible, peajes, transporte público, estacionamiento
- health: farmacia, médico, dentista, óptica
- utilities: facturas de servicios: luz, gas, agua, internet, telefonía, celular, cable, expensas
- rent: alquiler de la vivienda
- mercadolibre: compras de Mercado Libre
- entertainment: cine, teatro, videojuegos, suscripciones digitales, salidas
- clothing: ropa, calzado, accesorios de moda
- electronics: tecnología, electrodomésticos, celulares
- pets: alimentos para mascotas, veterinaria, accesorios para animales
- education: libros, útiles, cursos, jardines/colegios
- other: todo lo que no encaje en las anteriores

Otras reglas:
- amount: el total FINAL efectivamente pagado (o a pagar, en una factura de servicios), después de descuentos y promociones (ej: "2do al 50%"). Si el ticket incluye propina o cargo de servicio en el total impreso, incluilos
- date: formato YYYY-MM-DD. La fecha de HOY es ${todayIso}. La fecha del ticket nunca puede ser futura ni de hace más de un año; si no se ve claramente o es inconsistente, dejá date en null. En facturas de servicios usá la fecha de emisión, no la de vencimiento
- items: un objeto por línea de producto, en el orden impreso, con tres campos:
  - raw: la línea del producto TAL CUAL está impresa, sin el precio ni la cantidad (ej: "QSO BARRA L3N FET FFL")
  - name: el nombre limpio del producto en español, con las abreviaturas del ticket expandidas (QSO → Queso, GALL → Galletitas, CERV → Cerveza, HAMBUR → Hamburguesas, ANTITRANS → Antitranspirante, SUAV → Suavizante), sin marca, sin tamaño, sin códigos (ej: "Queso en barra")
  - price: el importe total de esa línea (cantidad × precio unitario), tal como suma al total. null si no se ve
  - Si el mismo producto aparece en dos líneas, devolvé las dos
  - NO incluyas líneas que no sean productos: totales, subtotales, IVA, descuentos, promociones, medios de pago
- discount_total: la suma de todos los descuentos, promociones y bonificaciones del ticket, como número positivo. null si no hay
- extra_charges: propina, cargo de servicio o recargos que se suman al total y no son productos. null si no hay
- confidence: 0.0 a 1.0 según qué tan legible está el ticket
- NUNCA inventes datos`;
}

const sleep = (ms: number) => new Promise((r) => setTimeout(r, ms));

type GeminiCall =
  | { ok: true; data: unknown }
  | { ok: false; status: number; body: string; retryable: boolean };

/// Un único request a Gemini. Los reintentos, el respaldo y el escalado los
/// decide [runOcr] con el presupuesto de tiempo compartido.
async function callGemini(
  geminiKey: string,
  model: ModelConfig,
  prompt: string,
  imageBase64: string,
  mimeType: string,
  timeoutMs: number,
  maxOutputTokens: number,
): Promise<GeminiCall> {
  let resp: Response;
  try {
    resp = await fetch(geminiUrl(model.id), {
      method: "POST",
      // API key por header y no en la query string: las URLs quedan en logs
      // de proxies y de la plataforma.
      headers: { "Content-Type": "application/json", "x-goog-api-key": geminiKey },
      signal: AbortSignal.timeout(timeoutMs),
      body: JSON.stringify({
        contents: [{
          // Imagen primero, instrucciones después: la guía de Gemini 3 pide
          // las instrucciones al final, después del contenido.
          parts: [
            { inline_data: { mime_type: mimeType, data: imageBase64 } },
            { text: prompt },
          ],
        }],
        generationConfig: {
          // Sin `temperature`: para Gemini 3 Google pide dejarla en el default
          // (1.0); bajarla puede provocar loops o peores resultados. El schema
          // ya acota la salida.
          maxOutputTokens,
          thinkingConfig: { thinkingLevel: model.thinkingLevel },
          // Structured output: JSON que cumple el schema, sin prosa extra. La
          // normalización post-parse sigue siendo el cinturón de seguridad.
          responseMimeType: "application/json",
          responseSchema: RESPONSE_SCHEMA,
        },
      }),
    });
  } catch (e) {
    // Timeout (AbortSignal) o error de red: retryable.
    return { ok: false, status: 0, body: String(e), retryable: true };
  }

  if (resp.ok) return { ok: true, data: await resp.json() };
  const body = await resp.text();
  // 404: el modelo no existe o se dio de baja → que actúe el respaldo.
  const retryable = [404, 429, 500, 503].includes(resp.status);
  return { ok: false, status: resp.status, body, retryable };
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

type ParsedOcr =
  | { ok: true; result: OcrResult; finishReason: string | undefined }
  | { ok: false; finishReason: string | undefined };

function parseAttempt(attempt: OcrAttempt, todayIso: string): ParsedOcr {
  const jsonStr = extractJsonString(attempt.rawText);
  if (!jsonStr) return { ok: false, finishReason: attempt.finishReason };
  let parsed: OcrParsedInput;
  try {
    parsed = JSON.parse(jsonStr);
  } catch {
    return { ok: false, finishReason: attempt.finishReason };
  }
  return {
    ok: true,
    finishReason: attempt.finishReason,
    result: normalizeOcrResult(parsed, { today: new Date(`${todayIso}T00:00:00Z`) }),
  };
}

type EscalationReason =
  | "primary_unavailable"
  | "amount_mismatch"
  | "amount_missing"
  | "invalid_output";

interface OcrRun {
  /// Resultado final (null si ningún intento respondió dentro del presupuesto).
  parsed: ParsedOcr | null;
  /// Último error HTTP (status 0 = timeout/red) si nunca hubo respuesta 200.
  httpError: { status: number; body: string } | null;
  model: string;
  attempts: number;
  escalation: EscalationReason | null;
  promptTokens: number;
  outputTokens: number;
  latencyMs: number;
}

/// Orquesta los llamados a Gemini dentro de [GEMINI_BUDGET_MS]:
/// 1. Principal (Flash-Lite). Si está caído o saturado pasa al respaldo en vez
///    de reintentar el mismo modelo saturado; después, un último intento al
///    principal si queda tiempo.
/// 2. finishReason MAX_TOKENS → un reintento del mismo modelo con el doble.
/// 3. Si el resultado del principal es dudoso (el monto no cierra con las
///    líneas, falta el total en un ticket con productos, o el JSON es
///    inválido) y queda tiempo, UNA pasada con el respaldo. El camino feliz
///    sigue siendo una sola llamada a Flash-Lite.
async function runOcr(
  geminiKey: string,
  prompt: string,
  imageBase64: string,
  mimeType: string,
  todayIso: string,
): Promise<OcrRun> {
  const start = Date.now();
  const deadline = start + GEMINI_BUDGET_MS;
  const remaining = () => deadline - Date.now();
  const run: OcrRun = {
    parsed: null,
    httpError: null,
    model: PRIMARY.id,
    attempts: 0,
    escalation: null,
    promptTokens: 0,
    outputTokens: 0,
    latencyMs: 0,
  };

  // Un llamado completo a un modelo (incluye el retry por MAX_TOKENS).
  // Devuelve null si no hubo respuesta usable (error HTTP o sin presupuesto).
  const attemptModel = async (
    model: ModelConfig,
    minBudgetMs = MIN_ATTEMPT_MS,
  ): Promise<ParsedOcr | null> => {
    let maxTokens = model.maxOutputTokens;
    for (let i = 0; i < 2; i++) {
      if (remaining() < minBudgetMs) return null;
      run.attempts++;
      const call = await callGemini(
        geminiKey,
        model,
        prompt,
        imageBase64,
        mimeType,
        Math.min(GEMINI_ATTEMPT_TIMEOUT_MS, remaining()),
        maxTokens,
      );
      if (!call.ok) {
        console.warn(`Gemini ${model.id} -> ${call.status}:`, call.body.slice(0, 300));
        run.httpError = { status: call.status, body: call.body };
        if (!call.retryable) throw new NonRetryableGeminiError(call.status, call.body);
        return null;
      }
      run.httpError = null;
      const attempt = extractAttempt(call.data);
      run.promptTokens += attempt.usage.promptTokenCount ?? 0;
      run.outputTokens += (attempt.usage.candidatesTokenCount ?? 0) +
        (attempt.usage.thoughtsTokenCount ?? 0);
      if (attempt.finishReason === "MAX_TOKENS" && i === 0) {
        console.warn(`${model.id}: MAX_TOKENS, reintentando con maxOutputTokens=${maxTokens * 2}`);
        maxTokens *= 2;
        minBudgetMs = MIN_ATTEMPT_MS;
        continue;
      }
      return parseAttempt(attempt, todayIso);
    }
    return null;
  };

  try {
    // ── 1. Disponibilidad: principal → respaldo → principal ────────────────
    let parsed = await attemptModel(PRIMARY);
    if (parsed == null && run.httpError != null) {
      run.escalation = "primary_unavailable";
      run.model = FALLBACK.id;
      parsed = await attemptModel(FALLBACK);
      if (parsed == null && run.httpError != null && remaining() > MIN_ATTEMPT_MS + 1000) {
        await sleep(1000);
        run.model = PRIMARY.id;
        parsed = await attemptModel(PRIMARY);
      }
    }

    // ── 2. Calidad: escalar un resultado dudoso del principal ──────────────
    if (parsed != null && run.model === PRIMARY.id && run.escalation == null) {
      const reason: EscalationReason | null = !parsed.ok
        ? "invalid_output"
        : parsed.result.amountCheck === "mismatch"
        ? "amount_mismatch"
        : parsed.result.amountCheck === "missing"
        ? "amount_missing"
        : null;
      if (reason != null && remaining() >= MIN_ESCALATION_MS) {
        run.escalation = reason;
        let second: ParsedOcr | null = null;
        try {
          second = await attemptModel(FALLBACK, MIN_ESCALATION_MS);
        } catch (e) {
          // El principal ya respondió: un error del respaldo no tumba el scan.
          if (!(e instanceof NonRetryableGeminiError)) throw e;
        }
        run.httpError = null;
        // El respaldo reemplaza al principal salvo que devuelva algo peor:
        // JSON inválido, o un monto que tampoco cierra cuando el principal
        // al menos tenía uno.
        if (
          second?.ok &&
          (!parsed.ok ||
            second.result.amountCheck === "ok" ||
            parsed.result.amountCheck === "missing")
        ) {
          parsed = second;
          run.model = FALLBACK.id;
        }
      }
    }
    run.parsed = parsed;
  } catch (e) {
    if (!(e instanceof NonRetryableGeminiError)) throw e;
    run.httpError = { status: e.status, body: e.body };
  }
  run.latencyMs = Date.now() - start;
  return run;
}

class NonRetryableGeminiError extends Error {
  constructor(readonly status: number, readonly body: string) {
    super(`Gemini ${status}`);
  }
}

/// Actualiza el log de telemetría. Best-effort: nunca rompe el request.
async function finalizeLog(
  supabase: SupabaseClient,
  logId: string | null,
  fields: Record<string, unknown>,
) {
  if (!logId) return;
  try {
    const { error } = await supabase.from("ocr_scan_logs").update(fields).eq("id", logId);
    if (error) console.warn("finalizeLog falló:", error);
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

interface PossibleDuplicate {
  expenseId: string;
  title: string;
  paidAt: string;
}

const DAY_MS = 24 * 60 * 60 * 1000;

/// Duplicado por CONTENIDO: un gasto del hogar con el mismo monto (±$1) y la
/// misma fecha (±1 día), o cargado en las últimas 48 h si el ticket no trae
/// fecha. El hash de imagen solo atrapa la misma foto re-elegida de la
/// galería; una segunda foto del mismo ticket tiene otros bytes.
async function findPossibleDuplicate(
  supabase: SupabaseClient,
  householdId: string,
  result: OcrResult,
): Promise<PossibleDuplicate | null> {
  if (result.amount == null || result.amount <= 0) return null;
  let query = supabase
    .from("expenses")
    .select("id, title, paid_at")
    .eq("household_id", householdId)
    .eq("type", "expense")
    .gte("amount", result.amount - 1)
    .lte("amount", result.amount + 1);
  if (result.date) {
    const day = Date.parse(`${result.date}T00:00:00Z`);
    query = query
      .gte("paid_at", new Date(day - DAY_MS).toISOString())
      .lt("paid_at", new Date(day + 2 * DAY_MS).toISOString());
  } else {
    query = query.gte("created_at", new Date(Date.now() - 2 * DAY_MS).toISOString());
  }
  const { data, error } = await query
    .order("created_at", { ascending: false })
    .limit(1)
    .maybeSingle();
  if (error) console.warn("findPossibleDuplicate falló (fail-open):", error);
  if (error || !data) return null;
  return {
    expenseId: data.id as string,
    title: data.title as string,
    paidAt: data.paid_at as string,
  };
}

/// Cómo llama el hogar a este comercio, aprendido de gastos escaneados y
/// confirmados antes (clave: CUIT). Lo escribe el cliente vía el RPC
/// remember_merchant_preference.
async function findMerchantPreference(
  supabase: SupabaseClient,
  householdId: string,
  taxId: string | null,
): Promise<{ title: string; category: string | null } | null> {
  if (!taxId) return null;
  const { data, error } = await supabase
    .from("merchant_preferences")
    .select("title, category")
    .eq("household_id", householdId)
    .eq("tax_id", taxId)
    .maybeSingle();
  if (error) console.warn("findMerchantPreference falló (fail-open):", error);
  if (error || !data) return null;
  return { title: data.title as string, category: (data.category as string | null) ?? null };
}

const json = (body: unknown, status = 200, extra: Record<string, string> = {}) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json", ...extra },
  });

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) return json({ error: "Unauthorized" }, 401);

    const token = authHeader.replace("Bearer ", "");

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
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
      return json({ error: "Unauthorized" }, 401);
    }

    // Contexto del scan en 1 solo round-trip: user_id + household + tier +
    // conteos de rate limit (ventana corta y 24 h).
    interface ScanContext {
      user_id: string | null;
      household_id: string | null;
      tier: string | null;
      recent_scans: number | null;
      daily_scans?: number | null;
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
      return json({ error: "internal_error" }, 500);
    }
    if (!ctx?.user_id) {
      console.error("User lookup failed for firebase_uid:", firebaseUid);
      return json({ error: "Unauthorized" }, 401);
    }
    if (!ctx.household_id) {
      return json({ error: "Household no encontrado" }, 403);
    }

    const userId = ctx.user_id as string;
    const householdId = ctx.household_id as string;
    const tier = (ctx.tier as string | null) ?? "free";

    if ((ctx.recent_scans ?? 0) >= RATE_LIMIT_MAX_SCANS) {
      return json(
        { error: "rate_limited", retryAfterSeconds: RATE_LIMIT_WINDOW_SECONDS },
        429,
        { "Retry-After": String(RATE_LIMIT_WINDOW_SECONDS) },
      );
    }
    // Techo de costo: sin esto, 8/min permitía ~11.500 scans por día y usuario.
    if ((ctx.daily_scans ?? 0) >= DAILY_MAX_SCANS) {
      return json(
        { error: "daily_limit", retryAfterSeconds: 3600 },
        429,
        { "Retry-After": "3600" },
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
    let binaryBytes: Uint8Array<ArrayBuffer> | null = null;

    if (contentType.includes("application/json")) {
      const body = await req.json();
      const parsed = body as {
        imageBase64?: string;
        mimeType?: string;
        todayLocal?: string;
      };
      if (!parsed.imageBase64) {
        return json({ error: "imageBase64 es requerido" }, 400);
      }
      if (parsed.imageBase64.length > MAX_BASE64_CHARS) {
        return json({ error: "Imagen demasiado grande. Máx 5MB." }, 413);
      }
      imageBase64 = parsed.imageBase64;
      mimeType = parsed.mimeType ?? "image/webp";
      todayLocal = parsed.todayLocal ?? null;
    } else {
      const bytes = new Uint8Array(await req.arrayBuffer());
      if (bytes.length === 0) {
        return json({ error: "Body vacío: se espera la imagen en bytes" }, 400);
      }
      if (bytes.length > MAX_IMAGE_BYTES) {
        return json({ error: "Imagen demasiado grande. Máx 5MB." }, 413);
      }
      imageBase64 = encodeBase64(bytes);
      mimeType = req.headers.get("x-mime-type") ?? "image/webp";
      todayLocal = req.headers.get("x-today-local");
      binaryBytes = bytes;
    }

    const geminiKey = Deno.env.get("GEMINI_API_KEY");
    if (!geminiKey) {
      return json({ error: "GEMINI_API_KEY no configurada" }, 500);
    }

    // ── Detección de ticket duplicado (misma imagen) ─────────────────────────
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
          model: PRIMARY_MODEL,
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
    const todayIso = resolveTodayIso(todayLocal, new Date());
    const run = await runOcr(geminiKey, buildPrompt(todayIso), imageBase64, mimeType, todayIso);

    const telemetry = {
      model: run.model,
      attempts: run.attempts,
      escalation_reason: run.escalation,
      gemini_latency_ms: run.latencyMs,
      prompt_tokens: run.promptTokens || null,
      output_tokens: run.outputTokens || null,
    };

    if (run.parsed == null) {
      const status = run.httpError?.status ?? 0;
      console.error("Gemini falló:", status, run.httpError?.body.slice(0, 300) ?? "sin presupuesto");
      await finalizeLog(supabase, logId, {
        ...telemetry,
        status: "failed",
        finish_reason: run.httpError ? `http_${status}` : "budget_exhausted",
      });
      return json({ error: "ocr_failed" }, 502);
    }

    const { parsed } = run;
    // Solo metadatos al log de la función: el contenido del ticket (comercio,
    // productos) no tiene por qué quedar en los logs de la plataforma.
    console.log(
      `OCR ${run.model} finish=${parsed.finishReason} attempts=${run.attempts}` +
        ` escalation=${run.escalation} tokens=${run.promptTokens}/${run.outputTokens}` +
        ` ms=${run.latencyMs}`,
    );

    if (!parsed.ok) {
      await finalizeLog(supabase, logId, {
        ...telemetry,
        status: "failed",
        finish_reason: parsed.finishReason ?? null,
      });
      return json({ error: "ocr_invalid_output", finishReason: parsed.finishReason }, 422);
    }

    const result: OcrResult = parsed.result;

    // Consultas posteriores al OCR, en paralelo (~1 round-trip a la base).
    // Ambas fail-open: si fallan, el scan sigue igual.
    const [possibleDuplicate, merchantPref] = await Promise.all([
      findPossibleDuplicate(supabase, householdId, result).catch(() => null),
      findMerchantPreference(supabase, householdId, result.merchantTaxId).catch(() => null),
    ]);

    // El hogar ya le puso nombre/categoría a este comercio (por CUIT): gana
    // sobre lo que infirió la IA ("VARIOS VTA/CPRA" → "Verdulería Juan").
    const aiMerchant = result.merchant;
    const aiCategory = result.category;
    if (merchantPref) {
      result.merchant = merchantPref.title;
      if (merchantPref.category) result.category = merchantPref.category;
    }

    // Path binario: esta fila es LA fila del scan → completar datos de IA.
    // ai_raw_items guarda las líneas del ticket tal cual (rawItems); los
    // nombres limpios viajan en data.items y quedan en matcher_result.
    // ai_amount/ai_date/ai_category permiten medir precisión contra los
    // final_* que escribe el cliente al confirmar.
    // Path legado: dejarla como marcador (el cliente inserta la suya con ai_*).
    const aiFields = isBinaryClient
      ? {
          ai_merchant: aiMerchant,
          ai_confidence: result.confidence,
          ai_raw_items: result.rawItems.length > 0 ? result.rawItems : result.items,
          ai_amount: result.amount,
          ai_date: result.date,
          ai_category: aiCategory,
          amount_check: result.amountCheck,
          duplicate_expense_id: possibleDuplicate?.expenseId ?? null,
          merchant_from_history: merchantPref != null,
        }
      : {};
    await finalizeLog(supabase, logId, {
      ...telemetry,
      status: "success",
      finish_reason: parsed.finishReason ?? null,
      ...aiFields,
    });

    return json({
      data: { ...result, merchantFromHistory: merchantPref != null },
      tier,
      logId: isBinaryClient ? logId : null,
      // Aviso (no bloqueo): esta imagen exacta ya se escaneó con éxito en
      // las últimas 48h en este household.
      duplicateScan: duplicateOf != null,
      // Aviso (no bloqueo): ya hay un gasto con el mismo monto y fecha.
      possibleDuplicate: possibleDuplicate
        ? { title: possibleDuplicate.title, paidAt: possibleDuplicate.paidAt }
        : null,
    });
  } catch (err) {
    console.error("scan-receipt error:", err);
    return json({ error: "internal_error" }, 500);
  }
});
