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
  items: string[];
  confidence: number;
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

/**
 * Normalizes/sanitizes a raw parsed Gemini object into a strict OcrResult:
 * - amount: non-negative finite number rounded to 2 decimals, else null
 * - date: only YYYY-MM-DD strings survive, else null
 * - category: must be in VALID_CATEGORIES, else "other"
 * - items: trimmed, de-duplicated, non-empty, capped at 30
 * - merchant: trimmed, capped at 100 chars, else null
 * - confidence: clamped to [0, 1], defaults to 0
 */
export function normalizeOcrResult(parsed: Partial<OcrResult>): OcrResult {
  const rawAmount = parsed.amount;
  const amount: number | null =
    typeof rawAmount === "number" && rawAmount >= 0 && isFinite(rawAmount)
      ? Math.round(rawAmount * 100) / 100
      : null;

  const rawDate = parsed.date;
  const date: string | null =
    typeof rawDate === "string" && /^\d{4}-\d{2}-\d{2}$/.test(rawDate)
      ? rawDate
      : null;

  const rawCat = parsed.category;
  const category =
    typeof rawCat === "string" &&
    (VALID_CATEGORIES as readonly string[]).includes(rawCat)
      ? rawCat
      : "other";

  const rawItems = Array.isArray(parsed.items) ? parsed.items : [];
  const items = [
    ...new Set(
      rawItems
        .filter((i) => typeof i === "string" && i.trim().length > 0)
        .map((i) => (i as string).trim()),
    ),
  ].slice(0, 30);

  const merchant =
    typeof parsed.merchant === "string" && parsed.merchant.trim().length > 0
      ? parsed.merchant.trim().slice(0, 100)
      : null;

  const confidence =
    typeof parsed.confidence === "number"
      ? Math.min(1, Math.max(0, parsed.confidence))
      : 0;

  return { merchant, amount, date, category, items, confidence };
}
