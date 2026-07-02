import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { createRemoteJWKSet, jwtVerify } from "https://esm.sh/jose@5";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const FIREBASE_PROJECT_ID = "homesync-prod-r7-123";
const BUCKET = "custom-avatars";

interface FirebaseJWTPayload {
  sub: string;
  aud: string;
  iss: string;
}

function storageObjectPathFromPublicUrl(url: string): string | null {
  const marker = `/storage/v1/object/public/${BUCKET}/`;
  const markerIndex = url.indexOf(marker);
  if (markerIndex === -1) return null;

  const rawPath = url.slice(markerIndex + marker.length);
  if (!rawPath.trim()) return null;
  return decodeURIComponent(rawPath);
}

async function verifyFirebaseUser(token: string): Promise<string | null> {
  try {
    const jwks = createRemoteJWKSet(
      new URL(
        "https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com",
      ),
    );

    const { payload } = await jwtVerify(token, jwks, {
      issuer: `https://securetoken.google.com/${FIREBASE_PROJECT_ID}`,
      audience: FIREBASE_PROJECT_ID,
    });

    const firebasePayload = payload as FirebaseJWTPayload;
    return firebasePayload.sub || null;
  } catch (error) {
    console.error("Firebase JWT verification failed:", error);
    return null;
  }
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const firebaseUid = await verifyFirebaseUser(
      authHeader.replace("Bearer ", ""),
    );
    if (!firebaseUid) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const body = await req.json();
    const avatarId = (body as { avatarId?: string }).avatarId?.trim();
    if (!avatarId) {
      return new Response(JSON.stringify({ error: "avatarId_required" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
    );

    const { data: userRow, error: userError } = await supabase
      .from("users")
      .select("id, avatar_url")
      .eq("firebase_uid", firebaseUid)
      .limit(1)
      .single();

    if (userError || !userRow) {
      console.error("User lookup failed:", userError);
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const { data: avatarRow, error: avatarError } = await supabase
      .from("custom_avatar_generations")
      .select("id, avatar_url")
      .eq("id", avatarId)
      .eq("user_id", userRow.id)
      .limit(1)
      .single();

    if (avatarError || !avatarRow) {
      return new Response(JSON.stringify({ error: "not_found" }), {
        status: 404,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const objectPath = storageObjectPathFromPublicUrl(avatarRow.avatar_url);
    const wasActiveAvatar = userRow.avatar_url === avatarRow.avatar_url;
    if (wasActiveAvatar) {
      const { error: profileError } = await supabase
        .from("users")
        .update({ avatar_url: "\u{1F431}", updated_at: new Date().toISOString() })
        .eq("id", userRow.id);
      if (profileError) {
        console.error("Custom avatar profile fallback failed:", profileError);
        return new Response(JSON.stringify({ error: "profile_update_failed" }), {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }
    }

    if (objectPath) {
      const { error: removeError } = await supabase.storage
        .from(BUCKET)
        .remove([objectPath]);
      if (removeError) {
        console.error("Custom avatar storage delete failed:", removeError);
        return new Response(JSON.stringify({ error: "storage_delete_failed" }), {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }
    }

    const { error: deleteError } = await supabase
      .from("custom_avatar_generations")
      .delete()
      .eq("id", avatarId)
      .eq("user_id", userRow.id);

    if (deleteError) {
      console.error("Custom avatar row delete failed:", deleteError);
      return new Response(JSON.stringify({ error: "delete_failed" }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    return new Response(JSON.stringify({ ok: true }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error("delete-custom-avatar error:", error);
    return new Response(JSON.stringify({ error: "internal_error" }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
