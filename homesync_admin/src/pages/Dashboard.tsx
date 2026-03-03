import { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import { 
  Users, 
  CheckCircle2, 
  AlertTriangle, 
  TrendingUp,
  Activity,
  Zap,
  Loader2,
  Calendar
} from 'lucide-react';

const StatCard = ({ title, value, change, icon: Icon, color, loading }: any) => (
  <div className="glass p-6 rounded-3xl relative overflow-hidden group">
    <div className={`absolute top-0 right-0 w-32 h-32 bg-${color}-500/10 rounded-full blur-3xl -mr-16 -mt-16 transition-all duration-500 group-hover:scale-150`} />
    <div className="flex justify-between items-start mb-4">
      <div className={`p-3 rounded-2xl bg-${color}-500/10 text-${color}-500`}>
        <Icon className="w-6 h-6" />
      </div>
      {change && (
        <div className="flex items-center gap-1 text-emerald-400 text-xs font-bold bg-emerald-400/10 px-2 py-1 rounded-full">
          <TrendingUp className="w-3 h-3" />
          {change}
        </div>
      )}
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
  const [stats, setStats] = useState({
    households: 0,
    tasksToday: 0,
    alerts: 0,
    totalCoins: 0,
  });
  const [activities, setActivities] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchDashboardData();
  }, []);

  const fetchDashboardData = async () => {
    setLoading(true);
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const [households, tasksToday, alerts, ledgerRes, activityStream] = await Promise.all([
      supabase.from('households').select('*', { count: 'exact', head: true }),
      supabase.from('tasks').select('*', { count: 'exact', head: true }).eq('status', 'verified').gte('updated_at', today.toISOString()),
      supabase.from('application_logs').select('*', { count: 'exact', head: true }).eq('level', 'error'),
      supabase.from('ledger_entries').select('amount').eq('type', 'coins_earned'),
      supabase.from('household_activities').select('*').order('created_at', { ascending: false }).limit(5)
    ]);

    const totalCoins = ledgerRes.data?.reduce((acc, curr) => acc + (curr.amount || 0), 0) || 0;

    setStats({
      households: households.count || 0,
      tasksToday: tasksToday.count || 0,
      alerts: alerts.count || 0,
      totalCoins
    });

    setActivities(activityStream.data || []);
    setLoading(false);
  };

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
        <StatCard 
          title="Active Households" 
          value={stats.households} 
          icon={Users} 
          color="indigo"
          loading={loading}
        />
        <StatCard 
          title="Tasks Completed Today" 
          value={stats.tasksToday} 
          icon={CheckCircle2} 
          color="emerald"
          loading={loading}
        />
        <StatCard 
          title="Critical Alerts" 
          value={stats.alerts} 
          icon={AlertTriangle} 
          color="rose"
          loading={loading}
        />
        <StatCard 
          title="Circulating Coins" 
          value={stats.totalCoins.toLocaleString()} 
          icon={Zap} 
          color="amber"
          loading={loading}
        />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <div className="lg:col-span-2 glass-dark p-8 rounded-3xl border border-white/5">
          <div className="flex items-center justify-between mb-8">
            <h3 className="text-xl font-bold flex items-center gap-2">
              <Activity className="w-5 h-5 text-secondary" />
              Recent Activity
            </h3>
          </div>
          
          <div className="space-y-6">
            {loading ? (
               <div className="flex justify-center py-10"><Loader2 className="animate-spin text-primary" /></div>
            ) : activities.length === 0 ? (
               <div className="text-gray-500 italic py-10 text-center">No recent activity detected.</div>
            ) : activities.map((act) => (
              <div key={act.id} className="flex items-center gap-4 p-4 rounded-2xl bg-white/5 border border-white/5 group hover:border-white/10 transition-colors">
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
            ))}
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
