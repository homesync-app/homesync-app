import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// Edge Function invocada via cron (Supabase Cron) una vez por dia, idealmente
// a la manana hora Argentina (~12:00 UTC). Dispara el RPC que genera los
// recordatorios de pagos planificados para hogares premium; el insert en
// `notifications` gatilla el webhook de push existente (send-notification).
//
// Misma auth que cleanup-old-receipts: CRON_SECRET o service role. Correrla
// dos veces el mismo dia es inocuo (el RPC es idempotente por dia/pago).

Deno.serve(async (req: Request) => {
  const authHeader = req.headers.get("Authorization");
  const cronSecret = Deno.env.get("CRON_SECRET");

  const isCron = cronSecret && authHeader === `Bearer ${cronSecret}`;
  const isServiceRole =
    authHeader === `Bearer ${Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")}`;

  if (!isCron && !isServiceRole) {
    return new Response(JSON.stringify({ error: "Unauthorized" }), {
      status: 401,
      headers: { "Content-Type": "application/json" },
    });
  }

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
  );

  const { data, error } = await supabase.rpc(
    "generate_planned_payment_reminders_v1",
  );

  if (error) {
    console.error("generate_planned_payment_reminders_v1 failed:", error);
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }

  console.log("planned-payment-reminders:", JSON.stringify(data));
  return new Response(JSON.stringify(data), {
    headers: { "Content-Type": "application/json" },
  });
});
