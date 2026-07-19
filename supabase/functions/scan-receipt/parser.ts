// Pure, dependency-free parsing helpers for the scan-receipt Edge Function.
//
// This logic used to live inline inside `index.ts`'s request handler, which
// made it impossible to unit-test without a live HTTP request + Gemini call.
// It is extracted here verbatim (same behavior) so it can be covered by
// `parser.test.ts`. Keep this module free of Deno/network/Supabase imports.

export interface OcrResult {
  merchant: string | null;
  amount: number | null;
  date: string | null;
  category: string | null;
  /// Nombres limpios de producto (abreviaturas expandidas, sin marca).
  /// Mismo campo `items` que siempre → los clientes viejos siguen andando,
  /// solo que ahora reciben nombres mejores para su matcher local.
  items: string[];
  /// Líneas del ticket tal cual impresas, alineadas 1:1 con `items`.
  /// Van a ai_raw_items para telemetría/panel admin.
  rawItems: string[];
  confidence: number;
}

/// Forma cruda de lo que puede devolver Gemini antes de normalizar.
/// `items` puede venir como strings (formato viejo / defensivo) o como
/// objetos {raw, name} (schema actual).
export interface OcrParsedInput {
  merchant?: unknown;
  amount?: unknown;
  date?: unknown;
  category?: unknown;
  items?: unknown;
  confidence?: unknown;
}

export const VALID_CATEGORIES = [
  "supermarket",
  "restaurants",
  "transport",
  "health",
  "entertainment",
  "clothing",
  "electronics",
  "pets",
  "education",
  "other",
] as const;

/**
 * JSON schema entregado a Gemini vía `generationConfig.responseSchema`.
 *
 * Fuerza al modelo a devolver JSON que cumple esta forma exacta (sin bloques
 * cercados ni prosa), usando el subconjunto de OpenAPI 3.0 que soporta la API.
 * `category` se restringe con `enum` a las categorías válidas, así el modelo
 * no inventa una fuera de lista. `propertyOrdering` ayuda a la consistencia.
 *
 * Igual mantenemos `normalizeOcrResult` como capa de saneo defensivo: el schema
 * acota el formato, pero los rangos (amount ≥ 0, confidence ∈ [0,1], fecha
 * plausible, dedupe de items) se siguen validando del lado del servidor.
 */
export const RESPONSE_SCHEMA = {
  type: "object",
  properties: {
    merchant: { type: "string", nullable: true },
    amount: { type: "number", nullable: true },
    date: { type: "string", nullable: true },
    category: { type: "string", enum: [...VALID_CATEGORIES] },
    // Cada item trae la línea impresa (raw) Y el nombre limpio (name).
    // Antes pedíamos solo "nombres limpios" y Gemini a veces devolvía la
    // abreviatura del ticket tal cual ("GALL ECOOP DE ARROZ") y a veces la
    // expandía ("Galletas de arroz") — una lotería que el matcher pagaba.
    items: {
      type: "array",
      items: {
        type: "object",
        properties: {
          raw: { type: "string" },
          name: { type: "string" },
        },
        required: ["raw", "name"],
        propertyOrdering: ["raw", "name"],
      },
    },
    confidence: { type: "number" },
  },
  required: ["amount", "category", "items", "confidence"],
  propertyOrdering: [
    "merchant",
    "amount",
    "date",
    "category",
    "items",
    "confidence",
  ],
} as const;

/**
 * Pulls the JSON payload out of Gemini's raw text response. Gemini may wrap the
 * JSON in a ```json fenced block or return it bare. Returns null when no JSON
 * object can be located.
 */
export function extractJsonString(rawText: string): string | null {
  if (!rawText) return null;
  const jsonMatch =
    rawText.match(/```(?:json)?\s*([\s\S]*?)```/) ??
    rawText.match(/(\{[\s\S]*\})/);
  return jsonMatch?.[1] ?? jsonMatch?.[0] ?? null;
}

