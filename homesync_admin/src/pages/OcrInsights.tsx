import { useCallback, useEffect, useMemo, useState } from 'react';
import {
  ScanLine,
  Copy,
  CheckCircle2,
  TrendingUp,
  AlertTriangle,
  Filter,
  ShoppingBag,
  Sparkles,
  RefreshCcw,
  FileText,
  ChevronDown,
  ChevronUp,
} from 'lucide-react';
import { supabase } from '../lib/supabase';
import { EmptyState, ErrorState, LoadingState } from '../components/PageState';

// ─── Tipos ──────────────────────────────────────────────────────────────────

interface UnmatchedRow {
  raw_text: string;
  occurrences: number;
  distinct_users: number;
  last_seen: string;
}

interface ManualRow {
  normalized_name: string;
  times_added: number;
  households_using: number;
  last_added: string;
  variations: string[];
}

interface DailyStats {
  day: string;
  total_scans: number;
  avg_confidence: number | null;
  avg_matched: number | null;
  avg_to_add: number | null;
  avg_unmatched: number | null;
  avg_dropped: number | null;
  confirmed: number;
  cancelled: number;
  confirm_rate_pct: number | null;
}

interface MatcherResult {
  matched?: string[];
  to_add?: string[];
  unrecognized?: string[];
  dropped?: string[];
}

interface ScanLog {
  id: string;
  created_at: string;
  ai_merchant: string | null;
  ai_confidence: number | null;
  ai_raw_items: string[];
  matcher_result: MatcherResult | null;
  user_action: string | null;
  tier: string | null;
}

type Tab = 'scans' | 'unmatched' | 'dropped' | 'manual' | 'stats';

// ─── Helpers ────────────────────────────────────────────────────────────────

const fmtDate = (iso: string) => {
  try {
    return new Date(iso).toLocaleDateString('es-AR', {
      day: '2-digit',
      month: 'short',
    });
  } catch {
    return iso;
  }
};

const buildPromptUnmatched = (rows: UnmatchedRow[], n: number) => {
  const top = rows.slice(0, n);
  const list = top
    .map((r, i) => `${i + 1}. "${r.raw_text}" (visto ${r.occurrences}x)`)
    .join('\n');
  return `Soy desarrollador de una app de listas de compras argentina. Te paso una lista de productos que la IA detectó en tickets reales pero mi catálogo no reconoció. Para cada uno necesito:

1. Nombre canónico corto en español rioplatense (ej: "Yogur bebible", no "yoghurt")
2. Emoji apropiado (uno solo, nativo Unicode)
3. Categoría sugerida entre: fruits, meat, dairy, bakery, cleaning, drinks, snacks, pharmacy, pets, frozen, pantry

Devolvelo en formato JSON:
[
  {"name": "...", "emoji": "...", "category": "..."},
  ...
]

Productos:
${list}`;
};

const buildPromptManual = (rows: ManualRow[], n: number) => {
  const top = rows.slice(0, n);
  const list = top
    .map(
      (r, i) =>
        `${i + 1}. "${r.normalized_name}" (agregado ${r.times_added}x por ${r.households_using} hogares)`,
    )
    .join('\n');
  return `Soy desarrollador de una app de listas de compras argentina. Estos productos fueron tipeados manualmente por usuarios y todavía no tienen icono en mi catálogo. Para cada uno necesito:

1. Nombre canónico corto en español rioplatense
2. Emoji apropiado (uno solo, nativo Unicode)
3. Categoría sugerida entre: fruits, meat, dairy, bakery, cleaning, drinks, snacks, pharmacy, pets, frozen, pantry

Devolvelo en formato JSON:
[
  {"name": "...", "emoji": "...", "category": "..."},
  ...
]

Productos:
${list}`;
};

// ─── Componente ─────────────────────────────────────────────────────────────

