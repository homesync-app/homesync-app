import { useCallback, useEffect, useState } from 'react';
import type { LucideIcon } from 'lucide-react';
import {
  Users,
  CheckCircle2,
  AlertTriangle,
  TrendingUp,
  Activity,
  Zap,
  Loader2,
  Calendar,
} from 'lucide-react';
import { supabase } from '../lib/supabase';
import { EmptyState, ErrorState, LoadingState } from '../components/PageState';

type Tone = 'indigo' | 'emerald' | 'rose' | 'amber';

interface DashboardStats {
  households: number;
  tasksToday: number;
  alerts: number;
  totalCoins: number;
}

interface ActivityItem {
  id: string;
  created_at: string;
  activity_type?: string;
  title?: string;
  metadata?: {
    title?: string;
    xp_reward?: number;
  };
}

const toneClass: Record<Tone, { halo: string; icon: string }> = {
  indigo: { halo: 'bg-indigo-500/10', icon: 'bg-indigo-500/10 text-indigo-500' },
  emerald: { halo: 'bg-emerald-500/10', icon: 'bg-emerald-500/10 text-emerald-500' },
  rose: { halo: 'bg-rose-500/10', icon: 'bg-rose-500/10 text-rose-500' },
  amber: { halo: 'bg-amber-500/10', icon: 'bg-amber-500/10 text-amber-500' },
};

const StatCard = ({
  title,
  value,
  icon: Icon,
  tone,
  loading,
}: {
  title: string;
  value: string | number;
  icon: LucideIcon;
  tone: Tone;
  loading: boolean;
}) => (
  <div className="glass p-6 rounded-3xl relative overflow-hidden group">
    <div
      className={`absolute top-0 right-0 w-32 h-32 rounded-full blur-3xl -mr-16 -mt-16 transition-all duration-500 group-hover:scale-150 ${toneClass[tone].halo}`}
    />
    <div className="flex justify-between items-start mb-4">
      <div className={`p-3 rounded-2xl ${toneClass[tone].icon}`}>
        <Icon className="w-6 h-6" />
      </div>
      <div className="flex items-center gap-1 text-emerald-400 text-xs font-bold bg-emerald-400/10 px-2 py-1 rounded-full">
        <TrendingUp className="w-3 h-3" />
        Live
      </div>
    </div>
    <p className="text-gray-400 text-sm font-medium">{title}</p>
    {loading ? (
      <Loader2 className="w-6 h-6 animate-spin text-gray-500 mt-2" />
    ) : (
      <h3 className="text-3xl font-bold mt-1">{value}</h3>
    )}
  </div>
);

