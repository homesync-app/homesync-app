import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function getBearerToken(req: Request): string | null {
  const header = req.headers.get("Authorization") ?? req.headers.get("authorization");
  if (!header?.startsWith("Bearer ")) return null;
  return header.slice("Bearer ".length).trim();
}

function firstName(fullName: string | null | undefined, email: string | null | undefined) {
  const trimmed = fullName?.trim();
  if (trimmed) return trimmed.split(/\s+/)[0];
  return email?.split("@")[0] ?? "";
}

function isEnglish(locale: string | null | undefined) {
  return (locale ?? "").toLowerCase().startsWith("en");
}

function escapeHtml(value: string) {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  try {
    const token = getBearerToken(req);
    if (!token) return json({ error: "Missing Authorization bearer token" }, 401);

    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
    const resendApiKey = Deno.env.get("RESEND_API_KEY");
    const from = Deno.env.get("SUPPORT_EMAIL_FROM") ?? "HomeSync <support@homesync.app>";

    if (!supabaseUrl || !serviceRoleKey) return json({ error: "Supabase env missing" }, 500);
    if (!resendApiKey) return json({ error: "RESEND_API_KEY is not configured" }, 500);

    const supabase = createClient(supabaseUrl, serviceRoleKey);
    const { data: authData, error: authError } = await supabase.auth.getUser(token);
    const adminEmail = authData.user?.email;
    if (authError || !adminEmail) return json({ error: "Unauthorized" }, 401);

    const { data: adminUser, error: adminError } = await supabase
      .from("users")
      .select("id, email, is_admin")
      .eq("email", adminEmail)
      .maybeSingle();

    if (adminError || !adminUser?.is_admin) return json({ error: "Forbidden" }, 403);

    const payload = await req.json();
    const feedbackId = String(payload.feedback_id ?? "");
    const body = String(payload.body ?? "").trim();
    const subject =
      String(payload.subject ?? "").trim() || "Respuesta de HomeSync sobre tu mensaje";

    if (!feedbackId || !body) return json({ error: "Missing feedback_id or body" }, 400);

    const { data: feedback, error: feedbackError } = await supabase
      .from("user_feedback")
      .select("id, email, title, type, locale, user_id, response_count")
      .eq("id", feedbackId)
      .maybeSingle();

    if (feedbackError || !feedback) return json({ error: "Feedback not found" }, 404);
    if (!feedback.email) return json({ error: "Feedback has no recipient email" }, 400);

    const { data: feedbackUser } = await supabase
      .from("users")
      .select("email, full_name")
      .eq("id", feedback.user_id)
      .maybeSingle();

    const english = isEnglish(feedback.locale);
    const name = firstName(feedbackUser?.full_name, feedbackUser?.email ?? feedback.email);
    const greeting = name ? (english ? `Hi ${name},` : `Hola ${name},`) : english ? "Hi," : "Hola,";
    const intro = english
      ? feedback.type === "bug"
        ? "Thanks for reporting this issue in HomeSync."
        : "Thanks for sharing your idea for HomeSync."
      : feedback.type === "bug"
        ? "Gracias por reportar este error en HomeSync."
        : "Gracias por compartir tu idea para HomeSync.";

    const html = `
      <div style="font-family:Inter,Arial,sans-serif;line-height:1.6;color:#111827">
        <p>${escapeHtml(greeting)}</p>
        <p>${intro}</p>
        <div style="border-left:4px solid #7f0df2;padding-left:16px;margin:20px 0;color:#374151">
          ${escapeHtml(body).replaceAll("\n", "<br>")}
        </div>
        <p style="color:#6b7280;font-size:14px">
          ${english ? "Original message" : "Mensaje original"}: "${escapeHtml(feedback.title)}"
        </p>
        <p>${english ? "Warmly," : "Abrazo,"}<br>HomeSync</p>
      </div>
    `;

    const emailResponse = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${resendApiKey}`,
      },
      body: JSON.stringify({
        from,
        to: feedback.email,
        reply_to: adminEmail,
        subject,
        text: `${greeting}\n\n${intro}\n\n${body}\n\n${english ? "Original message" : "Mensaje original"}: "${feedback.title}"\n\nHomeSync`,
        html,
      }),
    });

    const emailData = await emailResponse.json().catch(() => ({}));
    if (!emailResponse.ok) {
      console.error("Resend failed", emailResponse.status, emailData);
      return json({ error: "Email provider failed", details: emailData }, 502);
    }

    const providerMessageId = typeof emailData.id === "string" ? emailData.id : null;

    const { error: insertError } = await supabase.from("user_feedback_responses").insert({
      feedback_id: feedbackId,
      responder_user_id: adminUser.id,
      responder_email: adminEmail,
      recipient_email: feedback.email,
      subject,
      body,
      provider_message_id: providerMessageId,
    });

    if (insertError) throw insertError;

    const { error: updateError } = await supabase
      .from("user_feedback")
      .update({
        status: "replied",
        resolved: true,
        responded_at: new Date().toISOString(),
        last_response_at: new Date().toISOString(),
        response_count: Number(feedback.response_count ?? 0) + 1,
      })
      .eq("id", feedbackId);

    if (updateError) throw updateError;

    return json({ ok: true, provider_message_id: providerMessageId });
  } catch (error) {
    console.error("send-feedback-reply error", error);
    return json({ error: "Internal error" }, 500);
  }
});
