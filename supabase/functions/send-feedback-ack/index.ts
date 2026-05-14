import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { createRemoteJWKSet, jwtVerify } from "https://esm.sh/jose@5";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const FIREBASE_PROJECT_ID = "homesync-prod-r7-123";

interface FirebaseJWTPayload {
  sub: string;
  email?: string;
  aud: string;
  iss: string;
}

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

async function verifyFirebaseUser(token: string): Promise<string | null> {
  try {
    const jwks = createRemoteJWKSet(
      new URL("https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com"),
    );

    const { payload } = await jwtVerify(token, jwks, {
      issuer: `https://securetoken.google.com/${FIREBASE_PROJECT_ID}`,
      audience: FIREBASE_PROJECT_ID,
    });

    return (payload as FirebaseJWTPayload).sub || null;
  } catch (error) {
    console.error("Firebase JWT verification failed:", error);
    return null;
  }
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  try {
    const token = getBearerToken(req);
    if (!token) return json({ error: "Missing Authorization bearer token" }, 401);

    const firebaseUid = await verifyFirebaseUser(token);
    if (!firebaseUid) return json({ error: "Unauthorized" }, 401);

    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
    const resendApiKey = Deno.env.get("RESEND_API_KEY");
    const from = Deno.env.get("SUPPORT_EMAIL_FROM") ?? "HomeSync <support@homesync.app>";

    if (!supabaseUrl || !serviceRoleKey) return json({ error: "Supabase env missing" }, 500);
    if (!resendApiKey) return json({ error: "RESEND_API_KEY is not configured" }, 500);

    const { feedback_id: feedbackId } = await req.json();
    if (!feedbackId) return json({ error: "Missing feedback_id" }, 400);

    const supabase = createClient(supabaseUrl, serviceRoleKey);
    const { data: userRow, error: userError } = await supabase
      .from("users")
      .select("id, email, full_name")
      .eq("firebase_uid", firebaseUid)
      .maybeSingle();

    if (userError || !userRow) return json({ error: "User not found" }, 404);

    const { data: feedback, error: feedbackError } = await supabase
      .from("user_feedback")
      .select("id, user_id, email, type, title, locale, wants_email_response, ack_sent_at")
      .eq("id", feedbackId)
      .maybeSingle();

    if (feedbackError || !feedback) return json({ error: "Feedback not found" }, 404);
    if (feedback.user_id !== userRow.id) return json({ error: "Forbidden" }, 403);
    if (!feedback.wants_email_response) return json({ ok: true, skipped: "email_opt_out" });
    if (!feedback.email) return json({ error: "Feedback has no recipient email" }, 400);
    if (feedback.ack_sent_at) return json({ ok: true, skipped: "already_sent" });

    const name = firstName(userRow.full_name, userRow.email);
    const english = isEnglish(feedback.locale);
    const greeting = name ? (english ? `Hi ${name},` : `Hola ${name},`) : english ? "Hi," : "Hola,";
    const subject = english
      ? "We received your HomeSync message"
      : "Recibimos tu mensaje en HomeSync";
    const typeLine = english
      ? feedback.type === "bug"
        ? "Thanks for reporting this issue."
        : "Thanks for sharing this idea."
      : feedback.type === "bug"
        ? "Gracias por reportar este error."
        : "Gracias por compartir esta idea.";
    const replyLine = english
      ? `If we need more context or have an update, we'll reply directly to this email: ${feedback.email}.`
      : `Si necesitamos más contexto o tenemos una novedad, te vamos a responder directo a este correo: ${feedback.email}.`;
    const close = english
      ? "I personally read every message while HomeSync is growing."
      : "Leo personalmente cada mensaje mientras HomeSync está creciendo.";

    const text = `${greeting}\n\n${typeLine}\n\n${replyLine}\n\n"${feedback.title}"\n\n${close}\n\nHomeSync`;
    const html = `
      <div style="font-family:Inter,Arial,sans-serif;line-height:1.6;color:#111827">
        <p>${escapeHtml(greeting)}</p>
        <p>${escapeHtml(typeLine)}</p>
        <p>${escapeHtml(replyLine)}</p>
        <div style="border-left:4px solid #7f0df2;padding-left:16px;margin:20px 0;color:#374151">
          ${escapeHtml(feedback.title)}
        </div>
        <p style="color:#6b7280">${escapeHtml(close)}</p>
        <p>HomeSync</p>
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
        subject,
        text,
        html,
      }),
    });

    const emailData = await emailResponse.json().catch(() => ({}));
    if (!emailResponse.ok) {
      console.error("Resend ack failed", emailResponse.status, emailData);
      return json({ error: "Email provider failed", details: emailData }, 502);
    }

    await supabase
      .from("user_feedback")
      .update({ ack_sent_at: new Date().toISOString() })
      .eq("id", feedback.id);

    return json({ ok: true });
  } catch (error) {
    console.error("send-feedback-ack error", error);
    return json({ error: "Internal error" }, 500);
  }
});
