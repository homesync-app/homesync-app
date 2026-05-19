import { useCallback, useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import {
  Users as UsersIcon,
  Crown,
  User,
  Shield,
  Calendar,
  Search,
  Mail,
} from 'lucide-react';
import { EmptyState, ErrorState, LoadingState } from '../components/PageState';

interface HouseholdMember {
  id: string;
  user_id: string;
  role: string;
  joined_at: string;
  household: {
    id: string;
    name: string;
  } | null;
  user: {
    full_name: string | null;
    avatar_url: string | null;
  } | null;
}

interface AppUser {
  id: string;
  email: string | null;
  full_name: string | null;
  avatar_url: string | null;
  firebase_uid: string | null;
  is_admin: boolean | null;
  created_at: string;
  householdMemberships: HouseholdMember[];
}

export const UserManagement = () => {
  const [users, setUsers] = useState<AppUser[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [error, setError] = useState<string | null>(null);

  const fetchUsers = useCallback(async () => {
    setLoading(true);
    setError(null);

    const [
      { data: usersData, error: usersError },
      { data: membersData, error: membersError },
    ] = await Promise.all([
      supabase
        .from('users')
        .select('id, email, full_name, avatar_url, firebase_uid, is_admin, created_at')
        .order('created_at', { ascending: false })
        .limit(500),
      supabase
        .from('household_members')
        .select(`
          *,
          household:households(id, name),
          user:users(full_name, avatar_url)
        `)
        .order('joined_at', { ascending: false })
        .limit(1000),
    ]);

    if (usersError || membersError) {
      setError(usersError?.message ?? membersError?.message ?? 'No pudimos cargar usuarios.');
      setLoading(false);
      return;
    }

    const membershipsByUser = new Map<string, HouseholdMember[]>();
    ((membersData ?? []) as HouseholdMember[]).forEach((membership) => {
      const current = membershipsByUser.get(membership.user_id) ?? [];
      membershipsByUser.set(membership.user_id, [...current, membership]);
    });

    setUsers(
      ((usersData ?? []) as Omit<AppUser, 'householdMemberships'>[]).map((appUser) => ({
        ...appUser,
        householdMemberships: membershipsByUser.get(appUser.id) ?? [],
      })),
    );
    setLoading(false);
  }, []);

  useEffect(() => {
    const timeoutId = window.setTimeout(() => {
      void fetchUsers();
    }, 0);
    return () => window.clearTimeout(timeoutId);
  }, [fetchUsers]);

  const filteredUsers = users.filter((appUser) => {
    const query = search.toLowerCase();
    return (
      appUser.full_name?.toLowerCase().includes(query) ||
      appUser.email?.toLowerCase().includes(query) ||
      appUser.firebase_uid?.toLowerCase().includes(query) ||
      appUser.householdMemberships.some((membership) =>
        membership.household?.name?.toLowerCase().includes(query),
      )
    );
  });

  return (
    <div className="space-y-8 animate-in fade-in duration-500">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h2 className="text-3xl font-bold tracking-tight">User Management</h2>
          <p className="text-gray-400 mt-1">
            Monitor app users, households, roles, and onboarding gaps.
          </p>
        </div>

        <div className="flex items-center gap-3">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-500" />
            <input
              type="text"
              placeholder="Search users..."
              className="bg-white/5 border border-white/10 rounded-xl py-2 pl-10 pr-4 focus:outline-none focus:ring-2 focus:ring-primary/50 text-sm"
              value={search}
              onChange={(event) => setSearch(event.target.value)}
            />
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
        {loading ? (
          <div className="col-span-full">
            <LoadingState title="Cargando usuarios..." />
          </div>
        ) : error ? (
          <div className="col-span-full">
            <ErrorState title="Error al cargar usuarios" description={error} />
          </div>
        ) : filteredUsers.length === 0 ? (
          <div className="col-span-full">
            <EmptyState
              title="No hay usuarios para mostrar"
              description="Revisa el filtro o la configuración de acceso admin."
            />
          </div>
        ) : (
          filteredUsers.map((appUser) => {
            const primaryMembership = appUser.householdMemberships[0];
            const role = primaryMembership?.role ?? (appUser.is_admin ? 'admin' : 'sin hogar');

            return (
              <div key={appUser.id} className="glass p-6 rounded-3xl relative group overflow-hidden">
                <div className="absolute top-4 right-4">
                  <div
                    className={`flex items-center gap-1.5 px-3 py-1 rounded-full text-[10px] font-bold uppercase tracking-wider border ${
                      role === 'owner'
                        ? 'bg-amber-500/10 text-amber-500 border-amber-500/20'
                        : role === 'sin hogar'
                          ? 'bg-rose-500/10 text-rose-400 border-rose-500/20'
                          : 'bg-indigo-500/10 text-indigo-400 border-indigo-500/20'
                    }`}
                  >
                    {role === 'owner' ? <Crown className="w-3 h-3" /> : <User className="w-3 h-3" />}
                    {role}
                  </div>
                </div>

                <div className="flex items-center gap-4 mb-6 pr-20">
                  <div className="w-14 h-14 rounded-2xl bg-white/5 border border-white/10 flex items-center justify-center relative">
                    {appUser.avatar_url ? (
                      <img
                        src={appUser.avatar_url}
                        alt=""
                        className="w-full h-full rounded-2xl object-cover"
                      />
                    ) : (
                      <UsersIcon className="w-6 h-6 text-primary" />
                    )}
                    <div className="absolute -bottom-1 -right-1 w-4 h-4 bg-emerald-500 border-2 border-[#0f172a] rounded-full" />
                  </div>
                  <div className="min-w-0">
                    <h4 className="font-bold text-lg leading-tight truncate">
                      {appUser.full_name || 'Anonymous'}
                    </h4>
                    <div className="flex items-center gap-1.5 text-gray-500 text-xs mt-1">
                      <Shield className="w-3 h-3 text-secondary" />
                      <span>ID: ...{appUser.id.slice(-6)}</span>
                    </div>
                  </div>
                </div>

                <div className="space-y-3">
                  <div className="flex items-center gap-3 px-3 py-2 rounded-xl bg-white/5 border border-white/5">
                    <div className="p-1.5 rounded-lg bg-indigo-500/10 text-indigo-400">
                      <UsersIcon className="w-4 h-4" />
                    </div>
                    <div>
                      <p className="text-[10px] text-gray-500 font-bold uppercase tracking-tighter">
                        Household
                      </p>
                      <p className="text-sm font-semibold">
                        {primaryMembership?.household?.name || 'Sin hogar asignado'}
                      </p>
                      {appUser.householdMemberships.length > 1 && (
                        <p className="text-xs text-gray-500 mt-0.5">
                          +{appUser.householdMemberships.length - 1} hogar
                          {appUser.householdMemberships.length > 2 ? 'es' : ''} más
                        </p>
                      )}
                    </div>
                  </div>

                  <div className="flex items-center gap-3 px-3 py-2 rounded-xl bg-white/5 border border-white/5">
                    <div className="p-1.5 rounded-lg bg-secondary/10 text-secondary">
                      <Calendar className="w-4 h-4" />
                    </div>
                    <div>
                      <p className="text-[10px] text-gray-500 font-bold uppercase tracking-tighter">
                        {primaryMembership ? 'Joined Date' : 'Created Date'}
                      </p>
                      <p className="text-sm font-semibold">
                        {new Date(primaryMembership?.joined_at ?? appUser.created_at).toLocaleDateString()}
                      </p>
                    </div>
                  </div>

                  <div className="flex items-center gap-3 px-3 py-2 rounded-xl bg-white/5 border border-white/5">
                    <div className="p-1.5 rounded-lg bg-primary/10 text-primary">
                      <Mail className="w-4 h-4" />
                    </div>
                    <div className="min-w-0">
                      <p className="text-[10px] text-gray-500 font-bold uppercase tracking-tighter">
                        Email
                      </p>
                      <p className="text-sm font-semibold truncate">{appUser.email || 'Sin email'}</p>
                    </div>
                  </div>
                </div>
              </div>
            );
          })
        )}
      </div>
    </div>
  );
};
