import { createClient, SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";

// Servidor MCP (Streamable HTTP, sin streaming: cada POST devuelve JSON) para
// que Muse lea el embudo de crecimiento como "custom connector".
//
// Solo devuelve AGREGADOS: conteos por día, modo de hogar o campaña. Nunca
// ids, emails, nombres ni el referrer crudo. Los hogares demo/QA se excluyen.
//
// Auth: GROWTH_MCP_TOKEN, por header `Authorization: Bearer <token>`, `x-api-key` o, para
// clientes que no dejan configurar headers, en la URL (`?token=<token>`).
// verify_jwt=false en config.toml: el gateway no tiene que pedir un JWT.

const PROTOCOL_VERSIONS = ["2025-06-18", "2025-03-26", "2024-11-05"];
const SERVER_INFO = { name: "homesync-growth", version: "1.0.0" };

// Hogares sembrados para capturas y QA; no son usuarios reales.
const EXCLUDED_HOUSEHOLDS = new Set([
  "11111111-1111-4111-8111-111111111111", // Sofi & Mati (demo pareja)
  "22222222-2222-4222-8222-222222222222", // Familia Romero (demo familia)
  "44444444-4444-4444-4444-444444444444", // Testing: Familia
]);
const isTestEmail = (email: string | null) =>
  !!email && (/@homesync\.local$/i.test(email) || /homesync\.demo@/i.test(email));

const json = (body: unknown, status = 200) =>
  new Response(body === null ? null : JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });

function timingSafeEqual(a: string, b: string) {
  const ea = new TextEncoder().encode(a);
  const eb = new TextEncoder().encode(b);
  let diff = ea.length ^ eb.length;
  for (let i = 0; i < Math.max(ea.length, eb.length); i++) {
    diff |= (ea[i] ?? 0) ^ (eb[i] ?? 0);
  }
  return diff === 0;
}

