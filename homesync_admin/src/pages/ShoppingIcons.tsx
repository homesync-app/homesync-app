import { useEffect, useMemo, useState } from 'react';
import { Link } from 'react-router-dom';
import type { LucideIcon } from 'lucide-react';
import {
  Search,
  Sparkles,
  CheckCircle2,
  AlertTriangle,
  RefreshCcw,
  PackageX,
  ImageOff,
  Flame,
  Clock,
  Library,
  ScanLine,
  TrendingUp,
  ArrowRight,
} from 'lucide-react';
import { supabase } from '../lib/supabase';
import { EmptyState, ErrorState, LoadingState } from '../components/PageState';

interface UsageRow {
  normalized_name: string;
  primary_name_key: string | null;
  primary_emoji: string | null;
  times_added: number;
  households_using: number;
  last_added: string;
  variations: string[];
}

interface CatalogEntry {
  name_key: string;
  version: string;
  aliases: Record<string, string[]>;
  usage: UsageRow | null;
}

interface OcrRawRow {
  raw_text: string;
  occurrences: number;
  distinct_users: number;
  last_seen: string;
}

interface OcrDailyStat {
  day: string;
  total_scans: number;
  avg_confidence: number | null;
  confirmed: number;
  cancelled: number;
  confirm_rate_pct: number | null;
}

type Tab = 'catalog' | 'unused' | 'pending' | 'ocr';
type OcrSubTab = 'unmatched' | 'dropped';
type SortKey = 'usage' | 'name' | 'last_used';
type SortDir = 'asc' | 'desc';

const BUCKET = 'shopping-icons';

const fmtDate = (iso: string | null | undefined) => {
  if (!iso) return '—';
  try {
    return new Date(iso).toLocaleDateString('es-AR', {
      day: '2-digit',
      month: 'short',
    });
  } catch {
    return '—';
  }
};

const titleCase = (s: string) =>
  s
    .replace(/[_-]+/g, ' ')
    .replace(/\b\w/g, (c) => c.toUpperCase())
    .trim();

const GENERIC_EMOJIS = new Set(['🛒', '\u{1F6D2}', 'Â­ÆÃ¸Ã†', '']);

const isGenericEmoji = (e: string | null | undefined) =>
  !e || GENERIC_EMOJIS.has(e);

type PendingStatus = 'missing' | 'unpicked' | 'generic';

interface PendingEntry {
  row: UsageRow;
  status: PendingStatus;
  suggested_key: string | null;
  match_reason: string | null;
}

interface ManifestEntry {
  v: string;
  aliases: Record<string, string[]>;
}

const parseManifestEntry = (raw: unknown): ManifestEntry => {
  if (typeof raw === 'string') return { v: raw, aliases: {} };
  if (raw && typeof raw === 'object') {
    const e = raw as { v?: string; aliases?: Record<string, string[]> };
    return { v: e.v ?? '1', aliases: e.aliases ?? {} };
  }
  return { v: '1', aliases: {} };
};

const normalize = (s: string) =>
  s
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/\s+/g, ' ')
    .trim();

const singularize = (s: string) => {
  if (s.length <= 3) return s;
  if (s.endsWith('es') && s.length > 4) return s.slice(0, -2);
  if (s.endsWith('s')) return s.slice(0, -1);
  return s;
};

const normalizeToken = (s: string) => singularize(normalize(s));

interface CatalogIndex {
  keys: string[];
  aliasIndex: Map<string, string>;
  byFirstWord: Map<string, string[]>;
}

const buildCatalogIndex = (
  manifest: Record<string, unknown> | null,
): CatalogIndex => {
  const empty: CatalogIndex = {
    keys: [],
    aliasIndex: new Map(),
    byFirstWord: new Map(),
  };
  if (!manifest) return empty;
  const keys = Object.keys(manifest);
  const aliasIndex = new Map<string, string>();
  const byFirstWord = new Map<string, string[]>();
  keys.forEach((k) => {
    const entry = parseManifestEntry(manifest[k]);
    const candidates = new Set<string>();
    candidates.add(titleCase(k).toLowerCase());
    candidates.add(k.toLowerCase().replace(/[_-]+/g, ' '));
    for (const arr of Object.values(entry.aliases)) {
      for (const a of arr) candidates.add(a.toLowerCase());
    }
    candidates.forEach((c) => {
      const n = normalizeToken(c);
      if (n && !aliasIndex.has(n)) aliasIndex.set(n, k);
    });
    const first = normalizeToken(titleCase(k));
    if (first) {
      const list = byFirstWord.get(first) ?? [];
      list.push(k);
      byFirstWord.set(first, list);
    }
  });
  return { keys, aliasIndex, byFirstWord };
};