export interface NormalizeOptions {
  /**
   * Reference "today" used for the date sanity check. When provided, parsed
   * dates that are in the future or older than ~1 year are dropped to null.
   * Left optional so the pure unit tests stay independent of the wall clock.
   */
  today?: Date;
}

/** Días hacia atrás que consideramos una fecha de ticket plausible. */
const MAX_RECEIPT_AGE_DAYS = 366;
const MS_PER_DAY = 24 * 60 * 60 * 1000;

/**
 * Normalizes/sanitizes a raw parsed Gemini object into a strict OcrResult:
 * - amount: non-negative finite number rounded to 2 decimals, else null
 * - date: only YYYY-MM-DD strings survive; when `today` is given, future or
 *   absurdly-old dates are also dropped to null
 * - category: must be in VALID_CATEGORIES, else "other"
 * - items: accepts strings (legacy) or {raw, name} objects (current schema);
 *   trimmed, de-duplicated by clean name, non-empty, capped at 30. `items`
 *   carries the clean names, `rawItems` the printed ticket lines (1:1).
 * - merchant: trimmed, capped at 100 chars, else null
 * - confidence: clamped to [0, 1], defaults to 0
 */
export function normalizeOcrResult(
  parsed: OcrParsedInput,
  options: NormalizeOptions = {},
): OcrResult {
  const rawAmount = parsed.amount;
  const amount: number | null =
    typeof rawAmount === "number" && rawAmount >= 0 && isFinite(rawAmount)
      ? Math.round(rawAmount * 100) / 100
      : null;

  const rawDate = parsed.date;
  let date: string | null =
    typeof rawDate === "string" && /^\d{4}-\d{2}-\d{2}$/.test(rawDate)
      ? rawDate
      : null;

  // Sanity check temporal: un ticket no puede ser del futuro ni de hace años.
  // Solo se aplica cuando el caller pasa una referencia de "hoy".
  if (date && options.today) {
    const t = options.today;
    const todayUtc = Date.UTC(
      t.getUTCFullYear(),
      t.getUTCMonth(),
      t.getUTCDate(),
    );
    const parsedUtc = Date.parse(`${date}T00:00:00Z`);
    const oldestAllowed = todayUtc - MAX_RECEIPT_AGE_DAYS * MS_PER_DAY;
    // +1 día de tolerancia por zonas horarias del dispositivo.
    const newestAllowed = todayUtc + MS_PER_DAY;
    if (
      Number.isNaN(parsedUtc) ||
      parsedUtc > newestAllowed ||
      parsedUtc < oldestAllowed
    ) {
      date = null;
    }
  }

  const rawCat = parsed.category;
  const category =
    typeof rawCat === "string" &&
    (VALID_CATEGORIES as readonly string[]).includes(rawCat)
      ? rawCat
      : "other";

  const itemsIn = Array.isArray(parsed.items) ? parsed.items : [];
  const items: string[] = [];
  const rawItems: string[] = [];
  const seenNames = new Set<string>();
  for (const it of itemsIn) {
    let name = "";
    let raw = "";
    if (typeof it === "string") {
      name = it.trim();
      raw = name;
    } else if (it && typeof it === "object") {
      const o = it as { raw?: unknown; name?: unknown };
      name = typeof o.name === "string" ? o.name.trim() : "";
      raw = typeof o.raw === "string" ? o.raw.trim() : "";
      if (!name) name = raw;
      if (!raw) raw = name;
    }
    if (!name) continue;
    const key = name.toLowerCase();
    if (seenNames.has(key)) continue;
    seenNames.add(key);
    items.push(name);
    rawItems.push(raw);
    if (items.length >= 30) break;
  }

  const merchant =
    typeof parsed.merchant === "string" && parsed.merchant.trim().length > 0
      ? parsed.merchant.trim().slice(0, 100)
      : null;

  const confidence =
    typeof parsed.confidence === "number"
      ? Math.min(1, Math.max(0, parsed.confidence))
      : 0;

  return { merchant, amount, date, category, items, rawItems, confidence };
}
