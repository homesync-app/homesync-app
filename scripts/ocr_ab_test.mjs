#!/usr/bin/env node
// @ts-check
/**
 * A/B de modelos OCR para tickets de HomeSync.
 *
 * Corre la MISMA imagen de ticket contra varios modelos de Gemini y arma una
 * tabla comparativa de: campos extraídos, latencia, tokens usados y costo
 * estimado por scan. Sirve para decidir con datos reales (tickets argentinos
 * arrugados / térmicos) antes de migrar en producción.
 *
 * NO toca Supabase ni la app. Llama directo a la API de Gemini con tu API key,
 * replicando el MISMO prompt + responseSchema que usa la Edge Function
 * `scan-receipt`, así la comparación es representativa.
 *
 * ── Uso ────────────────────────────────────────────────────────────────────
 *   # 1. Poné fotos de tickets reales en una carpeta (jpg/png/webp).
 *   # 2. Exportá tu API key de Gemini:
 *   #      Windows (cmd):   set GEMINI_API_KEY=xxxx
 *   #      Windows (pwsh):  $env:GEMINI_API_KEY="xxxx"
 *   # 3. Corré:
 *   node scripts/ocr_ab_test.mjs ./mis_tickets
 *   node scripts/ocr_ab_test.mjs ./mis_tickets --models gemini-2.5-flash,gemini-3.1-flash-lite,gemini-3.5-flash
 *   node scripts/ocr_ab_test.mjs ./mis_tickets --json resultados.json
 *
 * Requiere Node 18+ (usa fetch nativo). Sin dependencias externas.
 */

import { readFile, readdir, writeFile } from "node:fs/promises";
import { extname, join, basename } from "node:path";

// ─── Config ──────────────────────────────────────────────────────────────────

const API_KEY = process.env.GEMINI_API_KEY;
if (!API_KEY) {
  console.error(
    "ERROR: falta GEMINI_API_KEY en el entorno.\n" +
      "  pwsh: $env:GEMINI_API_KEY=\"tu_key\"\n" +
      "  cmd:  set GEMINI_API_KEY=tu_key",
  );
  process.exit(1);
}

const DEFAULT_MODELS = [
  "gemini-2.5-flash", // baseline actual (deprecado, shutdown 17-jun-2026)
  "gemini-3.1-flash-lite", // candidato recomendado
  "gemini-3.5-flash", // opción premium si lo barato falla
];

// Precios USD por 1M tokens (input/output). Aproximados a 2026-05-30; ajustar
// si cambian. Fuente: ai.google.dev/gemini-api/docs/pricing + comparativas.
const PRICING = {
  "gemini-2.5-flash": { in: 0.3, out: 2.5 },
  "gemini-2.5-flash-lite": { in: 0.1, out: 0.4 },
  "gemini-3.1-flash-lite": { in: 0.25, out: 1.5 },
  "gemini-3.5-flash": { in: 1.5, out: 9.0 },
};

const MIME_BY_EXT = {
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".png": "image/png",
  ".webp": "image/webp",
  ".heic": "image/heic",
};

const VALID_CATEGORIES = [
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
];