const findCatalogMatch = (
  normalized: string,
  index: CatalogIndex,
): { nameKey: string; reason: string } | null => {
  const n = normalizeToken(normalized);
  if (!n) return null;

  const exact = index.aliasIndex.get(n);
  if (exact) return { nameKey: exact, reason: 'Nombre/alias exacto' };

  const firstWordHits = index.byFirstWord.get(n);
  if (firstWordHits && firstWordHits.length > 0) {
    return { nameKey: firstWordHits[0], reason: 'Primera palabra' };
  }

  for (const k of index.keys) {
    const tc = titleCase(k).toLowerCase();
    if (tc.includes(n) || n.includes(tc.split(' ')[0])) {
      return { nameKey: k, reason: 'Semejante' };
    }
  }

  return null;
};

export const ShoppingIcons = () => {
  const [rows, setRows] = useState<UsageRow[] | null>(null);
  const [manifest, setManifest] = useState<Record<string, unknown> | null>(null);
  const [ocrUnmatched, setOcrUnmatched] = useState<OcrRawRow[] | null>(null);
  const [ocrDropped, setOcrDropped] = useState<OcrRawRow[] | null>(null);
  const [ocrDaily, setOcrDaily] = useState<OcrDailyStat[] | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [tab, setTab] = useState<Tab>('catalog');
  // Sub-filtro del tab "Falta ícono". Por defecto mostramos sólo los
  // accionables (status 'missing' = sin match en el catálogo → hay que CREAR un
  // ícono). Los que SÍ tienen match ('unpicked'/'generic') ya tienen ícono
  // disponible, así que no son demanda real y quedan detrás de un chip en vez
  // de ensuciar la lista principal.
  const [pendingFilter, setPendingFilter] = useState<
    'actionable' | 'matched' | 'all'
  >('actionable');
  const [ocrSubTab, setOcrSubTab] = useState<OcrSubTab>('unmatched');
  const [query, setQuery] = useState('');
  const [loading, setLoading] = useState(false);
  const [sortKey, setSortKey] = useState<SortKey>('usage');
  const [sortDir, setSortDir] = useState<SortDir>('desc');

  const storageBase = useMemo(() => {
    const { data } = supabase.storage.from(BUCKET).getPublicUrl('');
    return data.publicUrl.replace(/\/$/, '');
  }, []);

  const load = async () => {
    setLoading(true);
    setError(null);
    try {
      const usagePromise = supabase
        .from('v_shopping_items_usage')
        .select('*')
        .limit(1000);
      const manifestUrl = `${storageBase}/manifest.json?t=${Date.now()}`;
      const manifestPromise = fetch(manifestUrl).then(async (r) => {
        if (!r.ok) throw new Error(`manifest fetch ${r.status}`);
        return (await r.json()) as Record<string, unknown>;
      });
      const ocrUnmatchedPromise = supabase
        .from('v_ocr_unmatched_items')
        .select('*')
        .limit(50);
      const ocrDroppedPromise = supabase
        .from('v_ocr_dropped_items')
        .select('*')
        .limit(50);
      const ocrDailyPromise = supabase
        .from('v_ocr_daily_stats')
        .select('*')
        .limit(14);
      const [usageRes, manifestData, unmatchedRes, droppedRes, dailyRes] =
        await Promise.all([
          usagePromise,
          manifestPromise,
          ocrUnmatchedPromise,
          ocrDroppedPromise,
          ocrDailyPromise,
        ]);
      if (usageRes.error) throw usageRes.error;
      if (unmatchedRes.error) throw unmatchedRes.error;
      if (droppedRes.error) throw droppedRes.error;
      if (dailyRes.error) throw dailyRes.error;
      setRows((usageRes.data ?? []) as UsageRow[]);
      setManifest(manifestData);
      setOcrUnmatched((unmatchedRes.data ?? []) as OcrRawRow[]);
      setOcrDropped((droppedRes.data ?? []) as OcrRawRow[]);
      setOcrDaily((dailyRes.data ?? []) as OcrDailyStat[]);
    } catch (e) {
      setError(e instanceof Error ? e.message : String(e));
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const usageByNameKey = useMemo(() => {
    const map = new Map<string, UsageRow>();
    (rows ?? []).forEach((r) => {
      if (r.primary_name_key && !map.has(r.primary_name_key)) {
        map.set(r.primary_name_key, r);
      }
    });
    return map;
  }, [rows]);

  const catalog: CatalogEntry[] = useMemo(() => {
    if (!manifest) return [];
    return Object.entries(manifest)
      .map(([name_key, raw]) => {
        const entry = parseManifestEntry(raw);
        return {
          name_key,
          version: entry.v,
          aliases: entry.aliases,
          usage: usageByNameKey.get(name_key) ?? null,
        };
      })
      .sort((a, b) => a.name_key.localeCompare(b.name_key));
  }, [manifest, usageByNameKey]);

  const catalogIndex = useMemo(() => buildCatalogIndex(manifest), [manifest]);

  const pendingRequests: PendingEntry[] = useMemo(() => {
    if (!rows || !manifest) return [];
    return rows
      .filter((r) => !r.primary_name_key || !manifest[r.primary_name_key])
      .map<PendingEntry>((r) => {
        const isOrphanKey =
          !!r.primary_name_key && !manifest[r.primary_name_key];
        const generic = isGenericEmoji(r.primary_emoji);
        const match = findCatalogMatch(r.normalized_name, catalogIndex);

        let status: PendingStatus;
        if (!match) {
          status = 'missing';
        } else if (isOrphanKey) {
          status = 'unpicked';
        } else if (generic) {
          status = 'generic';
        } else {
          status = 'unpicked';
        }

        const reason = isOrphanKey && match ? 'Key huérfano' : (match?.reason ?? null);

        return {
          row: r,
          status,
          suggested_key: match?.nameKey ?? null,
          match_reason: reason,
        };
      })
      .sort((a, b) => {
        const order: Record<PendingStatus, number> = {
          missing: 0,
          unpicked: 1,
          generic: 2,
        };
        if (a.status !== b.status) return order[a.status] - order[b.status];
        return (
          new Date(b.row.last_added).getTime() -
          new Date(a.row.last_added).getTime()
        );
      });
  }, [rows, manifest, catalogIndex]);

  const stats = useMemo(() => {
    const total = catalog.length;
    const used = catalog.filter((c) => c.usage !== null).length;
    const unused = total - used;
    const missing = pendingRequests.filter((p) => p.status === 'missing').length;
    const unpicked = pendingRequests.filter(
      (p) => p.status === 'unpicked',
    ).length;
    const generic = pendingRequests.filter((p) => p.status === 'generic').length;
    const coverage = total > 0 ? Math.round((used / total) * 100) : 0;
    return { total, used, unused, missing, unpicked, generic, coverage };
  }, [catalog, pendingRequests]);

  const sortedCatalog = useMemo(() => {
    const dir = sortDir === 'asc' ? 1 : -1;
    return [...catalog].sort((a, b) => {
      switch (sortKey) {
        case 'name':
          return dir * a.name_key.localeCompare(b.name_key);
        case 'last_used': {
          const av = a.usage?.last_added ?? '';
          const bv = b.usage?.last_added ?? '';
          if (!av && !bv) return a.name_key.localeCompare(b.name_key);
          if (!av) return 1;
          if (!bv) return -1;
          return dir * (new Date(av).getTime() - new Date(bv).getTime());
        }
        case 'usage':
        default: {
          const av = a.usage?.times_added ?? 0;
          const bv = b.usage?.times_added ?? 0;
          if (av === bv) return a.name_key.localeCompare(b.name_key);
          return dir * (av - bv);
        }
      }
    });
  }, [catalog, sortKey, sortDir]);

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase();
    if (tab === 'pending') {
      let base = pendingRequests;
      if (pendingFilter === 'actionable') {
        base = base.filter((p) => p.status === 'missing');
      } else if (pendingFilter === 'matched') {
        base = base.filter((p) => p.status !== 'missing');
      }
      if (!q) return base;
      return base.filter(
        (p) =>
          p.row.normalized_name.includes(q) ||
          p.row.variations.some((v) => v.toLowerCase().includes(q)) ||
          (p.row.primary_name_key?.toLowerCase().includes(q) ?? false) ||
          (p.suggested_key?.toLowerCase().includes(q) ?? false),
      );
    }
    const base = tab === 'unused' ? sortedCatalog.filter((c) => !c.usage) : sortedCatalog;
    if (!q) return base;
    return base.filter((c) => c.name_key.toLowerCase().includes(q));
  }, [tab, sortedCatalog, pendingRequests, query, pendingFilter]);

  const toggleSort = (key: SortKey) => {
    if (sortKey === key) {
      setSortDir((d) => (d === 'asc' ? 'desc' : 'asc'));
    } else {
      setSortKey(key);
      setSortDir(key === 'name' ? 'asc' : 'desc');
    }
  };

  const sortIndicator = (key: SortKey) =>
    sortKey === key ? (sortDir === 'asc' ? '↑' : '↓') : '';

  const ocrSummary = useMemo(() => {
    const last7 = (ocrDaily ?? []).slice(0, 7);
    const totalScans = last7.reduce((acc, r) => acc + (r.total_scans ?? 0), 0);
    const totalConfirmed = last7.reduce((acc, r) => acc + (r.confirmed ?? 0), 0);
    const confirmRate =
      totalScans > 0
        ? ((totalConfirmed / totalScans) * 100).toFixed(1)
        : '—';
    const avgConf =
      last7.length > 0
        ? (
            last7.reduce(
              (a, r) => a + (r.avg_confidence ?? 0),
              0,
            ) / last7.length
          ).toFixed(2)
        : '—';
    return { totalScans, confirmRate, avgConf };
  }, [ocrDaily]);

  return (
    <div className="space-y-6 animate-in fade-in duration-500">
      <div className="flex flex-wrap items-start justify-between gap-4">
        <div>
          <h2 className="text-3xl font-bold tracking-tight flex items-center gap-3">
            <Sparkles className="w-7 h-7 text-secondary" /> Íconos de compras
          </h2>
          <p className="text-gray-400 mt-1 max-w-3xl">
            El catálogo es el manifest del bucket <span className="font-mono text-gray-300">shopping-icons</span>{' '}
            (lo que realmente ven los usuarios en la app). Lo cruzamos con{' '}
            <span className="font-mono text-gray-300">v_shopping_items_usage</span> para saber qué íconos
            se usan, cuáles nadie pidió y qué productos quedaron sin ícono.
          </p>
        </div>
        <button
          onClick={load}
          disabled={loading}
          className="glass px-4 py-2 rounded-xl hover:bg-white/10 transition-all flex items-center gap-2 text-sm font-bold disabled:opacity-50"
        >
          <RefreshCcw className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`} />
          Refrescar
        </button>
      </div>

      <OcrHealthBar
        summary={ocrSummary}
        unmatchedCount={ocrUnmatched?.length ?? 0}
        droppedCount={ocrDropped?.length ?? 0}
      />

      <div className="grid grid-cols-2 lg:grid-cols-5 gap-4">
        <StatCard
          tone="indigo"
          label="Total íconos"
          sublabel="catálogo manifest"
          value={stats.total}
          icon={Library}
        />
        <StatCard
          tone="emerald"
          label="En uso (90d)"
          sublabel="usuarios lo pidieron"
          value={stats.used}
          icon={CheckCircle2}
        />
        <StatCard
          tone="amber"
          label="Sin uso (90d)"
          sublabel="en manifest, sin pedidos"
          value={stats.unused}
          icon={PackageX}
        />
        <StatCard
          tone="rose"
          label="Falta ícono en catálogo"
          sublabel={
            stats.missing + stats.unpicked + stats.generic > 0
              ? `${stats.unpicked + stats.generic} con match · crear ícono nuevo`
              : 'todo cubierto'
          }
          value={stats.missing}
          icon={ImageOff}
        />
        <StatCard
          tone="violet"
          label="Cobertura"
          sublabel="del catálogo en uso"
          value={`${stats.coverage}%`}
          icon={Sparkles}
        />
      </div>

      <div className="grid grid-cols-2 sm:grid-cols-4 gap-2 bg-white/5 border border-white/10 rounded-xl p-1">
        <TabButton
          active={tab === 'catalog'}
          onClick={() => setTab('catalog')}
          icon={Library}
          label="Catálogo"
          count={stats.total}
        />
        <TabButton
          active={tab === 'unused'}
          onClick={() => setTab('unused')}
          icon={PackageX}
          label="Sin uso"
          count={stats.unused}
        />
        <TabButton
          active={tab === 'pending'}
          onClick={() => setTab('pending')}
          icon={ImageOff}
          label="Falta ícono"
          count={stats.missing}
        />
        <TabButton
          active={tab === 'ocr'}
          onClick={() => setTab('ocr')}
          icon={ScanLine}
          label="Demanda OCR"
          count={(ocrUnmatched?.length ?? 0) + (ocrDropped?.length ?? 0)}
        />
      </div>

      <div className="relative">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
        <input
          type="text"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder={
            tab === 'ocr'
              ? 'No aplica en Demanda OCR — usá las sub-tablas'
              : tab === 'pending'
                ? 'Buscar por nombre, variante o nameKey...'
                : 'Buscar por nameKey (ej: milk, milanesas, banana)...'
          }
          disabled={tab === 'ocr'}
          className="w-full bg-white/5 border border-white/10 rounded-xl pl-10 pr-4 py-2.5 text-sm placeholder-gray-500 focus:outline-none focus:border-primary/50 disabled:opacity-50"
        />
      </div>

      {tab === 'pending' && (
        <div className="flex flex-wrap gap-2 text-xs font-bold">
          {(['actionable', 'matched', 'all'] as const).map((key) => {
            const labels: Record<typeof key, string> = {
              actionable: `Falta ícono — crear nuevo (${stats.missing})`,
              matched: `Con match — ya tienen ícono (${stats.unpicked + stats.generic})`,
              all: `Todos (${stats.missing + stats.unpicked + stats.generic})`,
            };
            return (
              <button
                key={key}
                onClick={() => setPendingFilter(key)}
                className={`px-3 py-1.5 rounded-lg border transition-colors ${
                  pendingFilter === key
                    ? 'bg-primary/20 border-primary/40 text-primary'
                    : 'bg-white/5 border-white/10 text-gray-400 hover:text-white'
                }`}
              >
                {labels[key]}
              </button>
            );
          })}
        </div>
      )}

      {loading && !rows && <LoadingState title="Cargando productos y manifest..." />}
      {error && <ErrorState title="Error cargando datos" description={error} />}
      {!loading && rows && manifest && tab !== 'ocr' && filtered.length === 0 && (
        <EmptyState
          title={
            tab === 'catalog'
              ? 'El manifest está vacío'
              : tab === 'unused'
                ? 'Todos los íconos del catálogo se usaron en los últimos 90 días'
                : 'No hay productos sin ícono en los últimos 90 días'
          }
          description={
            tab === 'pending'
              ? undefined
              : tab === 'unused'
                ? 'Buen indicio: el catálogo está alineado con el uso real.'
                : undefined
          }
        />
      )}
      {tab === 'ocr' && (
        <OcrDemandPanel
          unmatched={ocrUnmatched ?? []}
          dropped={ocrDropped ?? []}
          subTab={ocrSubTab}
          onSubTabChange={setOcrSubTab}
        />
      )}
      {filtered.length > 0 && tab === 'pending' && (
        <PendingTable
          rows={filtered as PendingEntry[]}
          storageBase={storageBase}
        />
      )}
      {filtered.length > 0 && tab !== 'pending' && tab !== 'ocr' && (
        <CatalogTable
          rows={filtered as CatalogEntry[]}
          storageBase={storageBase}
          sortKey={sortKey}
          sortIndicator={sortIndicator}
          onSort={toggleSort}
        />
      )}
    </div>
  );
};

const TabButton = ({
  active,
  onClick,
  icon: Icon,
  label,
  count,
}: {
  active: boolean;
  onClick: () => void;
  icon: LucideIcon;
  label: string;
  count: number;
}) => (
  <button
    onClick={onClick}
    className={`flex items-center justify-center gap-2 px-4 py-2 text-sm font-bold rounded-lg transition-all ${
      active
        ? 'bg-primary/20 text-secondary border border-primary/30'
        : 'text-gray-400 hover:text-white border border-transparent'
    }`}
  >
    <Icon className="w-4 h-4" />
    <span>{label}</span>
    <span
      className={`text-[10px] tabular-nums px-1.5 py-0.5 rounded-full ${
        active ? 'bg-secondary/20 text-secondary' : 'bg-white/5 text-gray-400'
      }`}
    >
      {count}
    </span>
  </button>
);

const SortHeader = ({
  label,
  k,
  sortKey,
  sortIndicator,
  onSort,
  align = 'left',
  icon: Icon,
}: {
  label: string;
  k: SortKey;
  sortKey: SortKey;
  sortIndicator: (k: SortKey) => string;
  onSort: (k: SortKey) => void;
  align?: 'left' | 'right' | 'center';
  icon?: LucideIcon;
}) => {
  const active = sortKey === k;
  return (
    <th
      className={`px-4 py-3 font-bold ${
        align === 'right' ? 'text-right' : align === 'center' ? 'text-center' : 'text-left'
      }`}
    >
      <button
        type="button"
        onClick={() => onSort(k)}
        className={`inline-flex items-center gap-1.5 transition-colors ${
          active ? 'text-secondary' : 'text-gray-400 hover:text-gray-200'
        }`}
      >
        {Icon && <Icon className="w-3.5 h-3.5" />}
        <span className="uppercase tracking-wider text-xs">{label}</span>
        <span className="text-[10px] w-2.5 tabular-nums">{sortIndicator(k)}</span>
      </button>
    </th>
  );
};

const CatalogTable = ({
  rows,
  storageBase,
  sortKey,
  sortIndicator,
  onSort,
}: {
  rows: CatalogEntry[];
  storageBase: string;
  sortKey: SortKey;
  sortIndicator: (k: SortKey) => string;
  onSort: (k: SortKey) => void;
}) => (
  <div className="glass rounded-2xl overflow-hidden">
    <div className="overflow-x-auto">
      <table className="w-full min-w-[720px]">
        <thead className="bg-white/5 border-b border-white/10">
          <tr>
            <th className="text-left px-4 py-3 font-bold w-16">Ícono</th>
            <th className="text-left px-4 py-3 font-bold">Producto</th>
            <SortHeader
              label="Veces"
              k="usage"
              sortKey={sortKey}
              sortIndicator={sortIndicator}
              onSort={onSort}
              align="right"
              icon={Flame}
            />
            <th className="text-right px-4 py-3 font-bold text-xs uppercase tracking-wider text-gray-400">
              Hogares
            </th>
            <SortHeader
              label="Último uso"
              k="last_used"
              sortKey={sortKey}
              sortIndicator={sortIndicator}
              onSort={onSort}
              align="right"
              icon={Clock}
            />
            <th className="text-center px-4 py-3 font-bold w-28 text-xs uppercase tracking-wider text-gray-400">
              Estado
            </th>
          </tr>
        </thead>
        <tbody className="text-sm divide-y divide-white/5">
          {rows.map((c) => {
            const used = c.usage !== null;
            return (
              <tr
                key={c.name_key}
                className="hover:bg-white/5 transition-colors"
              >
                <td className="px-4 py-3">
                  <img
                    src={`${storageBase}/products/${c.name_key}.png?v=${c.version}`}
                    alt={c.name_key}
                    className="w-10 h-10 object-contain rounded-lg bg-white/5"
                    loading="lazy"
                    onError={(e) => {
                      (e.currentTarget as HTMLImageElement).style.opacity = '0.2';
                    }}
                  />
                </td>
                <td className="px-4 py-3">
                  <div className="font-bold">{titleCase(c.name_key)}</div>
                  <div className="text-xs text-gray-500 font-mono mt-0.5">
                    {c.name_key}
                  </div>
                  {c.aliases?.es && c.aliases.es.length > 0 && (
                    <div
                      className="text-[10px] text-gray-500 mt-1 max-w-xs truncate"
                      title={c.aliases.es.join(', ')}
                    >
                      <span className="text-secondary/70">es:</span>{' '}
                      {c.aliases.es.slice(0, 4).join(' · ')}
                      {c.aliases.es.length > 4 &&
                        ` · +${c.aliases.es.length - 4}`}
                    </div>
                  )}
                </td>
                <td className="px-4 py-3 text-right font-bold tabular-nums">
                  {c.usage?.times_added ?? 0}
                </td>
                <td className="px-4 py-3 text-right text-gray-400 tabular-nums">
                  {c.usage?.households_using ?? 0}
                </td>
                <td className="px-4 py-3 text-right text-gray-500 text-xs">
                  {fmtDate(c.usage?.last_added)}
                </td>
                <td className="px-4 py-3 text-center">
                  {used ? (
                    <span className="inline-flex items-center gap-1 text-emerald-400 text-xs font-bold">
                      <CheckCircle2 className="w-3.5 h-3.5" /> En uso
                    </span>
                  ) : (
                    <span className="inline-flex items-center gap-1 text-gray-500 text-xs font-bold">
                      <PackageX className="w-3.5 h-3.5" /> Sin uso
                    </span>
                  )}
                </td>
              </tr>
            );
          })}
        </tbody>
      </table>
    </div>
  </div>
);

const PendingStatusChip = ({ entry }: { entry: PendingEntry }) => {
  if (entry.status === 'missing') {
    return (
      <div className="flex flex-col items-center gap-1">
        <span className="inline-flex items-center gap-1 text-amber-400 text-xs font-bold">
          <AlertTriangle className="w-3.5 h-3.5" /> Sin ícono en catálogo
        </span>
        <span className="text-[10px] text-gray-500">necesita ícono nuevo</span>
      </div>
    );
  }
  if (entry.status === 'unpicked') {
    return (
      <div className="flex flex-col items-center gap-1">
        <span className="inline-flex items-center gap-1 text-sky-300 text-xs font-bold">
          <Search className="w-3.5 h-3.5" /> Ícono sin elegir
        </span>
        {entry.suggested_key && (
          <span className="inline-flex items-center gap-1 px-1.5 py-0.5 rounded-md bg-sky-500/10 border border-sky-500/20 text-[10px] font-mono text-sky-200">
            {entry.suggested_key}
            <span className="text-sky-400/70">· {entry.match_reason}</span>
          </span>
        )}
      </div>
    );
  }
  return (
    <div className="flex flex-col items-center gap-1">
      <span className="inline-flex items-center gap-1 text-gray-400 text-xs font-bold">
        <ImageOff className="w-3.5 h-3.5" /> Ícono genérico
      </span>
      {entry.suggested_key && (
        <span className="inline-flex items-center gap-1 px-1.5 py-0.5 rounded-md bg-white/5 border border-white/10 text-[10px] font-mono text-gray-300">
          {entry.suggested_key}
        </span>
      )}
    </div>
  );
};

const PendingTable = ({
  rows,
  storageBase,
}: {
  rows: PendingEntry[];
  storageBase: string;
}) => (
  <div className="glass rounded-2xl overflow-hidden">
    <div className="overflow-x-auto">
      <table className="w-full min-w-[820px]">
        <thead className="bg-white/5 border-b border-white/10 text-xs text-gray-400 uppercase tracking-wider">
          <tr>
            <th className="text-left px-4 py-3 font-bold w-16">Emoji</th>
            <th className="text-left px-4 py-3 font-bold">Producto</th>
            <th className="text-right px-4 py-3 font-bold">Veces</th>
            <th className="text-right px-4 py-3 font-bold">Hogares</th>
            <th className="text-right px-4 py-3 font-bold">Último</th>
            <th className="text-center px-4 py-3 font-bold w-48">Diagnóstico</th>
          </tr>
        </thead>
        <tbody className="text-sm divide-y divide-white/5">
          {rows.map((entry) => {
            const r = entry.row;
            const showIcon = entry.suggested_key && entry.status !== 'missing';
            return (
              <tr
                key={r.normalized_name}
                className="hover:bg-white/5 transition-colors"
              >
                <td className="px-4 py-3">
                  <div className="w-10 h-10 flex items-center justify-center text-2xl rounded-lg bg-white/5">
                    {r.primary_emoji && !isGenericEmoji(r.primary_emoji)
                      ? r.primary_emoji
                      : '🛒'}
                  </div>
                </td>
                <td className="px-4 py-3">
                  <div className="font-bold capitalize">{r.normalized_name}</div>
                  {r.variations.length > 1 && (
                    <div className="text-xs text-gray-500 mt-0.5">
                      {r.variations.slice(0, 3).join(' · ')}
                      {r.variations.length > 3 && ` · +${r.variations.length - 3}`}
                    </div>
                  )}
                  {showIcon && entry.suggested_key && (
                    <div className="flex items-center gap-2 mt-1.5">
                      <img
                        src={`${storageBase}/products/${entry.suggested_key}.png`}
                        alt={entry.suggested_key}
                        className="w-6 h-6 object-contain rounded bg-white/5"
                        loading="lazy"
                        onError={(e) => {
                          (e.currentTarget as HTMLImageElement).style.opacity = '0.2';
                        }}
                      />
                      <span className="text-[10px] text-gray-500">
                        el ícono que el usuario podría estar viendo
                      </span>
                    </div>
                  )}
                </td>
                <td className="px-4 py-3 text-right font-bold tabular-nums">
                  {r.times_added}
                </td>
                <td className="px-4 py-3 text-right text-gray-400 tabular-nums">
                  {r.households_using}
                </td>
                <td className="px-4 py-3 text-right text-gray-500 text-xs">
                  {fmtDate(r.last_added)}
                </td>
                <td className="px-4 py-3 text-center">
                  <PendingStatusChip entry={entry} />
                </td>
              </tr>
            );
          })}
        </tbody>
      </table>
    </div>
  </div>
);

type Tone = 'indigo' | 'emerald' | 'amber' | 'rose' | 'violet';

const StatCard = ({
  label,
  sublabel,
  value,
  icon: Icon,
  tone,
}: {
  label: string;
  sublabel?: string;
  value: number | string;
  icon: LucideIcon;
  tone: Tone;
}) => {
  const colors: Record<Tone, { bg: string; text: string; icon: string }> = {
    indigo: { bg: 'bg-indigo-500/10', text: 'text-indigo-300', icon: 'text-indigo-400' },
    emerald: {
      bg: 'bg-emerald-500/10',
      text: 'text-emerald-300',
      icon: 'text-emerald-400',
    },
    amber: { bg: 'bg-amber-500/10', text: 'text-amber-300', icon: 'text-amber-400' },
    rose: { bg: 'bg-rose-500/10', text: 'text-rose-300', icon: 'text-rose-400' },
    violet: { bg: 'bg-violet-500/10', text: 'text-violet-300', icon: 'text-violet-400' },
  };
  const c = colors[tone];
  return (
    <div className="glass p-5 rounded-2xl flex items-center gap-4">
      <div className={`p-3 rounded-xl ${c.bg}`}>
        <Icon className={`w-6 h-6 ${c.icon}`} />
      </div>
      <div className="min-w-0">
        <p className="text-xs text-gray-400 uppercase tracking-wider font-bold truncate">
          {label}
        </p>
        <p className={`text-2xl font-bold mt-1 ${c.text}`}>{value}</p>
        {sublabel && (
          <p className="text-[10px] text-gray-500 mt-0.5 truncate">{sublabel}</p>
        )}
      </div>
    </div>
  );
};

const OcrHealthBar = ({
  summary,
  unmatchedCount,
  droppedCount,
}: {
  summary: { totalScans: number; confirmRate: string; avgConf: string };
  unmatchedCount: number;
  droppedCount: number;
}) => (
  <div className="glass-dark border border-white/10 rounded-2xl px-4 py-3 flex flex-wrap items-center gap-4 md:gap-6">
    <div className="flex items-center gap-2 text-violet-300 shrink-0">
      <ScanLine className="w-4 h-4" />
      <span className="text-[11px] uppercase tracking-widest font-black">
        Salud del OCR (7d)
      </span>
    </div>
    <div className="flex items-center gap-1.5 text-sm">
      <span className="text-gray-400 text-xs">scans</span>
      <span className="font-bold text-white tabular-nums">
        {summary.totalScans}
      </span>
    </div>
    <div className="flex items-center gap-1.5 text-sm">
      <CheckCircle2 className="w-3.5 h-3.5 text-emerald-400" />
      <span className="text-gray-400 text-xs">confirmación</span>
      <span className="font-bold text-emerald-300 tabular-nums">
        {summary.confirmRate}%
      </span>
    </div>
    <div className="flex items-center gap-1.5 text-sm">
      <TrendingUp className="w-3.5 h-3.5 text-violet-400" />
      <span className="text-gray-400 text-xs">confianza IA</span>
      <span className="font-bold text-violet-300 tabular-nums">
        {summary.avgConf}
      </span>
    </div>
    <div className="flex items-center gap-1.5 text-sm">
      <AlertTriangle className="w-3.5 h-3.5 text-amber-400" />
      <span className="text-gray-400 text-xs">demanda cruda</span>
      <span className="font-bold text-amber-300 tabular-nums">
        {unmatchedCount + droppedCount}
      </span>
      <span className="text-[10px] text-gray-500">
        ({unmatchedCount} sin catálogo · {droppedCount} descartados)
      </span>
    </div>
    <Link
      to="/ocr-insights"
      className="ml-auto inline-flex items-center gap-1 text-[11px] font-bold text-secondary hover:text-white transition-colors"
    >
      Ver detalles en OCR Insights <ArrowRight className="w-3 h-3" />
    </Link>
  </div>
);

const OcrDemandPanel = ({
  unmatched,
  dropped,
  subTab,
  onSubTabChange,
}: {
  unmatched: OcrRawRow[];
  dropped: OcrRawRow[];
  subTab: OcrSubTab;
  onSubTabChange: (t: OcrSubTab) => void;
}) => (
  <div className="glass rounded-2xl overflow-hidden">
    <div className="flex border-b border-white/10 bg-white/5">
      <button
        onClick={() => onSubTabChange('unmatched')}
        className={`flex-1 flex items-center justify-center gap-2 px-4 py-3 text-sm font-bold transition-all ${
          subTab === 'unmatched'
            ? 'text-secondary border-b-2 border-secondary bg-white/5'
            : 'text-gray-400 hover:text-white'
        }`}
      >
        <Sparkles className="w-4 h-4" /> Sin catálogo ({unmatched.length})
      </button>
      <button
        onClick={() => onSubTabChange('dropped')}
        className={`flex-1 flex items-center justify-center gap-2 px-4 py-3 text-sm font-bold transition-all ${
          subTab === 'dropped'
            ? 'text-amber-300 border-b-2 border-amber-400 bg-white/5'
            : 'text-gray-400 hover:text-white'
        }`}
      >
        <AlertTriangle className="w-4 h-4" /> Descartados ({dropped.length})
      </button>
    </div>
    <div className="p-4">
      {subTab === 'unmatched' ? (
        <>
          <p className="text-xs text-gray-400 mb-3">
            Strings que la IA detectó en tickets pero el matcher no supo
            clasificar contra el catálogo. Candidatos a crear ícono nuevo o a
            ajustar la lógica del matcher.
          </p>
          <OcrRawTable rows={unmatched.slice(0, 20)} />
        </>
      ) : (
        <>
          <p className="text-xs text-gray-400 mb-3">
            Strings que el quality gate del OCR descartó como basura. Para ver
            el prompt completo y revisar las reglas, andá a{' '}
            <Link to="/ocr-insights" className="text-secondary font-bold">
              OCR Insights
            </Link>
            .
          </p>
          <OcrRawTable rows={dropped.slice(0, 20)} />
        </>
      )}
    </div>
  </div>
);

const OcrRawTable = ({ rows }: { rows: OcrRawRow[] }) => {
  if (rows.length === 0) {
    return (
      <EmptyState
        title="Sin datos en los últimos 60 días"
        description="Buen indicio: el matcher y el quality gate están haciendo bien su trabajo."
      />
    );
  }
  return (
    <div className="overflow-x-auto">
      <table className="w-full min-w-[600px]">
        <thead className="bg-white/5 text-xs text-gray-400 uppercase tracking-wider">
          <tr>
            <th className="text-left px-3 py-2 font-bold">Texto crudo</th>
            <th className="text-right px-3 py-2 font-bold">Apariciones</th>
            <th className="text-right px-3 py-2 font-bold">Usuarios</th>
            <th className="text-right px-3 py-2 font-bold">Última vez</th>
          </tr>
        </thead>
        <tbody className="text-sm divide-y divide-white/5">
          {rows.map((r) => (
            <tr key={r.raw_text} className="hover:bg-white/5 transition-colors">
              <td className="px-3 py-2 font-mono text-xs text-gray-200 max-w-md truncate">
                {r.raw_text}
              </td>
              <td className="px-3 py-2 text-right font-bold tabular-nums">
                {r.occurrences}
              </td>
              <td className="px-3 py-2 text-right text-gray-400 tabular-nums">
                {r.distinct_users}
              </td>
              <td className="px-3 py-2 text-right text-gray-500 text-xs">
                {fmtDate(r.last_seen)}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};
