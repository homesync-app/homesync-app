import { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import { 
  BarChart3, 
  Coins, 
  Trophy, 
  TrendingUp, 
  Zap,
  Activity,
  Loader2
} from 'lucide-react';

export const Economy = () => {
  const [stats, setStats] = useState<any>(null);
  const [distribution, setDistribution] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchStats();
  }, []);

  const fetchStats = async () => {
    setLoading(true);
    
    // Get all ledger entries and users
    const [ledgerRes, usersRes] = await Promise.all([
      supabase.from('ledger_entries').select('user_id, type, amount'),
      supabase.from('users').select('id')
    ]);

    const entries = ledgerRes.data || [];
    const userList = usersRes.data || [];

    // Aggregate by user
    const userTotals = userList.map(user => {
      const userEntries = entries.filter(e => e.user_id === user.id);
      return {
        id: user.id,
        total_xp: userEntries
          .filter(e => e.type === 'xp_earned')
          .reduce((sum, e) => sum + (e.amount || 0), 0),
        coins: userEntries
          .filter(e => e.type === 'coins_earned')
          .reduce((sum, e) => sum + (e.amount || 0), 0)
      };
    });

    const totalXP = userTotals.reduce((acc, curr) => acc + curr.total_xp, 0);
    const totalCoins = userTotals.reduce((acc, curr) => acc + curr.coins, 0);
    
    setStats({
      totalUsers: userTotals.length,
      totalXP,
      totalCoins,
      avgXp: totalXP / (userTotals.length || 1),
      avgCoins: totalCoins / (userTotals.length || 1),
    });

    // Calculate real distribution
    const dist = [
      { label: '0-500 XP', count: userTotals.filter(u => u.total_xp <= 500).length, color: 'bg-primary' },
      { label: '500-2000 XP', count: userTotals.filter(u => u.total_xp > 500 && u.total_xp <= 2000).length, color: 'bg-indigo-500' },
      { label: '2000-5000 XP', count: userTotals.filter(u => u.total_xp > 2000 && u.total_xp <= 5000).length, color: 'bg-secondary' },
      { label: 'Elite (5000+)', count: userTotals.filter(u => u.total_xp > 5000).length, color: 'bg-emerald-500' },
    ];

    setDistribution(dist.map(d => ({
      ...d,
      percentage: userTotals.length ? Math.round((d.count / userTotals.length) * 100) : 0
    })));
    
    setLoading(false);
  };

  if (loading) return (
    <div className="h-[60vh] flex items-center justify-center">
      <Loader2 className="w-10 h-10 text-primary animate-spin" />
    </div>
  );

  return (
    <div className="space-y-8 animate-in fade-in duration-500">
      <div>
        <h2 className="text-3xl font-bold tracking-tight flex items-center gap-3">
          <BarChart3 className="w-8 h-8 text-secondary" />
          Economic Ecosystem
        </h2>
        <p className="text-gray-400 mt-1">Monitoring the flow of XP and Coins across all households.</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="glass p-8 rounded-[2rem] border-primary/20 relative overflow-hidden group">
          <div className="absolute top-0 right-0 p-4 opacity-10 group-hover:opacity-20 transition-opacity">
            <Trophy className="w-20 h-20 text-primary" />
          </div>
          <p className="text-sm font-bold uppercase tracking-widest text-primary mb-2">Total Wealth (XP)</p>
          <h3 className="text-4xl font-black">{stats.totalXP.toLocaleString()}</h3>
          <div className="flex items-center gap-1.5 text-gray-500 text-xs font-bold mt-4">
             <span>Cumulative System XP</span>
          </div>
        </div>

        <div className="glass p-8 rounded-[2rem] border-amber-500/20 relative overflow-hidden group">
           <div className="absolute top-0 right-0 p-4 opacity-10 group-hover:opacity-20 transition-opacity">
            <Coins className="w-20 h-20 text-amber-500" />
          </div>
          <p className="text-sm font-bold uppercase tracking-widest text-amber-500 mb-2">Coins in Circulation</p>
          <h3 className="text-4xl font-black">{stats.totalCoins.toLocaleString()}</h3>
          <div className="flex items-center gap-1.5 text-amber-500 text-xs font-bold mt-4">
            <Activity className="w-4 h-4" />
            <span>Real-time Ledger</span>
          </div>
        </div>

        <div className="glass p-8 rounded-[2rem] border-secondary/20 relative overflow-hidden group">
           <div className="absolute top-0 right-0 p-4 opacity-10 group-hover:opacity-20 transition-opacity">
            <Zap className="w-20 h-20 text-secondary" />
          </div>
          <p className="text-sm font-bold uppercase tracking-widest text-secondary mb-2">Average Fortune</p>
          <h3 className="text-4xl font-black">{Math.round(stats.avgCoins)} 🪙</h3>
          <div className="flex items-center gap-1.5 text-gray-500 text-xs font-bold mt-4">
            <span>Per user average</span>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <div className="glass-dark p-8 rounded-[2.5rem] border border-white/5">
           <h3 className="text-xl font-bold mb-8 flex items-center gap-2">
             <TrendingUp className="w-5 h-5 text-emerald-500" />
             XP Distribution
           </h3>
           <div className="space-y-6">
             {distribution.map((item) => (
                <div key={item.label}>
                   <div className="flex justify-between text-xs font-bold uppercase tracking-widest text-gray-400 mb-2">
                      <span>{item.label} ({item.count} users)</span>
                      <span>{item.percentage}%</span>
                   </div>
                   <div className="h-2 w-full bg-white/5 rounded-full overflow-hidden">
                      <div 
                        className={`h-full ${item.color} rounded-full transition-all duration-1000`} 
                        style={{ width: `${item.percentage}%` }}
                      />
                   </div>
                </div>
             ))}
           </div>
        </div>

        <div className="glass-dark p-8 rounded-[2.5rem] border border-white/5 flex flex-col items-center justify-center text-center">
            <div className="w-20 h-20 bg-primary/10 rounded-full flex items-center justify-center mb-6">
               <Zap className="w-10 h-10 text-primary" />
            </div>
            <h3 className="text-2xl font-bold mb-2">Economic Control</h3>
            <p className="text-gray-400 text-sm max-w-xs mb-8">
              Adjust global rewards to maintain health of the ecosystem.
            </p>
            <div className="flex items-center gap-4 w-full">
               <button className="flex-1 py-4 rounded-2xl bg-white/5 border border-white/10 font-bold hover:bg-white/10 transition-all opacity-50 cursor-not-allowed">Decrease</button>
               <div className="px-8 py-4 rounded-2xl bg-primary text-2xl font-black">1.0x</div>
               <button className="flex-1 py-4 rounded-2xl bg-white/5 border border-white/10 font-bold hover:bg-white/10 transition-all opacity-50 cursor-not-allowed">Increase</button>
            </div>
        </div>
      </div>
    </div>
  );
};