const RESPONSE_SCHEMA = {
  type: "object",
  properties: {
    merchant: { type: "string", nullable: true },
    amount: { type: "number", nullable: true },
    date: { type: "string", nullable: true },
    category: { type: "string", enum: VALID_CATEGORIES },
    items: { type: "array", items: { type: "string" } },
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
};

function buildPrompt(todayIso) {
  return `Sos un extractor de datos de tickets de compra.
Analizá la imagen del ticket y completá los campos del esquema de salida.

Reglas para merchant:
- Usá el nombre real del comercio si es claro y reconocible (ej: "Farmacity", "McDonald's", "Carrefour")
- Si el nombre en el ticket es un código fiscal genérico ("VARIOS VTA/CPRA", "CF", "CONSUMIDOR FINAL", "MOSTRADOR", siglas incomprensibles), NO lo uses
- En ese caso, inferí un nombre descriptivo del tipo de negocio basándote en los productos
- Si no podés inferir nada útil, dejá merchant en null

Reglas para category: supermarket, restaurants, transport, health, entertainment, clothing, electronics, pets, education, other.

Otras reglas:
- amount: número total del ticket sin signo $, punto como decimal
- date: formato YYYY-MM-DD. La fecha de HOY es ${todayIso}. Nunca futura ni de hace más de un año; si no se ve claramente dejá date en null
- items: nombres limpios de productos, sin precios, cantidades ni códigos
- confidence: 0.0 a 1.0 según qué tan legible está el ticket
- NUNCA inventes datos`;
}

// Algunos modelos 3.x rechazan thinkingBudget; algunos 2.5 rechazan
// thinkingLevel. Elegimos el parámetro correcto según la familia.
function thinkingConfigFor(model) {
  if (model.startsWith("gemini-3")) {
    return { thinkingLevel: "minimal" };
  }
  return { thinkingBudget: 0 };
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

function extractJsonString(rawText) {
  if (!rawText) return null;
  const m =
    rawText.match(/```(?:json)?\s*([\s\S]*?)```/) ??
    rawText.match(/(\{[\s\S]*\})/);
  return m?.[1] ?? m?.[0] ?? null;
}

async function callModel(model, imageBase64, mimeType, prompt) {
  const url = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${API_KEY}`;
  const t0 = Date.now();
  const resp = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      contents: [
        {
          parts: [
            { text: prompt },
            { inline_data: { mime_type: mimeType, data: imageBase64 } },
          ],
        },
      ],
      generationConfig: {
        temperature: 0.1,
        maxOutputTokens: 1024,
        thinkingConfig: thinkingConfigFor(model),
        responseMimeType: "application/json",
        responseSchema: RESPONSE_SCHEMA,
      },
    }),
  });
  const ms = Date.now() - t0;

  if (!resp.ok) {
    const body = await resp.text();
    return { ok: false, ms, status: resp.status, error: body.slice(0, 300) };
  }

  const data = await resp.json();
  const candidate = data?.candidates?.[0];
  const rawText = candidate?.content?.parts?.[0]?.text ?? "";
  const usage = data?.usageMetadata ?? {};
  const jsonStr = extractJsonString(rawText);

  let parsed = null;
  try {
    parsed = jsonStr ? JSON.parse(jsonStr) : null;
  } catch {
    parsed = null;
  }

  const price = PRICING[model];
  const inTok = usage.promptTokenCount ?? 0;
  const outTok = usage.candidatesTokenCount ?? usage.totalTokenCount ?? 0;
  const costUsd = price
    ? (inTok / 1e6) * price.in + (outTok / 1e6) * price.out
    : null;

  return {
    ok: true,
    ms,
    parsed,
    rawText: parsed ? undefined : rawText.slice(0, 200),
    inTok,
    outTok,
    costUsd,
    finishReason: candidate?.finishReason,
  };
}

function fmtMoney(n) {
  if (n == null) return "—";
  return "$" + n.toFixed(6);
}

function fmtField(v) {
  if (v == null) return "∅";
  if (Array.isArray(v)) return `[${v.length}] ${v.slice(0, 3).join(", ")}${v.length > 3 ? "…" : ""}`;
  return String(v);
}

// ─── Main ────────────────────────────────────────────────────────────────────

async function main() {
  const args = process.argv.slice(2);
  const dir = args.find((a) => !a.startsWith("--"));
  if (!dir) {
    console.error("Uso: node scripts/ocr_ab_test.mjs <carpeta_tickets> [--models a,b,c] [--json out.json]");
    process.exit(1);
  }

  const modelsArg = args.find((a) => a.startsWith("--models"));
  const models = modelsArg
    ? (modelsArg.split("=")[1] ?? args[args.indexOf(modelsArg) + 1]).split(",").map((s) => s.trim())
    : DEFAULT_MODELS;

  const jsonArg = args.find((a) => a.startsWith("--json"));
  const jsonOut = jsonArg
    ? jsonArg.split("=")[1] ?? args[args.indexOf(jsonArg) + 1]
    : null;

  const files = (await readdir(dir)).filter((f) =>
    MIME_BY_EXT[extname(f).toLowerCase()],
  );
  if (files.length === 0) {
    console.error(`No hay imágenes (jpg/png/webp/heic) en ${dir}`);
    process.exit(1);
  }

  const todayIso = new Date().toISOString().slice(0, 10);
  const prompt = buildPrompt(todayIso);

  console.log(`\nOCR A/B — ${files.length} ticket(s) × ${models.length} modelo(s)`);
  console.log(`Modelos: ${models.join(", ")}\n`);

  const report = [];
  const totals = Object.fromEntries(
    models.map((m) => [m, { ms: 0, cost: 0, ok: 0, fail: 0 }]),
  );

  for (const file of files) {
    const path = join(dir, file);
    const bytes = await readFile(path);
    const base64 = bytes.toString("base64");
    const mimeType = MIME_BY_EXT[extname(file).toLowerCase()];

    console.log(`\n━━━ ${file} (${(bytes.length / 1024).toFixed(0)} KB) ━━━`);
    const perFile = { file, results: {} };

    // Secuencial a propósito: no saturar rate limits ni mezclar latencias.
    for (const model of models) {
      process.stdout.write(`  ${model.padEnd(24)} `);
      try {
        const r = await callModel(model, base64, mimeType, prompt);
        perFile.results[model] = r;
        if (!r.ok) {
          totals[model].fail++;
          console.log(`✗ HTTP ${r.status}: ${r.error}`);
          continue;
        }
        totals[model].ok++;
        totals[model].ms += r.ms;
        totals[model].cost += r.costUsd ?? 0;
        const p = r.parsed ?? {};
        console.log(
          `✓ ${r.ms}ms  ${fmtMoney(r.costUsd)}  ` +
            `merchant=${fmtField(p.merchant)} amount=${fmtField(p.amount)} ` +
            `cat=${fmtField(p.category)} conf=${fmtField(p.confidence)} items=${fmtField(p.items)}`,
        );
      } catch (e) {
        totals[model].fail++;
        console.log(`✗ ${e.message}`);
        perFile.results[model] = { ok: false, error: e.message };
      }
    }
    report.push(perFile);
  }

  // Resumen
  console.log(`\n\n══════════ RESUMEN (${files.length} tickets) ══════════`);
  console.log(
    "modelo".padEnd(24) +
      "ok".padEnd(6) +
      "fail".padEnd(6) +
      "lat.media".padEnd(12) +
      "costo total".padEnd(14) +
      "costo/scan",
  );
  for (const model of models) {
    const t = totals[model];
    const avgMs = t.ok ? Math.round(t.ms / t.ok) : 0;
    const perScan = t.ok ? t.cost / t.ok : 0;
    console.log(
      model.padEnd(24) +
        String(t.ok).padEnd(6) +
        String(t.fail).padEnd(6) +
        `${avgMs}ms`.padEnd(12) +
        fmtMoney(t.cost).padEnd(14) +
        fmtMoney(perScan),
    );
  }

  // Proyección de costo a volumen
  console.log(`\nProyección de costo (costo/scan × volumen):`);
  for (const vol of [1000, 10000, 100000]) {
    const row = models
      .map((m) => {
        const t = totals[m];
        const perScan = t.ok ? t.cost / t.ok : 0;
        return `${m}=$${(perScan * vol).toFixed(2)}`;
      })
      .join("  ");
    console.log(`  ${String(vol).padStart(7)} scans/mes:  ${row}`);
  }

  console.log(
    `\nNota: la PRECISIÓN la juzgás vos comparando los campos arriba contra el ticket real.\n` +
      `El script no tiene "ground truth"; medí cuántos merchant/amount/category aciertan por modelo.`,
  );

  if (jsonOut) {
    await writeFile(jsonOut, JSON.stringify({ todayIso, models, report, totals }, null, 2));
    console.log(`\nResultado completo guardado en ${jsonOut}`);
  }
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
