import { useCallback, useEffect, useRef, useState } from 'react';
import {
  Users as UsersIcon,
  Crown,
  User,
  Shield,
  Search,
  Loader2,
  Sparkles,
  Star,
  Mail,
  Home as HomeIcon,
} from 'lucide-react';
import { EmptyState, ErrorState, LoadingState } from '../components/PageState';
import {
  adminSearchUsers,
  adminSetHouseholdPremium,
  type AdminUserRow,
} from '../lib/adminApi';

const PREMIUM_DAYS = 365;

function premiumLabel(row: AdminUserRow): string {
  if (!row.household_is_premium) return 'Free';
  if (!row.premium_until) return 'Premium';
  const until = new Date(row.premium_until);
  return `Premium · hasta ${until.toLocaleDateString('es-AR')}`;
}

export const UserManagement = () => {
  const [query, setQuery] = useState('');
  const [rows, setRows] = useState<AdminUserRow[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [hasSearched, setHasSearched] = useState(false);
  const [togglingHousehold, setTogglingHousehold] = useState<string | null>(null);
  const [toast, setToast] = useState<{ type: 'success' | 'error'; text: string } | null>(null);
  const debounceRef = useRef<number | null>(null);

  const runSearch = useCallback(async (q: string) => {
    const trimmed = q.trim();
    if (trimmed.length < 2) {
      setRows([]);
      setHasSearched(false);
      return;
    }
    setLoading(true);
    setError(null);
    try {
      const result = await adminSearchUsers(trimmed);
      setRows(result);
      setHasSearched(true);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'No pudimos buscar usuarios.');
    } finally {
      setLoading(false);
    }
  }, []);

  // Debounced search as the admin types.
  useEffect(() => {
    if (debounceRef.current) window.clearTimeout(debounceRef.current);
    debounceRef.current = window.setTimeout(() => void runSearch(query), 350);
    return () => {
      if (debounceRef.current) window.clearTimeout(debounceRef.current);
    };
  }, [query, runSearch]);

  useEffect(() => {
    if (!toast) return;
    const id = window.setTimeout(() => setToast(null), 3500);
    return () => window.clearTimeout(id);
  }, [toast]);

  const handleTogglePremium = async (row: AdminUserRow) => {
    if (!row.household_id) {
      setToast({ type: 'error', text: 'Este usuario no tiene un hogar al que aplicar premium.' });
      return;
    }
    const next = !row.household_is_premium;
    const until = next
      ? new Date(Date.now() + PREMIUM_DAYS * 24 * 60 * 60 * 1000).toISOString()
      : null;

    setTogglingHousehold(row.household_id);
    try {
      await adminSetHouseholdPremium(row.household_id, next, until);
      // Reflect the change on every row sharing this household.
      setRows((prev) =>
        prev.map((r) =>
          r.household_id === row.household_id
            ? {
                ...r,
                household_is_premium: next,
                plan_tier: next
                  ? r.household_type === 'couple'
                    ? 'couple_premium'
                    : 'group_premium'
                  : 'free',
                premium_until: until,
              }
            : r,
        ),
      );
      setToast({
        type: 'success',
        text: next
          ? `Premium activado para ${row.household_name ?? 'el hogar'}.`
          : `Premium desactivado para ${row.household_name ?? 'el hogar'}.`,
      });
    } catch (e) {
      setToast({
        type: 'error',
        text: e instanceof Error ? e.message : 'No se pudo actualizar el premium.',
      });
    } finally {
      setTogglingHousehold(null);
    }
  };

  return (
    <div className="space-y-8 animate-in fade-in duration-500">
      <div className="flex flex-col md:flex-row md:items-start justify-between gap-4">
        <div>
          <h2 className="text-3xl font-bold tracking-tight flex items-center gap-3">
            <UsersIcon className="w-8 h-8 text-indigo-400" />
            Usuarios
          </h2>
          <p className="text-gray-400 mt-1">
            Buscá cualquier usuario por email o nombre y gestioná el premium de su hogar.
          </p>
        </div>
      </div>

      <div className="relative max-w-xl">
        <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-500" />
        <input
          type="text"
          autoFocus
          placeholder="Buscar por email o nombre (mín. 2 caracteres)..."
          className="w-full bg-white/5 border border-white/10 rounded-2xl py-3 pl-12 pr-12 focus:outline-none focus:ring-2 focus:ring-primary/50 transition-all"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
        />
        {loading && (
          <Loader2 className="absolute right-4 top-1/2 -translate-y-1/2 w-5 h-5 text-primary animate-spin" />
        )}
      </div>

      {toast && (
        <div
          className={`flex items-center gap-2 px-4 py-3 rounded-xl text-sm font-medium ${
            toast.type === 'success'
              ? 'bg-emerald-500/10 border border-emerald-500/20 text-emerald-300'
              : 'bg-rose-500/10 border border-rose-500/20 text-rose-300'
          }`}
        >
          {toast.text}
        </div>
      )}

      {error && <ErrorState title="Error en la búsqueda" description={error} />}

      {!error && loading && rows.length === 0 && <LoadingState title="Buscando usuarios..." />}

      {!error && !loading && !hasSearched && query.trim().length < 2 && (
        <EmptyState
          title="Buscá un usuario"
          description="Escribí al menos 2 caracteres de un email o nombre para empezar."
        />
      )}

      {!error && !loading && hasSearched && rows.length === 0 && (
        <EmptyState
          title="Sin resultados"
          description="Ningún usuario coincide con esa búsqueda."
        />
      )}

      {rows.length > 0 && (
        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
          {rows.map((row) => (
            <div
              key={`${row.user_id}-${row.household_id ?? 'no-hh'}`}
              className="glass p-6 rounded-3xl relative group overflow-hidden"
            >
              <div className="absolute top-4 right-4 flex items-center gap-2">
                {row.is_admin && (
                  <span className="flex items-center gap-1 px-2.5 py-1 rounded-full text-[10px] font-bold uppercase tracking-wider border bg-secondary/10 text-secondary border-secondary/20">
                    <Shield className="w-3 h-3" /> Admin
                  </span>
                )}
                {row.household_role && (
                  <span
                    className={`flex items-center gap-1.5 px-3 py-1 rounded-full text-[10px] font-bold uppercase tracking-wider border ${
                      row.household_role === 'owner'
                        ? 'bg-amber-500/10 text-amber-500 border-amber-500/20'
                        : 'bg-indigo-500/10 text-indigo-400 border-indigo-500/20'
                    }`}
                  >
                    {row.household_role === 'owner' ? <Crown className="w-3 h-3" /> : <User className="w-3 h-3" />}
                    {row.household_role}
                  </span>
                )}
              </div>

              <div className="flex items-center gap-4 mb-5">
                <div className="w-14 h-14 rounded-2xl bg-white/5 border border-white/10 flex items-center justify-center overflow-hidden shrink-0">
                  {row.avatar_url && row.avatar_url.startsWith('http') ? (
                    <img src={row.avatar_url} alt="" className="w-full h-full rounded-2xl object-cover" />
                  ) : row.avatar_url ? (
                    <span className="text-2xl">{row.avatar_url}</span>
                  ) : (
                    <UsersIcon className="w-6 h-6 text-primary" />
                  )}
                </div>
                <div className="min-w-0">
                  <h4 className="font-bold text-lg leading-tight truncate">
                    {row.full_name || 'Sin nombre'}
                  </h4>
                  <div className="flex items-center gap-1.5 text-gray-400 text-xs mt-1 min-w-0">
                    <Mail className="w-3 h-3 shrink-0" />
                    <span className="truncate">{row.email || '—'}</span>
                  </div>
                </div>
              </div>

              <div className="space-y-3">
                <div className="flex items-center gap-3 px-3 py-2 rounded-xl bg-white/5 border border-white/5">
                  <div className="p-1.5 rounded-lg bg-indigo-500/10 text-indigo-400">
                    <HomeIcon className="w-4 h-4" />
                  </div>
                  <div className="min-w-0">
                    <p className="text-[10px] text-gray-500 font-bold uppercase tracking-tighter">Hogar</p>
                    <p className="text-sm font-semibold truncate">
                      {row.household_name || 'Sin hogar'}
                      {row.household_type ? ` · ${row.household_type}` : ''}
                    </p>
                  </div>
                </div>

                <div
                  className={`flex items-center gap-3 px-3 py-2 rounded-xl border ${
                    row.household_is_premium
                      ? 'bg-amber-500/10 border-amber-500/20'
                      : 'bg-white/5 border-white/5'
                  }`}
                >
                  <div
                    className={`p-1.5 rounded-lg ${
                      row.household_is_premium
                        ? 'bg-amber-500/20 text-amber-400'
                        : 'bg-white/10 text-gray-400'
                    }`}
                  >
                    <Star className="w-4 h-4" />
                  </div>
                  <div className="min-w-0">
                    <p className="text-[10px] text-gray-500 font-bold uppercase tracking-tighter">Plan</p>
                    <p className="text-sm font-semibold truncate">{premiumLabel(row)}</p>
                  </div>
                </div>
              </div>

              <button
                onClick={() => void handleTogglePremium(row)}
                disabled={!row.household_id || togglingHousehold === row.household_id}
                className={`mt-4 w-full py-2.5 rounded-xl text-sm font-bold flex items-center justify-center gap-2 transition-all disabled:opacity-40 disabled:cursor-not-allowed ${
                  row.household_is_premium
                    ? 'bg-white/5 border border-white/10 text-gray-200 hover:bg-white/10'
                    : 'bg-amber-500 text-black hover:opacity-90 glow-amber'
                }`}
                title={!row.household_id ? 'El usuario no tiene un hogar' : undefined}
              >
                {togglingHousehold === row.household_id ? (
                  <Loader2 className="w-4 h-4 animate-spin" />
                ) : row.household_is_premium ? (
                  'Quitar premium del hogar'
                ) : (
                  <>
                    <Sparkles className="w-4 h-4" />
                    Hacer hogar premium ({PREMIUM_DAYS}d)
                  </>
                )}
              </button>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};
