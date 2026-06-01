import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const jsonHeaders = { "Content-Type": "application/json" };
const PREMIUM_ENTITLEMENT = "premium";

type RevenueCatEvent = {
  id?: string;
  type?: string;
  app_user_id?: string;
  original_app_user_id?: string;
  product_id?: string;
  entitlement_ids?: string[] | null;
  expiration_at_ms?: number | null;
  grace_period_expiration_at_ms?: number | null;
  event_timestamp_ms?: number;
  environment?: string;
};

type RevenueCatPayload = {
  api_version?: string;
  event?: RevenueCatEvent;
};

type SupabaseClient = ReturnType<typeof createClient>;

function getSupabaseSecretKey(): string {
  const secretKeys = Deno.env.get("SUPABASE_SECRET_KEYS");
  if (secretKeys) {
    const parsed = JSON.parse(secretKeys) as Record<string, string>;
    const defaultKey = parsed.default;
    if (defaultKey) return defaultKey;
  }

  return Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
}

function unauthorized() {
  return new Response(JSON.stringify({ error: "Unauthorized" }), {
    status: 401,
    headers: jsonHeaders,
  });
}

function isAuthorized(req: Request): boolean {
  const configuredSecret = Deno.env.get("REVENUECAT_WEBHOOK_SECRET")?.trim();
  if (!configuredSecret) {
    console.error("Missing REVENUECAT_WEBHOOK_SECRET");
    return false;
  }

  const authorization = req.headers.get("authorization")?.trim();
  const webhookSecret = req.headers.get("x-webhook-secret")?.trim();
  return authorization === configuredSecret ||
    authorization === `Bearer ${configuredSecret}` ||
    webhookSecret === configuredSecret;
}

function toIsoFromMs(value?: number | null): string | null {
  if (typeof value !== "number" || !Number.isFinite(value)) return null;
  return new Date(value).toISOString();
}

function isUuid(value: string): boolean {
  return /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i
    .test(value);
}

function hasPremiumEntitlement(event: RevenueCatEvent): boolean {
  const entitlementIds = event.entitlement_ids ?? [];
  return entitlementIds.includes(PREMIUM_ENTITLEMENT) ||
    event.product_id?.startsWith("premium_") === true;
}

function computePremiumState(event: RevenueCatEvent) {
  const type = event.type ?? "";
  const now = Date.now();
  const entitlementMatches = hasPremiumEntitlement(event);
  const expirationMs = type === "BILLING_ISSUE"
    ? event.grace_period_expiration_at_ms ?? event.expiration_at_ms
    : event.expiration_at_ms;
  const expiresInFuture = expirationMs == null || expirationMs > now;
  const inactiveType = type === "EXPIRATION" || type === "TRANSFER";
  const isPremium = entitlementMatches && !inactiveType && expiresInFuture;

  return {
    isPremium,
    expirationAt: isPremium ? toIsoFromMs(expirationMs) : null,
  };
}

function planTierForHouseholdType(householdType: string | null): string {
  return householdType === "couple" ? "couple_premium" : "group_premium";
}

async function recomputeHouseholdPremium(
  supabase: SupabaseClient,
  householdId: string,
) {
  const { data: household, error: householdError } = await supabase
    .from("households")
    .select("id, household_type")
    .eq("id", householdId)
    .maybeSingle();
  if (householdError || !household) {
    throw new Error(`household lookup failed: ${householdError?.message}`);
  }

  const { data: members, error: membersError } = await supabase
    .from("household_members")
    .select("user_id")
    .eq("household_id", householdId);
  if (membersError) {
    throw new Error(`household members lookup failed: ${membersError.message}`);
  }

  const memberIds = (members ?? []).map((row) => row.user_id as string);
  if (memberIds.length === 0) return;

  const { data: states, error: statesError } = await supabase
    .from("revenuecat_customer_state")
    .select("app_user_id, is_premium, expiration_at")
    .in("app_user_id", memberIds);
  if (statesError) {
    throw new Error(`revenuecat state lookup failed: ${statesError.message}`);
  }

  const now = Date.now();
  const activeStates = (states ?? []).filter((state) => {
    if (state.is_premium !== true) return false;
    const expiration = state.expiration_at as string | null;
    return expiration == null || Date.parse(expiration) > now;
  });

  const isPremium = activeStates.length > 0;
  const sortedExpirations = activeStates
    .map((state) => state.expiration_at as string)
    .sort();
  const premiumUntil = activeStates.some((state) => state.expiration_at == null)
    ? null
    : sortedExpirations[sortedExpirations.length - 1] ?? null;
  const ownerUserId = isPremium
    ? (activeStates[0].app_user_id as string)
    : null;

  const { error: householdUpdateError } = await supabase
    .from("households")
    .update({
      plan_tier: isPremium
        ? planTierForHouseholdType(household.household_type as string | null)
        : "free",
      premium_until: premiumUntil,
      subscription_owner_user_id: ownerUserId,
    })
    .eq("id", householdId);
  if (householdUpdateError) {
    throw new Error(
      `household premium update failed: ${householdUpdateError.message}`,
    );
  }

  const { error: usersUpdateError } = await supabase
    .from("users")
    .update({
      is_premium: isPremium,
      premium_until: premiumUntil,
    })
    .in("id", memberIds);
  if (usersUpdateError) {
    throw new Error(`legacy user premium update failed: ${usersUpdateError.message}`);
  }
}

