// Unit tests for the scan-receipt pure parsing layer.
//
// Run with:  deno test supabase/functions/scan-receipt/parser.test.ts
// (also runs in CI via .github/workflows/edge_functions.yml)

import {
  assertEquals,
  assert,
} from "https://deno.land/std@0.224.0/assert/mod.ts";
import {
  extractJsonString,
  normalizeOcrResult,
  VALID_CATEGORIES,
} from "./parser.ts";

Deno.test("extractJsonString: bare JSON object", () => {
  const raw = '{"amount": 100, "merchant": "Carrefour"}';
  const json = extractJsonString(raw);
  assert(json !== null);
  assertEquals(JSON.parse(json!).amount, 100);
});

Deno.test("extractJsonString: fenced ```json block", () => {
  const raw = 'Acá tenés:\n```json\n{"amount": 42}\n```\nfin';
  const json = extractJsonString(raw);
  assert(json !== null);
  assertEquals(JSON.parse(json!).amount, 42);
});

Deno.test("extractJsonString: fenced block without language tag", () => {
  const raw = '```\n{"amount": 7}\n```';
  const json = extractJsonString(raw);
  assert(json !== null);
  assertEquals(JSON.parse(json!).amount, 7);
});

Deno.test("extractJsonString: returns null when no JSON present", () => {
  assertEquals(extractJsonString("no hay json aca"), null);
  assertEquals(extractJsonString(""), null);
});

Deno.test("normalizeOcrResult: amount rounds to 2 decimals", () => {
  const r = normalizeOcrResult({ amount: 12.3456 });
  assertEquals(r.amount, 12.35);
});

Deno.test("normalizeOcrResult: negative / NaN / Infinity amount -> null", () => {
  assertEquals(normalizeOcrResult({ amount: -5 }).amount, null);
  assertEquals(normalizeOcrResult({ amount: NaN }).amount, null);
  assertEquals(normalizeOcrResult({ amount: Infinity }).amount, null);
  assertEquals(
    normalizeOcrResult({ amount: "100" as unknown as number }).amount,
    null,
  );
});

Deno.test("normalizeOcrResult: only YYYY-MM-DD dates survive", () => {
  assertEquals(normalizeOcrResult({ date: "2026-04-11" }).date, "2026-04-11");
  assertEquals(normalizeOcrResult({ date: "11/04/2026" }).date, null);
  assertEquals(normalizeOcrResult({ date: "not-a-date" }).date, null);
  assertEquals(normalizeOcrResult({}).date, null);
});

Deno.test("normalizeOcrResult: invalid category falls back to 'other'", () => {
  assertEquals(normalizeOcrResult({ category: "supermarket" }).category, "supermarket");
  assertEquals(normalizeOcrResult({ category: "casino" }).category, "other");
  assertEquals(normalizeOcrResult({}).category, "other");
});

Deno.test("normalizeOcrResult: every VALID_CATEGORIES value is accepted", () => {
  for (const cat of VALID_CATEGORIES) {
    assertEquals(normalizeOcrResult({ category: cat }).category, cat);
  }
});

Deno.test("normalizeOcrResult: items trimmed, de-duplicated, capped at 30", () => {
  const r = normalizeOcrResult({
    items: ["  Leche ", "Leche", "", "   ", "Pan"],
  });
  assertEquals(r.items, ["Leche", "Pan"]);

  const many = Array.from({ length: 50 }, (_, i) => `item-${i}`);
  assertEquals(normalizeOcrResult({ items: many }).items.length, 30);
});

Deno.test("normalizeOcrResult: merchant trimmed and capped at 100 chars", () => {
  assertEquals(normalizeOcrResult({ merchant: "  Farmacity " }).merchant, "Farmacity");
  assertEquals(normalizeOcrResult({ merchant: "   " }).merchant, null);
  assertEquals(normalizeOcrResult({ merchant: 123 as unknown as string }).merchant, null);
  const long = "x".repeat(200);
  assertEquals(normalizeOcrResult({ merchant: long }).merchant!.length, 100);
});

Deno.test("normalizeOcrResult: confidence clamped to [0,1]", () => {
  assertEquals(normalizeOcrResult({ confidence: 0.7 }).confidence, 0.7);
  assertEquals(normalizeOcrResult({ confidence: 5 }).confidence, 1);
  assertEquals(normalizeOcrResult({ confidence: -2 }).confidence, 0);
  assertEquals(normalizeOcrResult({}).confidence, 0);
});

Deno.test("normalizeOcrResult: realistic end-to-end Gemini payload", () => {
  const raw = '```json\n' +
    JSON.stringify({
      merchant: "  Carrefour Express  ",
      amount: 1234.567,
      date: "2026-04-11",
      category: "supermarket",
      items: ["Leche", "Leche", "Pan", ""],
      confidence: 0.95,
    }) +
    '\n```';

  const jsonStr = extractJsonString(raw);
  assert(jsonStr !== null);
  const result = normalizeOcrResult(JSON.parse(jsonStr!));

  assertEquals(result.merchant, "Carrefour Express");
  assertEquals(result.amount, 1234.57);
  assertEquals(result.date, "2026-04-11");
  assertEquals(result.category, "supermarket");
  assertEquals(result.items, ["Leche", "Pan"]);
  assertEquals(result.confidence, 0.95);
});