// Limpia lo que un cliente (o una persona copiando) puede agregar alrededor del
// token: esquema ("Bearer", "Token", "Api-Key"), comillas o la línea entera
// `GROWTH_MCP_TOKEN=...` de .env.claude.
function normalizeToken(raw: string) {
  let v = raw.trim().replace(/^["']|["']$/g, "").trim();
  v = v.replace(/^(bearer|token|api-?key)\s+/i, "").trim();
  v = v.replace(/^GROWTH_MCP_TOKEN\s*=\s*/, "").trim();
  return v.replace(/^["']|["']$/g, "");
}

// Devuelve de dónde vino un token válido, o null.
function authorizedSource(req: Request): string | null {
  const expected = Deno.env.get("GROWTH_MCP_TOKEN");
  if (!expected) return null;
  const candidates: Array<[string, string | null]> = [
    ["authorization", req.headers.get("authorization")],
    ["x-api-key", req.headers.get("x-api-key")],
    ["api-key", req.headers.get("api-key")],
    ["apikey", req.headers.get("apikey")],
    ["x-mcp-token", req.headers.get("x-mcp-token")],
    ["query", new URL(req.url).searchParams.get("token") ?? new URL(req.url).searchParams.get("api_key")],
  ];
  for (const [source, raw] of candidates) {
    if (!raw) continue;
    let value = normalizeToken(raw);
    // Basic auth: se acepta el token como usuario o como contraseña.
    if (/^basic\s+/i.test(raw.trim())) {
      try {
        const decoded = atob(raw.trim().replace(/^basic\s+/i, ""));
        value = decoded.split(":").find((part) => part && timingSafeEqual(part, expected)) ?? "";
      } catch {
        value = "";
      }
    }
    if (value && timingSafeEqual(value, expected)) return source;
  }
  return null;
}

// Registro de diagnóstico: nombres de headers, nunca sus valores.
async function logAccess(
  db: SupabaseClient,
  req: Request,
  status: number,
  authSource: string | null,
  rpcMethod: string | null,
) {
  try {
    await db.from("growth_mcp_access_log").insert({
      http_method: req.method,
      rpc_method: rpcMethod,
      status,
      auth_source: authSource,
      header_names: [...req.headers.keys()].filter((h) => !h.startsWith("x-forwarded") && !h.startsWith("cf-")),
      user_agent: req.headers.get("user-agent")?.slice(0, 200) ?? null,
    });
  } catch (e) {
    console.error("growth-mcp access log failed:", e);
  }
}

// ---------- datos ----------

type Row = Record<string, unknown>;

async function fetchAll(
  db: SupabaseClient,
  table: string,
  columns: string,
  sinceColumn?: string,
  since?: string,
): Promise<Row[]> {
  const rows: Row[] = [];
  const page = 1000;
  for (let from = 0; ; from += page) {
    let query = db.from(table).select(columns).range(from, from + page - 1);
    if (sinceColumn && since) query = query.gte(sinceColumn, since);
    const { data, error } = await query;
    if (error) throw new Error(`${table}: ${error.message}`);
    rows.push(...((data ?? []) as Row[]));
    if (!data || data.length < page) return rows;
  }
}

interface Snapshot {
  since: Date;
  users: Row[]; // usuarios reales dados de alta en la ventana
  households: Row[]; // hogares reales creados en la ventana
  memberHousehold: Map<string, string>; // user_id -> household_id
  attribution: Map<string, Row>; // user_id -> utm_*
  activeUsers7d: Map<string, Date>; // user_id -> primera actividad
  activeHouseholds7d: Set<string>;
  firstActivity: Map<string, Date>; // user_id -> primera actividad en la ventana
}

async function loadSnapshot(db: SupabaseClient, days: number): Promise<Snapshot> {
  const since = new Date(Date.now() - days * 86_400_000);
  const sinceIso = since.toISOString();
  const weekAgo = new Date(Date.now() - 7 * 86_400_000);

  const [allUsers, allHouseholds, members, attributions, activities] = await Promise.all([
    fetchAll(db, "users", "id,email,created_at,deleted_at,is_admin", "created_at", sinceIso),
    fetchAll(db, "households", "id,household_type,plan_tier,created_at", "created_at", sinceIso),
    fetchAll(db, "household_members", "user_id,household_id"),
    fetchAll(db, "install_attributions", "user_id,utm_source,utm_medium,utm_campaign,created_at", "created_at", sinceIso),
    fetchAll(db, "household_activities", "user_id,household_id,created_at", "created_at", sinceIso),
  ]);

  const memberHousehold = new Map<string, string>();
  for (const m of members) memberHousehold.set(m.user_id as string, m.household_id as string);

  const users = allUsers.filter((u) =>
    !isTestEmail(u.email as string | null) && !u.is_admin &&
    !EXCLUDED_HOUSEHOLDS.has(memberHousehold.get(u.id as string) ?? "")
  );
  const households = allHouseholds.filter((h) => !EXCLUDED_HOUSEHOLDS.has(h.id as string));

  const attribution = new Map<string, Row>();
  for (const a of attributions) attribution.set(a.user_id as string, a);

  const firstActivity = new Map<string, Date>();
  const activeUsers7d = new Map<string, Date>();
  const activeHouseholds7d = new Set<string>();
  for (const a of activities) {
    const hh = a.household_id as string;
    if (EXCLUDED_HOUSEHOLDS.has(hh)) continue;
    const at = new Date(a.created_at as string);
    const uid = a.user_id as string | null;
    if (uid) {
      const prev = firstActivity.get(uid);
      if (!prev || at < prev) firstActivity.set(uid, at);
      if (at >= weekAgo) activeUsers7d.set(uid, at);
    }
    if (at >= weekAgo) activeHouseholds7d.add(hh);
  }

  return { since, users, households, memberHousehold, attribution, activeUsers7d, activeHouseholds7d, firstActivity };
}

const isPremium = (planTier: unknown) => typeof planTier === "string" && planTier !== "free";
const day = (iso: unknown) => String(iso).slice(0, 10);

// "Activado" = registró al menos una tarea, gasto o compra en sus primeros 7 días.
function isActivated(s: Snapshot, user: Row) {
  const first = s.firstActivity.get(user.id as string);
  if (!first) return false;
  return first.getTime() - new Date(user.created_at as string).getTime() <= 7 * 86_400_000;
}

function householdTypeOf(s: Snapshot, userId: string, byId: Map<string, Row>) {
  const hh = s.memberHousehold.get(userId);
  if (!hh) return "sin_hogar";
  return (byId.get(hh)?.household_type as string | undefined) ?? "hogar_previo";
}

const pct = (n: number, d: number) => (d === 0 ? null : Math.round((n / d) * 1000) / 10);

// ---------- tools ----------

async function growthOverview(db: SupabaseClient, days: number) {
  const s = await loadSnapshot(db, days);
  const byMode: Record<string, number> = {};
  for (const h of s.households) {
    const t = (h.household_type as string) ?? "desconocido";
    byMode[t] = (byMode[t] ?? 0) + 1;
  }
  const activated = s.users.filter((u) => isActivated(s, u)).length;
  const withHousehold = s.users.filter((u) => s.memberHousehold.has(u.id as string)).length;
  return {
    window_days: days,
    since: s.since.toISOString().slice(0, 10),
    signups: s.users.length,
    signups_with_household: withHousehold,
    activated_7d: activated,
    activation_rate_pct: pct(activated, s.users.length),
    new_households: s.households.length,
    new_households_by_mode: byMode,
    new_premium_households: s.households.filter((h) => isPremium(h.plan_tier)).length,
    active_households_last_7d: s.activeHouseholds7d.size,
    active_users_last_7d: s.activeUsers7d.size,
    notes: "Excluye hogares demo/QA. 'activated_7d' = registró una tarea, gasto o compra en sus primeros 7 días. Solo Android tiene atribución de instalación.",
  };
}

async function acquisitionFunnel(db: SupabaseClient, days: number, groupBy: string) {
  const s = await loadSnapshot(db, days);
  const field = groupBy === "campaign" ? "utm_campaign" : groupBy === "medium" ? "utm_medium" : "utm_source";
  const householdById = new Map(s.households.map((h) => [h.id as string, h]));
  // premium por hogar de cualquier antigüedad: pedimos solo los hogares de estos usuarios
  const hhIds = [...new Set(s.users.map((u) => s.memberHousehold.get(u.id as string)).filter(Boolean))] as string[];
  const premiumHouseholds = new Set<string>();
  for (let i = 0; i < hhIds.length; i += 200) {
    const { data, error } = await db.from("households").select("id,plan_tier,household_type").in("id", hhIds.slice(i, i + 200));
    if (error) throw new Error(`households: ${error.message}`);
    for (const h of data ?? []) {
      if (isPremium(h.plan_tier)) premiumHouseholds.add(h.id);
      if (!householdById.has(h.id)) householdById.set(h.id, h);
    }
  }

  const groups = new Map<string, { signups: number; with_household: number; activated_7d: number; premium: number; modes: Record<string, number> }>();
  for (const u of s.users) {
    const a = s.attribution.get(u.id as string);
    const key = (a?.[field] as string | undefined)?.trim() || (a ? "(vacío)" : "(sin atribución)");
    const g = groups.get(key) ?? { signups: 0, with_household: 0, activated_7d: 0, premium: 0, modes: {} };
    g.signups++;
    const hh = s.memberHousehold.get(u.id as string);
    if (hh) {
      g.with_household++;
      const mode = householdTypeOf(s, u.id as string, householdById);
      g.modes[mode] = (g.modes[mode] ?? 0) + 1;
      if (premiumHouseholds.has(hh)) g.premium++;
    }
    if (isActivated(s, u)) g.activated_7d++;
    groups.set(key, g);
  }

  const rows = [...groups.entries()]
    .map(([key, g]) => ({ [field]: key, ...g, activation_rate_pct: pct(g.activated_7d, g.signups), premium_rate_pct: pct(g.premium, g.signups) }))
    .sort((a, b) => (b.signups as number) - (a.signups as number));
  return {
    window_days: days,
    group_by: field,
    rows,
    notes: "Una fila por valor de utm. '(sin atribución)' = iOS, versiones viejas o instalaciones sin referrer. 'premium' = su hogar tiene plan pago hoy.",
  };
}

async function dailySignups(db: SupabaseClient, days: number) {
  const s = await loadSnapshot(db, days);
  const series = new Map<string, { signups: number; new_households: number; activated_7d: number }>();
  for (let d = new Date(s.since); d <= new Date(); d = new Date(d.getTime() + 86_400_000)) {
    series.set(d.toISOString().slice(0, 10), { signups: 0, new_households: 0, activated_7d: 0 });
  }
  for (const u of s.users) {
    const row = series.get(day(u.created_at));
    if (!row) continue;
    row.signups++;
    if (isActivated(s, u)) row.activated_7d++;
  }
  for (const h of s.households) {
    const row = series.get(day(h.created_at));
    if (row) row.new_households++;
  }
  return { window_days: days, timezone: "UTC", days: [...series.entries()].map(([date, v]) => ({ date, ...v })) };
}

// Kit de redes: manifest público que arma tmp/marketing/publish_kit.py.
const CONTENT_KIT_URL =
  `${Deno.env.get("SUPABASE_URL")}/storage/v1/object/public/marketing/content_kit.json`;

async function contentKit(args: Record<string, unknown>) {
  // `?v=` saltea la caché del CDN de Storage: el manifest se resube al regenerar el kit.
  const res = await fetch(`${CONTENT_KIT_URL}?v=${Date.now()}`);
  if (!res.ok) throw new Error(`content_kit.json: HTTP ${res.status}`);
  const kit = await res.json();
  const wanted = (field: string) => (args[field] ? String(args[field]) : null);
  const mode = wanted("mode"), type = wanted("type"), network = wanted("network");
  const day = args.calendar_day != null ? Number(args.calendar_day) : null;
  const items = (kit.items as Row[]).filter((it) =>
    (!mode || it.mode === mode) &&
    (!type || it.type === type) &&
    (!network || (it.networks as string[]).includes(network)) &&
    (day == null || it.calendar_day === day)
  );
  return { generated_at: kit.generated_at, rules: kit.rules, bio_links: kit.bio_links, count: items.length, items };
}

const daysArg = { type: "integer", minimum: 1, maximum: 365, default: 30, description: "Ventana en días hacia atrás desde hoy." };
const TOOLS = [
  {
    name: "get_growth_overview",
    description: "Resumen del crecimiento de HomeSync en la ventana: altas, activación a 7 días, hogares nuevos por modo (couple/family/friends/solo), hogares premium nuevos y hogares activos en la última semana. Solo agregados, sin datos personales.",
    inputSchema: { type: "object", properties: { days: daysArg } },
    annotations: { readOnlyHint: true },
  },
  {
    name: "get_acquisition_funnel",
    description: "Embudo por origen de instalación (utm del link de Play): altas, cuántos armaron hogar, en qué modo, cuántos se activaron en 7 días y cuántos son premium. Sirve para comparar campañas y posteos.",
    inputSchema: {
      type: "object",
      properties: {
        days: daysArg,
        group_by: { type: "string", enum: ["source", "campaign", "medium"], default: "source", description: "Agrupar por utm_source, utm_campaign o utm_medium." },
      },
    },
    annotations: { readOnlyHint: true },
  },
  {
    name: "get_content_kit",
    description: "Contenido listo para publicar en Instagram y TikTok: carruseles, reels, posts e historias de HomeSync, cada uno con URLs públicas de las imágenes o el video, texto en español rioplatense, hashtags, red sugerida, día del calendario de lanzamiento y el link de Google Play con UTM. Publicá solo piezas de este kit y respetá `rules`.",
    inputSchema: {
      type: "object",
      properties: {
        mode: { type: "string", enum: ["pareja", "familia", "solo", "general"], description: "Filtrar por modo de hogar." },
        type: { type: "string", enum: ["carousel", "reel", "post", "story"], description: "Filtrar por formato." },
        network: { type: "string", enum: ["instagram", "tiktok"], description: "Filtrar por red." },
        calendar_day: { type: "integer", minimum: 1, description: "Día del calendario de lanzamiento (1 = primer día)." },
      },
    },
    annotations: { readOnlyHint: true },
  },
  {
    name: "get_daily_signups",
    description: "Serie diaria (UTC) de altas, hogares nuevos y activaciones, para ver el efecto de un posteo o campaña en el tiempo.",
    inputSchema: { type: "object", properties: { days: daysArg } },
    annotations: { readOnlyHint: true },
  },
];

async function callTool(db: SupabaseClient, name: string, args: Record<string, unknown>) {
  const days = Math.min(365, Math.max(1, Number(args.days ?? 30) || 30));
  switch (name) {
    case "get_growth_overview":
      return await growthOverview(db, days);
    case "get_acquisition_funnel":
      return await acquisitionFunnel(db, days, String(args.group_by ?? "source"));
    case "get_daily_signups":
      return await dailySignups(db, days);
    case "get_content_kit":
      return await contentKit(args);
    default:
      return undefined;
  }
}

// ---------- JSON-RPC ----------

interface RpcRequest {
  jsonrpc: "2.0";
  id?: string | number | null;
  method: string;
  params?: Record<string, unknown>;
}

async function handle(db: SupabaseClient, msg: RpcRequest) {
  const reply = (result: unknown) => ({ jsonrpc: "2.0", id: msg.id, result });
  const fail = (code: number, message: string) => ({ jsonrpc: "2.0", id: msg.id ?? null, error: { code, message } });
  if (msg.id === undefined) return null; // notificación: no lleva respuesta

  switch (msg.method) {
    case "initialize": {
      const asked = String(msg.params?.protocolVersion ?? "");
      return reply({
        protocolVersion: PROTOCOL_VERSIONS.includes(asked) ? asked : PROTOCOL_VERSIONS[0],
        capabilities: { tools: { listChanged: false } },
        serverInfo: SERVER_INFO,
        instructions: "HomeSync (app de hogar: tareas, gastos y compras compartidas; modos pareja/familia/amigos/solo). get_content_kit da el contenido listo para publicar; las otras herramientas, métricas agregadas para medir qué posteos y campañas traen hogares que se quedan.",
      });
    }
    case "ping":
      return reply({});
    case "tools/list":
      return reply({ tools: TOOLS });
    case "tools/call": {
      const name = String(msg.params?.name ?? "");
      const args = (msg.params?.arguments ?? {}) as Record<string, unknown>;
      try {
        const result = await callTool(db, name, args);
        if (result === undefined) return fail(-32602, `Unknown tool: ${name}`);
        return reply({
          content: [{ type: "text", text: JSON.stringify(result, null, 2) }],
          structuredContent: result,
        });
      } catch (e) {
        console.error(`growth-mcp ${name} failed:`, e);
        return reply({ content: [{ type: "text", text: `Error: ${(e as Error).message}` }], isError: true });
      }
    }
    default:
      return fail(-32601, `Method not found: ${msg.method}`);
  }
}

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
  "Access-Control-Allow-Headers":
    "authorization, x-api-key, api-key, x-mcp-token, content-type, accept, mcp-session-id, mcp-protocol-version",
};

Deno.serve(async (req: Request) => {
  const db = createClient(Deno.env.get("SUPABASE_URL") ?? "", Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "", {
    auth: { persistSession: false },
  });

  if (req.method === "OPTIONS") return new Response(null, { status: 204, headers: CORS });
  if (req.method !== "POST") {
    // Sin stream SSE del lado del servidor: el cliente usa solo POST.
    await logAccess(db, req, 405, authorizedSource(req), null);
    return new Response(null, { status: 405, headers: { Allow: "POST", ...CORS } });
  }

  let body: RpcRequest | RpcRequest[];
  try {
    body = await req.json();
  } catch {
    await logAccess(db, req, 400, authorizedSource(req), null);
    return json({ jsonrpc: "2.0", id: null, error: { code: -32700, message: "Parse error" } }, 400);
  }
  const rpcMethod = Array.isArray(body) ? body.map((m) => m.method).join(",") : body?.method ?? null;

  const source = authorizedSource(req);
  if (!source) {
    await logAccess(db, req, 401, null, rpcMethod);
    return new Response(JSON.stringify({ error: "Unauthorized" }), {
      status: 401,
      headers: { "Content-Type": "application/json", "WWW-Authenticate": 'Bearer realm="homesync-growth"', ...CORS },
    });
  }
  await logAccess(db, req, 200, source, rpcMethod);

  if (Array.isArray(body)) {
    const replies = (await Promise.all(body.map((m) => handle(db, m)))).filter(Boolean);
    return replies.length ? json(replies) : new Response(null, { status: 202 });
  }
  const reply = await handle(db, body);
  return reply ? json(reply) : new Response(null, { status: 202 });
});