export const Dashboard = () => {
  const [stats, setStats] = useState<DashboardStats>({
    households: 0,
    tasksToday: 0,
    alerts: 0,
    totalCoins: 0,
  });
  const [activities, setActivities] = useState<ActivityItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchDashboardData = useCallback(async () => {
    setLoading(true);
    setError(null);
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const [households, tasksToday, alerts, ledgerRes, activityStream] = await Promise.all([
      supabase.from('households').select('*', { count: 'exact', head: true }),
      supabase
        .from('tasks')
        .select('*', { count: 'exact', head: true })
        .eq('status', 'verified')
        .gte('updated_at', today.toISOString()),
      supabase.from('application_logs').select('*', { count: 'exact', head: true }).eq('level', 'error'),
      supabase.from('ledger_entries').select('amount').eq('type', 'coins_earned'),
      supabase.from('household_activities').select('*').order('created_at', { ascending: false }).limit(5),
    ]);

    if (households.error || tasksToday.error || alerts.error || ledgerRes.error || activityStream.error) {
      setError('No pudimos cargar el overview. Intenta de nuevo.');
      setLoading(false);
      return;
    }

    const totalCoins =
      ledgerRes.data?.reduce((acc: number, curr: { amount?: number }) => acc + (curr.amount || 0), 0) || 0;

    setStats({
      households: households.count || 0,
      tasksToday: tasksToday.count || 0,
      alerts: alerts.count || 0,
      totalCoins,
    });
    setActivities((activityStream.data || []) as ActivityItem[]);
    setLoading(false);
  }, []);

  useEffect(() => {
    const timeoutId = window.setTimeout(() => {
      void fetchDashboardData();
    }, 0);
    return () => window.clearTimeout(timeoutId);
  }, [fetchDashboardData]);

  return (
    <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-700">
      <div className="flex justify-between items-end">
        <div>
          <h2 className="text-3xl font-bold tracking-tight">System Overview</h2>
          <p className="text-gray-400 mt-1">Real-time heuristics and household performance metrics.</p>
        </div>
        <button
          onClick={fetchDashboardData}
          className="p-2 bg-white/5 border border-white/10 rounded-xl hover:bg-white/10 transition-colors"
        >
          <Activity className={`w-5 h-5 ${loading ? 'animate-pulse text-primary' : ''}`} />
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCard title="Active Households" value={stats.households} icon={Users} tone="indigo" loading={loading} />
        <StatCard title="Tasks Completed Today" value={stats.tasksToday} icon={CheckCircle2} tone="emerald" loading={loading} />
        <StatCard title="Critical Alerts" value={stats.alerts} icon={AlertTriangle} tone="rose" loading={loading} />
        <StatCard title="Circulating Coins" value={stats.totalCoins.toLocaleString()} icon={Zap} tone="amber" loading={loading} />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <div className="lg:col-span-2 glass-dark p-8 rounded-3xl border border-white/5">
          <h3 className="text-xl font-bold flex items-center gap-2 mb-8">
            <Activity className="w-5 h-5 text-secondary" />
            Recent Activity
          </h3>

          <div className="space-y-6">
            {error ? (
              <ErrorState title="Error al cargar actividad" description={error} />
            ) : loading ? (
              <LoadingState title="Cargando actividad reciente..." />
            ) : activities.length === 0 ? (
              <EmptyState title="Sin actividad reciente" description="Los eventos más nuevos aparecerán aquí." />
            ) : (
              activities.map((act) => (
                <div
                  key={act.id}
                  className="flex items-center gap-4 p-4 rounded-2xl bg-white/5 border border-white/5 group hover:border-white/10 transition-colors"
                >
                  <div className="w-10 h-10 rounded-xl bg-primary/20 flex items-center justify-center text-primary font-bold">
                    {act.activity_type === 'task' ? 'T' : 'E'}
                  </div>
                  <div className="flex-1">
                    <p className="text-sm font-bold">{act.metadata?.title || act.title || 'Untitled Activity'}</p>
                    <p className="text-xs text-gray-500 flex items-center gap-1 mt-1">
                      <Calendar className="w-3 h-3" />
                      {new Date(act.created_at).toLocaleTimeString()}
                    </p>
                  </div>
                  <div className="text-emerald-400 font-bold text-sm">
                    {act.metadata?.xp_reward ? `+${act.metadata.xp_reward} XP` : ''}
                  </div>
                </div>
              ))
            )}
          </div>
        </div>

        <div className="glass-dark p-8 rounded-3xl border border-white/5">
          <h3 className="text-xl font-bold mb-6">System Health</h3>
          <div className="space-y-4">
            <div className="p-4 rounded-2xl bg-emerald-500/10 border border-emerald-500/20">
              <p className="text-xs font-bold text-emerald-500 uppercase tracking-widest mb-1">Database</p>
              <p className="text-sm font-medium">Supabase Cloud (Active)</p>
            </div>
            <div className="p-4 rounded-2xl bg-primary/10 border border-primary/20">
              <p className="text-xs font-bold text-primary uppercase tracking-widest mb-1">Auth Service</p>
              <p className="text-sm font-medium">JWT RSA-256 (Enabled)</p>
            </div>
            <div className="p-4 rounded-2xl bg-amber-500/10 border border-amber-500/20">
              <p className="text-xs font-bold text-amber-500 uppercase tracking-widest mb-1">Storage</p>
              <p className="text-sm font-medium">Object Storage (CDN)</p>
            </div>
          </div>
          <button className="w-full mt-6 py-3 rounded-2xl bg-white/5 border border-white/10 font-bold hover:bg-white/10 transition-all">
            Refresh Diagnostic
          </button>
        </div>
      </div>
    </div>
  );
};