async function recomputeUserHouseholds(
  supabase: SupabaseClient,
  appUserId: string,
) {
  const { data: memberships, error } = await supabase
    .from("household_members")
    .select("household_id")
    .eq("user_id", appUserId);
  if (error) {
    throw new Error(`membership lookup failed: ${error.message}`);
  }

  const householdIds = [...new Set(
    (memberships ?? []).map((row) => row.household_id as string),
  )];
  for (const householdId of householdIds) {
    await recomputeHouseholdPremium(supabase, householdId);
  }
}

serve(async (req) => {
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: jsonHeaders,
    });
  }

  if (!isAuthorized(req)) return unauthorized();

  try {
    const payload = await req.json() as RevenueCatPayload;
    const event = payload.event;
    if (!event?.id || !event.type) {
      return new Response(JSON.stringify({ error: "Invalid RevenueCat event" }), {
        status: 400,
        headers: jsonHeaders,
      });
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      getSupabaseSecretKey(),
    );

    const { error: insertEventError } = await supabase
      .from("revenuecat_webhook_events")
      .insert({
        event_id: event.id,
        event_type: event.type,
        app_user_id: event.app_user_id ?? event.original_app_user_id ?? null,
        product_id: event.product_id ?? null,
        event_timestamp_ms: event.event_timestamp_ms ?? null,
        payload,
      });

    if (insertEventError?.code === "23505") {
      return new Response(JSON.stringify({ ok: true, duplicate: true }), {
        headers: jsonHeaders,
      });
    }
    if (insertEventError) {
      throw new Error(`event insert failed: ${insertEventError.message}`);
    }

    const appUserId = event.app_user_id ?? event.original_app_user_id;
    if (!appUserId || !isUuid(appUserId)) {
      console.warn("RevenueCat event skipped: app_user_id is not users.id", {
        eventId: event.id,
        appUserId,
      });
      return new Response(JSON.stringify({ ok: true, skipped: "unknown_user" }), {
        headers: jsonHeaders,
      });
    }

    const eventTimestampMs = event.event_timestamp_ms ?? Date.now();
    const { data: currentState, error: stateLookupError } = await supabase
      .from("revenuecat_customer_state")
      .select("latest_event_timestamp_ms")
      .eq("app_user_id", appUserId)
      .maybeSingle();
    if (stateLookupError) {
      throw new Error(`state lookup failed: ${stateLookupError.message}`);
    }

    if (
      currentState?.latest_event_timestamp_ms != null &&
      Number(currentState.latest_event_timestamp_ms) > eventTimestampMs
    ) {
      return new Response(JSON.stringify({ ok: true, stale: true }), {
        headers: jsonHeaders,
      });
    }

    const { isPremium, expirationAt } = computePremiumState(event);
    const { error: stateUpsertError } = await supabase
      .from("revenuecat_customer_state")
      .upsert({
        app_user_id: appUserId,
        is_premium: isPremium,
        product_id: event.product_id ?? null,
        entitlement_ids: event.entitlement_ids ?? [],
        expiration_at: expirationAt,
        latest_event_type: event.type,
        latest_event_id: event.id,
        latest_event_timestamp_ms: eventTimestampMs,
        updated_at: new Date().toISOString(),
      }, { onConflict: "app_user_id" });
    if (stateUpsertError) {
      throw new Error(`state upsert failed: ${stateUpsertError.message}`);
    }

    await recomputeUserHouseholds(supabase, appUserId);

    return new Response(JSON.stringify({ ok: true }), {
      headers: jsonHeaders,
    });
  } catch (error) {
    console.error("RevenueCat webhook failed:", error);
    return new Response(JSON.stringify({ error: "Internal error" }), {
      status: 500,
      headers: jsonHeaders,
    });
  }
});
