import { useCallback, useEffect, useMemo, useState } from 'react';
import { supabase } from '../lib/supabase';
import {
  Home as HomeIcon,
  Users,
  Crown,
  Calendar,
  Search,
  Activity,
} from 'lucide-react';
import { EmptyState, ErrorState, LoadingState } from '../components/PageState';

interface Household {
  id: string;
  name: string;
  household_type: string;
  created_at: string;
  member_count: number;
  owner_name: string | null;
}

export const Households = () => {
  const [households, setHouseholds] = useState<Household[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [selectedId, setSelectedId] = useState<string | null>(null);

  const fetchHouseholds = useCallback(async () => {
    setLoading(true);
    setError(null);

    const { data, error: fetchError } = await supabase
      .from('households')
      .select('id, name, household_type, created_at')
      .order('created_at', { ascending: false });

    if (fetchError || !data) {
      setError('No pudimos cargar los hogares.');
      setLoading(false);
      return;
    }

    const householdIds = data.map((h: { id: string }) => h.id);

    const { data: members } = await supabase
      .from('household_members')
      .select('household_id, role, user:users(full_name)')
      .in('household_id', householdIds);

    const memberMap = new Map<string, { count: number; ownerName: string | null }>();
    for (const m of (members as Record<string, unknown>[]) || []) {
      const hid = m.household_id as string;
      if (!memberMap.has(hid)) {
        memberMap.set(hid, { count: 0, ownerName: null });
      }
      const entry = memberMap.get(hid)!;
      entry.count++;
      if (m.role === 'owner') {
        const user = m.user as Record<string, unknown> | null;
        entry.ownerName = (user?.full_name as string) || null;
      }
    }

    const mapped: Household[] = data.map((h: Record<string, unknown>) => {
      const info = memberMap.get(h.id as string) || { count: 0, ownerName: null };
      return {
        id: h.id as string,
        name: h.name as string,
        household_type: h.household_type as string,
        created_at: h.created_at as string,
        member_count: info.count,
        owner_name: info.ownerName,
      };
    });

    setHouseholds(mapped);
    setLoading(false);
  }, []);

  useEffect(() => {
    const id = window.setTimeout(() => void fetchHouseholds(), 0);
    return () => window.clearTimeout(id);
  }, [fetchHouseholds]);

  const filtered = households.filter(
    (h) =>
      h.name.toLowerCase().includes(search.toLowerCase()) ||
      (h.owner_name && h.owner_name.toLowerCase().includes(search.toLowerCase()))
  );

  const typeIcon: Record<string, string> = {
    solo: '\u{1F464}',
    couple: '\u{2764}\u{FE0F}',
    friends: '\u{1F389}',
    family: '\u{1F468}\u{200D}\u{1F469}\u{200D}\u{1F467}\u{200D}\u{1F466}',
  };

  const typeColor: Record<string, string> = {
    solo: 'bg-blue-500/10 text-blue-400 border-blue-500/20',
    couple: 'bg-pink-500/10 text-pink-400 border-pink-500/20',
    friends: 'bg-orange-500/10 text-orange-400 border-orange-500/20',
    family: 'bg-green-500/10 text-green-400 border-green-500/20',
  };

  const timeAgo = useCallback((date: string) => {
    const diff = Date.now() - new Date(date).getTime();
    const hours = Math.floor(diff / 3600000);
    if (hours < 1) return `${Math.floor(diff / 60000)}m`;
    if (hours < 24) return `${hours}h`;
    return `${Math.floor(hours / 24)}d`;
  }, []);

  const [now] = useState(() => Date.now());

  const totalMembers = households.reduce((a, h) => a + h.member_count, 0);
  const recentCount = useMemo(() => {
    return households.filter((h) => {
      const diff = now - new Date(h.created_at).getTime();
      return diff < 7 * 24 * 3600000;
    }).length;
  }, [households, now]);

  return (
    <div className="space-y-8 animate-in fade-in duration-500">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h2 className="text-3xl font-bold tracking-tight flex items-center gap-3">
            <HomeIcon className="w-8 h-8 text-indigo-400" />
            Hogares
          </h2>
          <p className="text-gray-400 mt-1">
            Explor\u00e1 cada hogar: miembros, balance de tareas, actividad y salud.
          </p>
        </div>

        <div className="flex items-center gap-3">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-500" />
            <input
              type="text"
              placeholder="Buscar por nombre o due\u00f1o..."
              className="bg-white/5 border border-white/10 rounded-xl py-2 pl-10 pr-4 focus:outline-none focus:ring-2 focus:ring-primary/50 text-sm"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
          </div>
        </div>
      </div>

      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        <div className="glass-dark rounded-2xl p-5 border border-white/5">
          <div className="text-indigo-400 mb-2"><HomeIcon className="w-5 h-5" /></div>
          <p className="text-2xl font-bold">{loading ? '\u2014' : households.length}</p>
          <p className="text-xs text-gray-500 mt-1">Total hogares</p>
        </div>
        <div className="glass-dark rounded-2xl p-5 border border-white/5">
          <div className="text-pink-400 mb-2"><Users className="w-5 h-5" /></div>
          <p className="text-2xl font-bold">{loading ? '\u2014' : totalMembers}</p>
          <p className="text-xs text-gray-500 mt-1">Total miembros</p>
        </div>
        <div className="glass-dark rounded-2xl p-5 border border-white/5">
          <div className="text-emerald-400 mb-2"><Activity className="w-5 h-5" /></div>
          <p className="text-2xl font-bold">{loading ? '\u2014' : recentCount}</p>
          <p className="text-xs text-gray-500 mt-1">Creados esta semana</p>
        </div>
        <div className="glass-dark rounded-2xl p-5 border border-white/5">
          <div className="text-amber-400 mb-2"><Crown className="w-5 h-5" /></div>
          <p className="text-2xl font-bold">
            {loading ? '\u2014' : new Set(households.map((h) => h.household_type)).size}
          </p>
          <p className="text-xs text-gray-500 mt-1">Tipos de hogar</p>
        </div>
      </div>

      {error && <ErrorState title="Error al cargar hogares" description={error} />}

      {loading ? (
        <LoadingState title="Cargando hogares..." />
      ) : filtered.length === 0 ? (
        <EmptyState
          title="Sin hogares"
          description={search ? 'Prob\u00e1 con otra b\u00fasqueda.' : 'Los hogares creados aparecer\u00e1n aqu\u00ed.'}
        />
      ) : (
        <div className="space-y-3">
          {filtered.map((h) => (
            <button
              key={h.id}
              onClick={() => setSelectedId(selectedId === h.id ? null : h.id)}
              className={`w-full glass-dark rounded-2xl border transition-all duration-200 overflow-hidden text-left ${
                selectedId === h.id ? 'border-primary/30' : 'border-white/5 hover:border-white/15'
              }`}
            >
              <div className="px-5 py-4 flex items-center gap-4">
                <div className="w-12 h-12 rounded-xl bg-white/5 flex items-center justify-center text-2xl">
                  {typeIcon[h.household_type] || '\u{1F3E0}'}
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-bold truncate text-white/90">{h.name}</p>
                  <div className="flex items-center gap-3 mt-1 flex-wrap">
                    <span className="text-xs text-gray-500 flex items-center gap-1">
                      <Users className="w-3 h-3" />
                      {h.member_count} miembro{h.member_count !== 1 ? 's' : ''}
                    </span>
                    <span className="text-xs text-gray-500 flex items-center gap-1">
                      <Calendar className="w-3 h-3" />
                      {timeAgo(h.created_at)}
                    </span>
                    {h.owner_name && (
                      <span className="text-xs text-gray-500 flex items-center gap-1">
                        <Crown className="w-3 h-3" />
                        {h.owner_name}
                      </span>
                    )}
                  </div>
                </div>
                <div className="flex items-center gap-3 flex-shrink-0">
                  <span
                    className={`text-[10px] uppercase font-bold px-2.5 py-1 rounded-full border ${
                      typeColor[h.household_type] || 'bg-white/10 text-gray-400 border-white/20'
                    }`}
                  >
                    {h.household_type}
                  </span>
                </div>
              </div>
            </button>
          ))}
        </div>
      )}
    </div>
  );
};
