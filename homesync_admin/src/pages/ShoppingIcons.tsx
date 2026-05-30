import { useEffect, useMemo, useState } from 'react';
import type { LucideIcon } from 'lucide-react';
import {
  ShoppingBag,
  Search,
  Sparkles,
  CheckCircle2,
  AlertTriangle,
  RefreshCcw,
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

interface EnrichedRow extends UsageRow {
  has_custom_icon: boolean;
  icon_version: string | null;
}

type Tab = 'missing' | 'all';

const BUCKET = 'shopping-icons';

export const ShoppingIcons = () => {
  const [rows, setRows] = useState<UsageRow[] | null>(null);
  const [manifest, setManifest] = useState<Record<string, string> | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [tab, setTab] = useState<Tab>('missing');
  const [query, setQuery] = useState('');
  const [loading, setLoading] = useState(false);

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
        .limit(500);
      const manifestUrl = `${storageBase}/manifest.json?t=${Date.now()}`;
      const manifestPromise = fetch(manifestUrl).then(async (r) => {
        if (!r.ok) throw new Error(`manifest fetch ${r.status}`);
        return (await r.json()) as Record<string, string>;
      });
      const [usageRes, manifestData] = await Promise.all([
        usagePromise,
        manifestPromise,
      ]);
      if (usageRes.error) throw usageRes.error;
      setRows((usageRes.data ?? []) as UsageRow[]);
      setManifest(manifestData);
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

  const enriched: EnrichedRow[] = useMemo(() => {
    if (!rows || !manifest) return [];
    return rows.map((r) => ({
      ...r,
      has_custom_icon: !!(r.primary_name_key && manifest[r.primary_name_key]),
      icon_version: r.primary_name_key ? manifest[r.primary_name_key] ?? null : null,
    }));
  }, [rows, manifest]);

  const stats = useMemo(() => {
    if (!enriched.length) return { total: 0, covered: 0, missing: 0 };
    const covered = enriched.filter((r) => r.has_custom_icon).length;
    return { total: enriched.length, covered, missing: enriched.length - covered };
  }, [enriched]);

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase();
    const base = tab === 'missing'
      ? enriched.filter((r) => !r.has_custom_icon)
      : enriched;
    if (!q) return base;
    return base.filter(
      (r) =>
        r.normalized_name.includes(q) ||
        r.variations.some((v) => v.toLowerCase().includes(q)) ||
        (r.primary_name_key?.toLowerCase().includes(q) ?? false)
    );
  }, [enriched, tab, query]);

  return (
    <div className="space-y-6 animate-in fade-in duration-500">
      <div className="flex flex-wrap items-start justify-between gap-4">
        <div>
          <h2 className="text-3xl font-bold tracking-tight flex items-center gap-3">
            <Sparkles className="w-7 h-7 text-secondary" /> Íconos de compras
          </h2>
          <p className="text-gray-400 mt-1 max-w-3xl">
            Productos agregados por usuarios (vía OCR o manual, últimos 90 días) cruzados con el
            manifest de íconos custom en Storage. Sirve para priorizar qué íconos hacer próximos
            en función del uso real.
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

      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <StatCard
          tone="indigo"
          label="Productos distintos (90d)"
          value={stats.total}
          icon={ShoppingBag}
        />
        <StatCard
          tone="emerald"
          label="Con ícono custom"
          value={stats.covered}
          icon={CheckCircle2}
        />
        <StatCard
          tone="amber"
          label="Sin ícono custom"
          value={stats.missing}
          icon={AlertTriangle}
        />
      </div>

      <div className="flex bg-white/5 border border-white/10 rounded-xl overflow-hidden">
        <button
          onClick={() => setTab('missing')}
          className={`flex items-center gap-2 px-6 py-2.5 text-sm font-bold transition-all flex-1 justify-center ${
            tab === 'missing'
              ? 'bg-amber-500/20 text-amber-300'
              : 'text-gray-400 hover:text-white'
          }`}
        >
          <AlertTriangle className="w-4 h-4" /> Sin ícono ({stats.missing})
        </button>
        <button
          onClick={() => setTab('all')}
          className={`flex items-center gap-2 px-6 py-2.5 text-sm font-bold transition-all flex-1 justify-center ${
            tab === 'all'
              ? 'bg-primary/20 text-secondary'
              : 'text-gray-400 hover:text-white'
          }`}
        >
          <ShoppingBag className="w-4 h-4" /> Todos ({stats.total})
        </button>
      </div>

      <div className="relative">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
        <input
          type="text"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Buscar por nombre, variante o nameKey..."
          className="w-full bg-white/5 border border-white/10 rounded-xl pl-10 pr-4 py-2.5 text-sm placeholder-gray-500 focus:outline-none focus:border-primary/50"
        />
      </div>

      {loading && !rows && <LoadingState title="Cargando productos..." />}
      {error && <ErrorState title="Error cargando datos" description={error} />}
      {!loading && rows && filtered.length === 0 && (
        <EmptyState
          title={
            tab === 'missing'
              ? '¡Todo cubierto en este filtro!'
              : 'Sin productos en los últimos 90 días'
          }
          description={
            tab === 'missing'
              ? 'No hay productos sin ícono custom que coincidan con la búsqueda.'
              : undefined
          }
        />
      )}
      {filtered.length > 0 && (
        <div className="glass rounded-2xl overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full min-w-[720px]">
              <thead className="bg-white/5 border-b border-white/10 text-xs text-gray-400 uppercase tracking-wider">
                <tr>
                  <th className="text-left px-4 py-3 font-bold w-16">Ícono</th>
                  <th className="text-left px-4 py-3 font-bold">Producto</th>
                  <th className="text-left px-4 py-3 font-bold">nameKey</th>
                  <th className="text-right px-4 py-3 font-bold">Veces</th>
                  <th className="text-right px-4 py-3 font-bold">Hogares</th>
                  <th className="text-right px-4 py-3 font-bold">Último</th>
                  <th className="text-center px-4 py-3 font-bold w-24">Estado</th>
                </tr>
              </thead>
              <tbody className="text-sm divide-y divide-white/5">
                {filtered.map((r) => (
                  <tr
                    key={r.normalized_name}
                    className="hover:bg-white/5 transition-colors"
                  >
                    <td className="px-4 py-3">
                      {r.has_custom_icon && r.primary_name_key ? (
                        <img
                          src={`${storageBase}/products/${r.primary_name_key}.png?v=${r.icon_version}`}
                          alt={r.normalized_name}
                          className="w-10 h-10 object-contain"
                          loading="lazy"
                        />
                      ) : (
                        <div className="w-10 h-10 flex items-center justify-center text-2xl">
                          {r.primary_emoji || '🛒'}
                        </div>
                      )}
                    </td>
                    <td className="px-4 py-3">
                      <div className="font-bold capitalize">{r.normalized_name}</div>
                      {r.variations.length > 1 && (
                        <div className="text-xs text-gray-500 mt-0.5">
                          {r.variations.slice(0, 3).join(' · ')}
                          {r.variations.length > 3 && ` · +${r.variations.length - 3}`}
                        </div>
                      )}
                    </td>
                    <td className="px-4 py-3 font-mono text-xs">
                      {r.primary_name_key ? (
                        <span className="text-gray-300">{r.primary_name_key}</span>
                      ) : (
                        <span className="text-rose-400/70">— sin clave —</span>
                      )}
                    </td>
                    <td className="px-4 py-3 text-right font-bold tabular-nums">
                      {r.times_added}
                    </td>
                    <td className="px-4 py-3 text-right text-gray-400 tabular-nums">
                      {r.households_using}
                    </td>
                    <td className="px-4 py-3 text-right text-gray-500 text-xs">
                      {new Date(r.last_added).toLocaleDateString('es-AR')}
                    </td>
                    <td className="px-4 py-3 text-center">
                      {r.has_custom_icon ? (
                        <span className="inline-flex items-center gap-1 text-emerald-400 text-xs font-bold">
                          <CheckCircle2 className="w-3.5 h-3.5" /> OK
                        </span>
                      ) : (
                        <span className="inline-flex items-center gap-1 text-amber-400 text-xs font-bold">
                          <AlertTriangle className="w-3.5 h-3.5" /> Falta
                        </span>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  );
};

type Tone = 'indigo' | 'emerald' | 'amber';

const StatCard = ({
  label,
  value,
  icon: Icon,
  tone,
}: {
  label: string;
  value: number;
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
  };
  const c = colors[tone];
  return (
    <div className="glass p-5 rounded-2xl flex items-center gap-4">
      <div className={`p-3 rounded-xl ${c.bg}`}>
        <Icon className={`w-6 h-6 ${c.icon}`} />
      </div>
      <div>
        <p className="text-xs text-gray-400 uppercase tracking-wider font-bold">{label}</p>
        <p className={`text-2xl font-bold mt-1 ${c.text}`}>{value}</p>
      </div>
    </div>
  );
};
