import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

// Modelo de respuesta esperado de Gemini
interface OcrResult {
  merchant: string | null;
  amount: number | null;
  date: string | null;
  category: string | null;
  items: string[];
  confidence: number;
}

const GEMINI_API_URL =
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent";

const PROMPT = `Sos un extractor de datos de tickets de compra.
Analizá la imagen y devolvé SOLO JSON válido, sin texto extra, sin bloques de código:
{
  "merchant": "nombre del comercio",
  "amount": 1234.56,
  "date": "2026-04-11",
  "category": "supermarket|restaurants|transport|health|entertainment|other",
  "items": ["producto 1", "producto 2"],
  "confidence": 0.95
}
Reglas:
- merchant: nombre limpio del comercio (sin dirección ni CUIT)
- amount: número total del ticket sin signo $, punto como decimal
- date: formato YYYY-MM-DD; si no se ve claramente usá null
- category: elegí la más apropiada según el tipo de comercio
- items: nombres limpios de productos, sin precios, cantidades ni códigos de barras
- confidence: 0.0 a 1.0 según qué tan legible está el ticket
- Si no podés leer algo con certeza usá null, NUNCA inventes datos`;

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // Verificar autenticación
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
    );

    const { data: { user }, error: authError } = await supabase.auth.getUser(
      authHeader.replace("Bearer ", "")
    );
    if (authError || !user) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Input: imagen en base64
    // Flutter comprime localmente y manda los bytes como base64.
    // La imagen NO se guarda en Storage hasta que el usuario confirme el gasto.
    const body = await req.json();
    const { imageBase64, mimeType = "image/webp" } = body as {
      imageBase64: string;
      mimeType?: string;
    };

    if (!imageBase64) {
      return new Response(
        JSON.stringify({ error: "imageBase64 es requerido" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Validar tamaño razonable (max ~5MB base64 ≈ ~3.75MB imagen)
    if (imageBase64.length > 7_000_000) {
      return new Response(
        JSON.stringify({ error: "Imagen demasiado grande. Máx 5MB." }),
        {
          status: 413,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const geminiKey = Deno.env.get("GEMINI_API_KEY");
    if (!geminiKey) {
      return new Response(
        JSON.stringify({ error: "GEMINI_API_KEY no configurada" }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Llamar a Gemini 2.5 Flash con la imagen en base64
    const geminiResp = await fetch(`${GEMINI_API_URL}?key=${geminiKey}`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [
          {
            parts: [
              { text: PROMPT },
              {
                inline_data: {
                  mime_type: mimeType,
                  data: imageBase64,
                },
              },
            ],
          },
        ],
        generationConfig: {
          temperature: 0.1, // bajo para extracciones precisas
          maxOutputTokens: 512,
        },
      }),
    });

    if (!geminiResp.ok) {
      const errText = await geminiResp.text();
      console.error("Gemini error:", errText);
      return new Response(
        JSON.stringify({ error: "Error llamando a Gemini", detail: errText }),
        {
          status: 502,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const geminiData = await geminiResp.json();
    const rawText: string =
      geminiData?.candidates?.[0]?.content?.parts?.[0]?.text ?? "";

    // Extraer JSON aunque Gemini agregue texto decorativo
    const jsonMatch = rawText.match(/\{[\s\S]*\}/);
    if (!jsonMatch) {
      console.error("No JSON en respuesta de Gemini:", rawText);
      return new Response(
        JSON.stringify({ error: "Gemini no devolvió JSON válido" }),
        {
          status: 422,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const parsed: OcrResult = JSON.parse(jsonMatch[0]);

    // Normalización defensiva: tipos estrictos, rangos válidos, sin ruido
    const VALID_CATEGORIES = [
      "supermarket", "restaurants", "transport",
      "health", "entertainment", "other",
    ];

    const rawAmount = parsed.amount;
    const amount: number | null =
      typeof rawAmount === "number" && rawAmount >= 0 && isFinite(rawAmount)
        ? Math.round(rawAmount * 100) / 100  // máx 2 decimales
        : null;

    const rawDate = parsed.date;
    const date: string | null =
      typeof rawDate === "string" && /^\d{4}-\d{2}-\d{2}$/.test(rawDate)
        ? rawDate
        : null;

    const rawCat = parsed.category;
    const category: string =
      typeof rawCat === "string" && VALID_CATEGORIES.includes(rawCat)
        ? rawCat
        : "other";

    // Items: strings no vacíos, deduplicados, máx 30 items
    const rawItems = Array.isArray(parsed.items) ? parsed.items : [];
    const items: string[] = [
      ...new Set(
        rawItems
          .filter((i) => typeof i === "string" && i.trim().length > 0)
          .map((i) => (i as string).trim())
      ),
    ].slice(0, 30);

    const result: OcrResult = {
      merchant:
        typeof parsed.merchant === "string" && parsed.merchant.trim().length > 0
          ? parsed.merchant.trim().slice(0, 100)  // truncar nombres muy largos
          : null,
      amount,
      date,
      category,
      items,
      confidence:
        typeof parsed.confidence === "number"
          ? Math.min(1, Math.max(0, parsed.confidence))
          : 0,
    };

    return new Response(JSON.stringify({ data: result }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err) {
    console.error("scan-receipt error:", err);
    return new Response(
      JSON.stringify({ error: "Error interno", detail: String(err) }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
