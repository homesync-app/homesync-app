import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { createRemoteJWKSet, jwtVerify } from "https://esm.sh/jose@5";
import { STYLE_REFERENCE_IMAGES_BASE64 } from "./style_refs.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const FIREBASE_PROJECT_ID = "homesync-prod-r7-123";
const OPENAI_IMAGES_URL = "https://api.openai.com/v1/images/edits";
const BUCKET = "custom-avatars";
const MAX_BASE64_LENGTH = 7_000_000;
const MONTHLY_LIMIT = 1;
const SAVED_GENERATED_AVATAR_LIMIT = 6;
const DEFAULT_IMAGE_MODEL = "gpt-image-1.5";
const DEFAULT_IMAGE_QUALITY = "high";

interface FirebaseJWTPayload {
  sub: string;
  email?: string;
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

async function pruneOldGeneratedAvatars(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  activeAvatarUrl: string | null,
) {
  const { data: generatedRows, error } = await supabase
    .from("custom_avatar_generations")
    .select("id, avatar_url, created_at")
    .eq("user_id", userId)
    .like("avatar_url", "%/storage/v1/object/public/custom-avatars/%")
    .order("created_at", { ascending: false });

  if (error || !generatedRows) {
    console.error("Generated avatar prune lookup failed:", error);
    return;
  }

  const rowsToDelete = generatedRows
    .slice(SAVED_GENERATED_AVATAR_LIMIT)
    .filter((row) => row.avatar_url !== activeAvatarUrl);

  if (rowsToDelete.length === 0) return;

  const objectPaths = rowsToDelete
    .map((row) => storageObjectPathFromPublicUrl(row.avatar_url))
    .filter((path): path is string => path !== null);

  if (objectPaths.length > 0) {
    const { error: removeError } = await supabase.storage
      .from(BUCKET)
      .remove(objectPaths);
    if (removeError) {
      console.error("Old generated avatar storage prune failed:", removeError);
    }
  }

  const rowIds = rowsToDelete.map((row) => row.id);
  const { error: deleteError } = await supabase
    .from("custom_avatar_generations")
    .delete()
    .in("id", rowIds);
  if (deleteError) {
    console.error("Old generated avatar row prune failed:", deleteError);
  }
}

const prompt = `The first image is a photo. The other images are official characters from the HomeSync avatar set, included ONLY as art-style samples: hand-painted 2D storybook illustration with soft painterly shading, warm cream/peach/honey palette, large friendly eyes with highlights, gently simplified rounded features, rosy cheeks, and a clean cut-out edge where the painted silhouette meets fully transparent alpha directly, with NO outline, NO border and NO halo around it.

Redraw the subjects of the photo as the next character in that exact same set. Match the style-sample images precisely: same line quality, same soft painterly shading, same warm palette, same level of facial simplification. IMPORTANT: do NOT draw any white sticker border, die-cut outline, stroke or halo around the character — even if some style-sample images appear to show one, ignore it. The character's painted edge must meet transparent alpha directly.

The style-sample characters are OTHER people from the set. Never copy them or any part of them into the result: not their faces, hair, clothing, pets, or props. Everything depicted in the new avatar must come from the photo only.

Draw only the clearly visible living subjects from the photo, nothing more: one person means exactly one person and zero animals; one person with one pet means that person with that pet; two people means two people. Never invent a partner, child, pet, animal, prop, costume, plant, furniture, or scene that is not in the photo.

Style fidelity to the reference set matters more than portrait accuracy. Keep only the strongest identity cues from the photo: approximate age or species, hair or fur color and shape, skin tone, glasses or facial hair if visible, clothing color, and how the subjects hold each other or a pet. Ignore the photo's lighting, lens distortion, background, clutter, and detailed facial anatomy.

Composition, exactly like the reference images: bust framing with full head, hair, ears and shoulders visible (plus fur and paws for pets), the character drawn LARGE so it fills nearly the entire square canvas edge to edge, leaving only a thin transparent margin around the character. Outside the character's painted silhouette there is nothing at all, only transparent alpha.

Avoid: photorealism, realistic portrait anatomy, 3D render look, anime, memoji/emoji style, flat vector art, toothy smiles, glam or beauty-ad styling, heavy shadows, busy scenes, and any white sticker border, die-cut outline, stroke or halo around the silhouette.`;

function decodeBase64(value: string): Uint8Array {
  const binary = atob(value);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i);
  }
  return bytes;
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

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  let releaseUsageReservation = async () => {};

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

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
    );

    const { data: userRow, error: userError } = await supabase
      .from("users")
      .select("id, is_premium, premium_until, avatar_url")
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

    const { data: memberRows } = await supabase
      .from("household_members")
      .select("household_id")
      .eq("user_id", userRow.id);
    const householdIds = (memberRows ?? []).map(
      (row) => row.household_id as string,
    );

    // Mismo "premium efectivo" que public.get_effective_premium_status():
    // premium propio vigente, o cualquiera de sus hogares con plan pago vigente.
    const now = Date.now();
    const stillValid = (until: string | null) =>
      until == null || Date.parse(until) > now;
    let isPremium = userRow.is_premium === true &&
      stillValid(userRow.premium_until as string | null);

    if (!isPremium && householdIds.length > 0) {
      const { data: households } = await supabase
        .from("households")
        .select("plan_tier, premium_until")
        .in("id", householdIds);
      isPremium = (households ?? []).some(
        (h) =>
          h.plan_tier !== "free" &&
          stillValid(h.premium_until as string | null),
      );
    }

    if (!isPremium) {
      return new Response(JSON.stringify({ error: "premium_required" }), {
        status: 403,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const memberRow = householdIds.length > 0
      ? { household_id: householdIds[0] }
      : null;

    const monthStart = new Date();
    monthStart.setUTCDate(1);
    monthStart.setUTCHours(0, 0, 0, 0);
    const generationMonth = monthStart.toISOString().slice(0, 10);
    let usageReserved = false;

    releaseUsageReservation = async () => {
      if (!usageReserved) return;
      const { error } = await supabase
        .from("custom_avatar_monthly_usage")
        .delete()
        .eq("user_id", userRow.id)
        .eq("generation_month", generationMonth);
      if (error) {
        console.error("Failed to release avatar usage reservation:", error);
      }
      usageReserved = false;
    };

    // Kill-switch temporal para QA: con el secret en "true" no se reserva
    // cupo mensual (y por ende tampoco se bloquea por 23505).
    const monthlyLimitDisabled =
      (Deno.env.get("AVATAR_MONTHLY_LIMIT_DISABLED") ?? "")
        .trim().toLowerCase() === "true";

    const { error: reserveError } = monthlyLimitDisabled
      ? { error: null }
      : await supabase
        .from("custom_avatar_monthly_usage")
        .insert({
          user_id: userRow.id,
          generation_month: generationMonth,
        });

    if (reserveError?.code === "23505") {
      return new Response(
        JSON.stringify({
          error: "monthly_limit_reached",
          limit: MONTHLY_LIMIT,
        }),
        {
          status: 429,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }
    if (reserveError) {
      console.error("Avatar usage reservation failed:", reserveError);
      return new Response(JSON.stringify({ error: "usage_check_failed" }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }
    usageReserved = !monthlyLimitDisabled;

    const body = await req.json();
    const { imageBase64, mimeType = "image/webp" } = body as {
      imageBase64?: string;
      mimeType?: string;
    };

    if (!imageBase64) {
      await releaseUsageReservation();
      return new Response(JSON.stringify({ error: "imageBase64_required" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    if (imageBase64.length > MAX_BASE64_LENGTH) {
      await releaseUsageReservation();
      return new Response(JSON.stringify({ error: "image_too_large" }), {
        status: 413,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const openaiKey = Deno.env.get("OPENAI_API_KEY");
    if (!openaiKey) {
      await releaseUsageReservation();
      return new Response(JSON.stringify({ error: "server_not_configured" }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const inputBytes = decodeBase64(imageBase64);
    const configuredImageModel = Deno.env.get("OPENAI_IMAGE_MODEL")?.trim();
    const imageModel = configuredImageModel &&
        configuredImageModel !== "gpt-image-1-mini" &&
        configuredImageModel !== "gpt-image-1"
      ? configuredImageModel
      : DEFAULT_IMAGE_MODEL;
    const configuredImageQuality = Deno.env.get("OPENAI_IMAGE_QUALITY")?.trim();
    const imageQuality = configuredImageQuality &&
        configuredImageQuality !== "medium"
      ? configuredImageQuality
      : DEFAULT_IMAGE_QUALITY;
    console.log(
      "Generating custom avatar with model:",
      imageModel,
      "quality:",
      imageQuality,
    );
    const form = new FormData();
    form.append("model", imageModel);
    form.append("prompt", prompt);
    form.append("size", "1024x1024");
    form.append("quality", imageQuality);
    form.append("background", "transparent");
    form.append("output_format", "png");
    form.append(
      "image[]",
      new Blob([inputBytes], { type: mimeType }),
      "source.webp",
    );
    STYLE_REFERENCE_IMAGES_BASE64.forEach((refBase64, index) => {
      form.append(
        "image[]",
        new Blob([decodeBase64(refBase64)], { type: "image/png" }),
        `style_ref_${index + 1}.png`,
      );
    });

    const imageResponse = await fetch(OPENAI_IMAGES_URL, {
      method: "POST",
      headers: { Authorization: `Bearer ${openaiKey}` },
      body: form,
    });

    if (!imageResponse.ok) {
      const detail = await imageResponse.text();
      let message = "OpenAI no pudo generar el avatar.";
      try {
        const parsed = JSON.parse(detail);
        message = parsed?.error?.message ?? message;
      } catch (_) {
        if (detail.trim().length > 0) {
          message = detail.slice(0, 240);
        }
      }
      console.error("OpenAI image generation failed:", detail.slice(0, 500));
      await releaseUsageReservation();
      return new Response(
        JSON.stringify({
          error: "generation_failed",
          message: "No se pudo generar el avatar. Probá con otra foto.",
        }),
        {
          status: 502,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const imageJson = await imageResponse.json();
    const outputBase64 = imageJson?.data?.[0]?.b64_json as string | undefined;
    if (!outputBase64) {
      await releaseUsageReservation();
      return new Response(JSON.stringify({ error: "empty_generation" }), {
        status: 502,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const outputBytes = decodeBase64(outputBase64);
    console.log(
      "Generated avatar size KB:",
      Math.round(outputBytes.byteLength / 1024),
    );
    const objectPath = `${userRow.id}/${crypto.randomUUID()}.png`;

    const { error: uploadError } = await supabase.storage
      .from(BUCKET)
      .upload(objectPath, outputBytes, {
        contentType: "image/png",
        upsert: false,
      });

    if (uploadError) {
      console.error("Custom avatar upload failed:", uploadError);
      await releaseUsageReservation();
      return new Response(
        JSON.stringify({
          error: "upload_failed",
        }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const { data: publicUrlData } = supabase.storage
      .from(BUCKET)
      .getPublicUrl(objectPath);

    const avatarUrl = publicUrlData.publicUrl;

    const { error: generationInsertError } = await supabase.from("custom_avatar_generations").insert({
      user_id: userRow.id,
      household_id: memberRow?.household_id ?? null,
      avatar_url: avatarUrl,
      source_image_count: 1,
    });

    if (generationInsertError) {
      console.error("Custom avatar generation insert failed:", generationInsertError);
      await releaseUsageReservation();
      return new Response(JSON.stringify({ error: "usage_record_failed" }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    await pruneOldGeneratedAvatars(
      supabase,
      userRow.id,
      userRow.avatar_url ?? null,
    );

    return new Response(
      JSON.stringify({
        avatarUrl,
        remaining: 0,
        savedLimit: SAVED_GENERATED_AVATAR_LIMIT,
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (error) {
    console.error("generate-custom-avatar error:", error);
    await releaseUsageReservation();
    return new Response(
      JSON.stringify({ error: "internal_error" }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }
});