export const OcrInsights = () => {
  const [tab, setTab] = useState<Tab>('scans');
  const [scans, setScans] = useState<ScanLog[] | null>(null);
  const [unmatched, setUnmatched] = useState<UnmatchedRow[] | null>(null);
  const [dropped, setDropped] = useState<UnmatchedRow[] | null>(null);
  const [manual, setManual] = useState<ManualRow[] | null>(null);
  const [stats, setStats] = useState<DailyStats[] | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [refreshing, setRefreshing] = useState(false);
  const [copyCount, setCopyCount] = useState(20);
  const [copied, setCopied] = useState(false);

  const loadAll = useCallback(async () => {
    setRefreshing(true);
    setError(null);
    try {
      const [sc, u, d, m, s] = await Promise.all([
        supabase
          .from('ocr_scan_logs')
          .select(
            'id, created_at, ai_merchant, ai_confidence, ai_raw_items, matcher_result, user_action, tier',
          )
          .order('created_at', { ascending: false })
          .limit(50),
        supabase.from('v_ocr_unmatched_items').select('*').limit(200),
        supabase.from('v_ocr_dropped_items').select('*').limit(200),
        supabase.from('v_manual_items_no_icon').select('*').limit(200),
        supabase.from('v_ocr_daily_stats').select('*').limit(30),
      ]);

      if (sc.error) throw sc.error;
      if (u.error) throw u.error;
      if (d.error) throw d.error;
      if (m.error) throw m.error;
      if (s.error) throw s.error;

      setScans((sc.data ?? []) as ScanLog[]);
      setUnmatched((u.data ?? []) as UnmatchedRow[]);
      setDropped((d.data ?? []) as UnmatchedRow[]);
      setManual((m.data ?? []) as ManualRow[]);
      setStats((s.data ?? []) as DailyStats[]);
    } catch (e: unknown) {
      const msg = e instanceof Error ? e.message : 'Error desconocido';
      setError(msg);
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  }, []);

  useEffect(() => {
    loadAll();
  }, [loadAll]);

  const handleCopy = useCallback(async () => {
    let prompt = '';
    if (tab === 'unmatched' && unmatched) {
      prompt = buildPromptUnmatched(unmatched, copyCount);
    } else if (tab === 'dropped' && dropped) {
      // Para dropped el prompt es distinto: pedimos revisar si el descarte
      // fue correcto.
      const top = dropped.slice(0, copyCount);
      prompt = `Soy desarrollador. Estos strings fueron descartados por mi quality gate de OCR (no se ofrecen al usuario como productos). Para cada uno decime si es realmente basura o si es un producto válido que estoy descartando por error. En caso de ser válido, sugerí qué regla cambiar.

${top.map((r, i) => `${i + 1}. "${r.raw_text}" (${r.occurrences}x)`).join('\n')}`;
    } else if (tab === 'manual' && manual) {
      prompt = buildPromptManual(manual, copyCount);
    }
    try {
      await navigator.clipboard.writeText(prompt);
      setCopied(true);
      setTimeout(() => setCopied(false), 1800);
    } catch {
      setError('No se pudo copiar al portapapeles');
    }
  }, [tab, copyCount, unmatched, dropped, manual]);

  const summary = useMemo(() => {
    const last7 = (stats ?? []).slice(0, 7);
    const totalScans = last7.reduce((acc, r) => acc + r.total_scans, 0);
    const totalConfirmed = last7.reduce((acc, r) => acc + r.confirmed, 0);
    const confirmRate =
      totalScans > 0
        ? ((totalConfirmed / totalScans) * 100).toFixed(1)
        : '—';
    const avgConf =
      last7.length > 0
        ? (
            last7.reduce((a, r) => a + (r.avg_confidence ?? 0), 0) /
            last7.length
          ).toFixed(2)
        : '—';
    return { totalScans, confirmRate, avgConf };
  }, [stats]);

  if (loading) {
    return (
      <div className="space-y-6 animate-in fade-in duration-500">
        <Header />
        <LoadingState title="Cargando insights de OCR..." />
      </div>
    );
  }

  if (error) {
    return (
      <div className="space-y-6 animate-in fade-in duration-500">
        <Header />
        <ErrorState title="Error cargando datos" description={error} />
      </div>
    );
  }

  return (
    <div className="space-y-6 animate-in fade-in duration-500">
      <Header onRefresh={loadAll} refreshing={refreshing} />

      {/* Stats summary */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <StatCard
          icon={<ScanLine className="w-5 h-5" />}
          label="Scans (7d)"
          value={summary.totalScans.toString()}
          tone="indigo"
        />
        <StatCard
          icon={<CheckCircle2 className="w-5 h-5" />}
          label="Tasa de confirmación (7d)"
          value={`${summary.confirmRate}%`}
          tone="emerald"
        />
        <StatCard
          icon={<TrendingUp className="w-5 h-5" />}
          label="Confianza promedio IA (7d)"
          value={summary.avgConf}
          tone="violet"
        />
      </div>

      {/* Tabs */}
      <div className="glass-dark rounded-3xl border border-white/10 overflow-hidden">
        <div className="flex flex-wrap gap-1 p-2 border-b border-white/5">
          <TabButton
            active={tab === 'scans'}
            onClick={() => setTab('scans')}
            icon={<FileText className="w-4 h-4" />}
            label="Scans recientes"
            count={scans?.length}
          />
          <TabButton
            active={tab === 'unmatched'}
            onClick={() => setTab('unmatched')}
            icon={<Sparkles className="w-4 h-4" />}
            label="Sin catálogo"
            count={unmatched?.length}
          />
          <TabButton
            active={tab === 'dropped'}
            onClick={() => setTab('dropped')}
            icon={<AlertTriangle className="w-4 h-4" />}
            label="Descartados"
            count={dropped?.length}
          />
          <TabButton
            active={tab === 'manual'}
            onClick={() => setTab('manual')}
            icon={<ShoppingBag className="w-4 h-4" />}
            label="Manuales sin icono"
            count={manual?.length}
          />
          <TabButton
            active={tab === 'stats'}
            onClick={() => setTab('stats')}
            icon={<TrendingUp className="w-4 h-4" />}
            label="Métricas diarias"
            count={stats?.length}
          />
        </div>

        {/* Copy bar (no aplica a stats ni scans detallados) */}
        {tab !== 'stats' && tab !== 'scans' && (
          <div className="flex flex-wrap items-center gap-3 px-5 py-3 bg-white/5 border-b border-white/5">
            <Filter className="w-4 h-4 text-gray-400" />
            <span className="text-xs text-gray-400">Copiar top</span>
            <div className="flex gap-1">
              {[10, 20, 50, 100].map((n) => (
                <button
                  key={n}
                  onClick={() => setCopyCount(n)}
                  className={`px-2.5 py-1 text-xs rounded-lg transition-colors ${
                    copyCount === n
                      ? 'bg-primary text-white'
                      : 'bg-white/10 text-gray-300 hover:bg-white/15'
                  }`}
                >
                  {n}
                </button>
              ))}
            </div>
            <button
              onClick={handleCopy}
              className="ml-auto inline-flex items-center gap-2 px-3 py-1.5 rounded-lg bg-primary hover:bg-primary/90 text-white text-xs font-bold transition-colors"
            >
              {copied ? (
                <>
                  <CheckCircle2 className="w-4 h-4" /> Copiado
                </>
              ) : (
                <>
                  <Copy className="w-4 h-4" /> Copiar prompt para IA
                </>
              )}
            </button>
          </div>
        )}

        {/* Contenido */}
        <div className="p-5">
          {tab === 'scans' && <ScansList rows={scans} />}
          {tab === 'unmatched' && (
            <RawTable rows={unmatched} emptyTitle="No hay items sin catálogo todavía" />
          )}
          {tab === 'dropped' && (
            <RawTable rows={dropped} emptyTitle="No hay items descartados todavía" />
          )}
          {tab === 'manual' && (
            <ManualTable rows={manual} emptyTitle="Todos los items manuales tienen icono ✨" />
          )}
          {tab === 'stats' && (
            <StatsTable rows={stats} />
          )}
        </div>
      </div>
    </div>
  );
};

// ─── Subcomponentes ─────────────────────────────────────────────────────────

const Header = ({
  onRefresh,
  refreshing,
}: {
  onRefresh?: () => void;
  refreshing?: boolean;
}) => (
  <div className="flex flex-wrap items-start justify-between gap-3">
    <div>
      <h2 className="text-3xl font-bold tracking-tight flex items-center gap-3">
        <ScanLine className="w-8 h-8 text-violet-400" />
        OCR Insights
      </h2>
      <p className="text-gray-400 mt-1">
        Productos que la IA detecta en tickets, qué resuelve el matcher y qué
        agregan los usuarios manualmente — todo para ampliar el catálogo de iconos.
      </p>
    </div>
    {onRefresh && (
      <button
        onClick={onRefresh}
        disabled={refreshing}
        className="inline-flex items-center gap-2 px-4 py-2 rounded-xl bg-white/10 hover:bg-white/15 text-sm font-bold disabled:opacity-50 transition-colors"
      >
        <RefreshCcw className={`w-4 h-4 ${refreshing ? 'animate-spin' : ''}`} />
        Refrescar
      </button>
    )}
  </div>
);

const StatCard = ({
  icon,
  label,
  value,
  tone,
}: {
  icon: React.ReactNode;
  label: string;
  value: string;
  tone: 'indigo' | 'emerald' | 'violet';
}) => {
  const tones = {
    indigo: 'bg-indigo-500/10 text-indigo-400',
    emerald: 'bg-emerald-500/10 text-emerald-400',
    violet: 'bg-violet-500/10 text-violet-400',
  };
  return (
    <div className="glass-dark rounded-2xl border border-white/10 p-5">
      <div className={`w-10 h-10 rounded-xl flex items-center justify-center ${tones[tone]}`}>
        {icon}
      </div>
      <div className="mt-3 text-xs uppercase tracking-wider text-gray-400 font-bold">
        {label}
      </div>
      <div className="text-2xl font-bold mt-1">{value}</div>
    </div>
  );
};

const TabButton = ({
  active,
  onClick,
  icon,
  label,
  count,
}: {
  active: boolean;
  onClick: () => void;
  icon: React.ReactNode;
  label: string;
  count?: number;
}) => (
  <button
    onClick={onClick}
    className={`flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-bold transition-all ${
      active
        ? 'bg-primary/20 text-secondary border border-primary/20'
        : 'text-gray-400 hover:bg-white/5 hover:text-white'
    }`}
  >
    {icon}
    {label}
    {count !== undefined && (
      <span
        className={`text-[10px] px-1.5 py-0.5 rounded-full ${
          active ? 'bg-primary/30 text-white' : 'bg-white/10 text-gray-400'
        }`}
      >
        {count}
      </span>
    )}
  </button>
);

const RawTable = ({
  rows,
  emptyTitle,
}: {
  rows: UnmatchedRow[] | null;
  emptyTitle: string;
}) => {
  if (!rows || rows.length === 0) {
    return <EmptyState title={emptyTitle} description="Cuando los usuarios escaneen más tickets, los datos aparecerán acá." />;
  }
  return (
    <div className="overflow-x-auto">
      <table className="w-full text-sm">
        <thead>
          <tr className="text-left text-xs uppercase tracking-wider text-gray-400 border-b border-white/5">
            <th className="py-2 pr-4">Texto detectado</th>
            <th className="py-2 pr-4 text-right">Veces</th>
            <th className="py-2 pr-4 text-right">Usuarios</th>
            <th className="py-2 pr-4 text-right">Última vez</th>
          </tr>
        </thead>
        <tbody>
          {rows.map((r, idx) => (
            <tr key={idx} className="border-b border-white/5 hover:bg-white/5">
              <td className="py-2 pr-4 font-mono text-xs">{r.raw_text}</td>
              <td className="py-2 pr-4 text-right font-bold">{r.occurrences}</td>
              <td className="py-2 pr-4 text-right text-gray-400">{r.distinct_users}</td>
              <td className="py-2 pr-4 text-right text-gray-400">{fmtDate(r.last_seen)}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

const ManualTable = ({
  rows,
  emptyTitle,
}: {
  rows: ManualRow[] | null;
  emptyTitle: string;
}) => {
  if (!rows || rows.length === 0) {
    return <EmptyState title={emptyTitle} />;
  }
  return (
    <div className="overflow-x-auto">
      <table className="w-full text-sm">
        <thead>
          <tr className="text-left text-xs uppercase tracking-wider text-gray-400 border-b border-white/5">
            <th className="py-2 pr-4">Producto</th>
            <th className="py-2 pr-4">Variaciones</th>
            <th className="py-2 pr-4 text-right">Veces agregado</th>
            <th className="py-2 pr-4 text-right">Hogares</th>
            <th className="py-2 pr-4 text-right">Última vez</th>
          </tr>
        </thead>
        <tbody>
          {rows.map((r, idx) => (
            <tr key={idx} className="border-b border-white/5 hover:bg-white/5">
              <td className="py-2 pr-4 font-bold">{r.normalized_name}</td>
              <td className="py-2 pr-4 text-xs text-gray-400">
                {(r.variations ?? []).slice(0, 3).join(', ')}
                {(r.variations?.length ?? 0) > 3 && '…'}
              </td>
              <td className="py-2 pr-4 text-right font-bold">{r.times_added}</td>
              <td className="py-2 pr-4 text-right text-gray-400">{r.households_using}</td>
              <td className="py-2 pr-4 text-right text-gray-400">{fmtDate(r.last_added)}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

// Lista de scans individuales — muestra la cadena completa: AI raw → matcher.
const ScansList = ({ rows }: { rows: ScanLog[] | null }) => {
  if (!rows || rows.length === 0) {
    return (
      <EmptyState
        title="Sin scans todavía"
        description="Los scans van a aparecer acá apenas un usuario use el OCR."
      />
    );
  }
  return (
    <div className="space-y-3">
      {rows.map((scan) => (
        <ScanCard key={scan.id} scan={scan} />
      ))}
    </div>
  );
};

const ScanCard = ({ scan }: { scan: ScanLog }) => {
  const [expanded, setExpanded] = useState(false);
  const r = scan.matcher_result ?? {};
  const matched = r.matched ?? [];
  const toAdd = r.to_add ?? [];
  const unrec = r.unrecognized ?? [];
  const drop = r.dropped ?? [];

  const ts = new Date(scan.created_at).toLocaleString('es-AR', {
    day: '2-digit',
    month: 'short',
    hour: '2-digit',
    minute: '2-digit',
  });

  const actionTone =
    scan.user_action === 'confirmed'
      ? 'bg-emerald-500/10 text-emerald-300'
      : scan.user_action === 'cancelled'
      ? 'bg-rose-500/10 text-rose-300'
      : 'bg-amber-500/10 text-amber-300';

  const actionLabel =
    scan.user_action ?? 'pending';

  return (
    <div className="rounded-2xl bg-white/5 border border-white/10 overflow-hidden">
      <button
        onClick={() => setExpanded((v) => !v)}
        className="w-full flex flex-wrap items-center gap-3 px-4 py-3 hover:bg-white/5 transition-colors"
      >
        <div className="flex items-center gap-2 text-xs">
          <span className="text-gray-400 font-mono">{ts}</span>
          <span className="font-bold text-white">
            {scan.ai_merchant ?? '—'}
          </span>
        </div>
        <div className="flex items-center gap-2 ml-auto">
          <span className={`text-[10px] px-2 py-0.5 rounded-full font-bold ${actionTone}`}>
            {actionLabel}
          </span>
          {scan.tier && (
            <span className="text-[10px] px-2 py-0.5 rounded-full bg-white/10 text-gray-300 font-bold">
              {scan.tier}
            </span>
          )}
          {scan.ai_confidence != null && (
            <span className="text-[10px] px-2 py-0.5 rounded-full bg-violet-500/10 text-violet-300 font-bold">
              IA {scan.ai_confidence.toFixed(2)}
            </span>
          )}
          <span className="text-[10px] text-gray-400">
            raw {scan.ai_raw_items?.length ?? 0} · match {matched.length} · nuevos {toAdd.length} · sin {unrec.length} · drop {drop.length}
          </span>
          {expanded ? (
            <ChevronUp className="w-4 h-4 text-gray-400" />
          ) : (
            <ChevronDown className="w-4 h-4 text-gray-400" />
          )}
        </div>
      </button>

      {expanded && (
        <div className="px-4 pb-4 grid grid-cols-1 md:grid-cols-2 gap-4 text-xs">
          <ChainColumn
            title="📷 Texto original (IA)"
            tone="violet"
            items={scan.ai_raw_items ?? []}
            empty="—"
          />
          <ChainColumn
            title="✅ Marcados (ya en lista)"
            tone="emerald"
            items={matched}
            empty="ninguno"
          />
          <ChainColumn
            title="🆕 Ofrecidos para agregar"
            tone="indigo"
            items={toAdd}
            empty="ninguno"
          />
          <ChainColumn
            title="❓ Sin catálogo (candidatos)"
            tone="amber"
            items={unrec}
            empty="ninguno"
          />
          <ChainColumn
            title="🗑️ Descartados (quality gate)"
            tone="rose"
            items={drop}
            empty="ninguno"
            wide
          />
        </div>
      )}
    </div>
  );
};

const ChainColumn = ({
  title,
  tone,
  items,
  empty,
  wide,
}: {
  title: string;
  tone: 'violet' | 'emerald' | 'indigo' | 'amber' | 'rose';
  items: string[];
  empty: string;
  wide?: boolean;
}) => {
  const tones = {
    violet: 'border-violet-500/30 bg-violet-500/5',
    emerald: 'border-emerald-500/30 bg-emerald-500/5',
    indigo: 'border-indigo-500/30 bg-indigo-500/5',
    amber: 'border-amber-500/30 bg-amber-500/5',
    rose: 'border-rose-500/30 bg-rose-500/5',
  };
  return (
    <div className={`rounded-xl border ${tones[tone]} p-3 ${wide ? 'md:col-span-2' : ''}`}>
      <div className="text-[11px] uppercase tracking-wider font-bold text-gray-300 mb-2">
        {title} · {items.length}
      </div>
      {items.length === 0 ? (
        <div className="text-gray-500 italic">{empty}</div>
      ) : (
        <ul className="space-y-1">
          {items.map((it, i) => (
            <li key={i} className="font-mono text-gray-200 break-all">
              {it}
            </li>
          ))}
        </ul>
      )}
    </div>
  );
};

const StatsTable = ({ rows }: { rows: DailyStats[] | null }) => {
  if (!rows || rows.length === 0) {
    return <EmptyState title="Sin scans todavía" description="Las métricas se llenan a medida que los usuarios usan el OCR." />;
  }
  return (
    <div className="overflow-x-auto">
      <table className="w-full text-sm">
        <thead>
          <tr className="text-left text-xs uppercase tracking-wider text-gray-400 border-b border-white/5">
            <th className="py-2 pr-4">Día</th>
            <th className="py-2 pr-4 text-right">Scans</th>
            <th className="py-2 pr-4 text-right">Confianza</th>
            <th className="py-2 pr-4 text-right">Match prom.</th>
            <th className="py-2 pr-4 text-right">A agregar prom.</th>
            <th className="py-2 pr-4 text-right">Sin catálogo</th>
            <th className="py-2 pr-4 text-right">Descartados</th>
            <th className="py-2 pr-4 text-right">% Confirm.</th>
          </tr>
        </thead>
        <tbody>
          {rows.map((r) => (
            <tr key={r.day} className="border-b border-white/5 hover:bg-white/5">
              <td className="py-2 pr-4 font-bold">{fmtDate(r.day)}</td>
              <td className="py-2 pr-4 text-right">{r.total_scans}</td>
              <td className="py-2 pr-4 text-right">{r.avg_confidence ?? '—'}</td>
              <td className="py-2 pr-4 text-right">{r.avg_matched ?? '—'}</td>
              <td className="py-2 pr-4 text-right">{r.avg_to_add ?? '—'}</td>
              <td className="py-2 pr-4 text-right">{r.avg_unmatched ?? '—'}</td>
              <td className="py-2 pr-4 text-right">{r.avg_dropped ?? '—'}</td>
              <td className="py-2 pr-4 text-right font-bold text-emerald-400">
                {r.confirm_rate_pct ?? '—'}%
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};
