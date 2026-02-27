import React, { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import { 
  Users as UsersIcon,
  Crown,
  User,
  Shield,
  Mail,
  Calendar,
  Loader2,
  MoreVertical,
  Search
} from 'lucide-react';

interface HouseholdMember {
  id: string;
  user_id: string;
  role: string;
  joined_at: string;
  household: {
    id: string;
    name: string;
  };
  user: {
    full_name: string;
    email: string;
    avatar_url: string;
  };
}

export const UserManagement = () => {
  const [members, setMembers] = useState<HouseholdMember[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');

  useEffect(() => {
    fetchMembers();
  }, []);

  const fetchMembers = async () => {
    setLoading(true);
    // Join with households and users
    const { data } = await supabase
      .from('household_members')
      .select(`
        *,
        household:households(id, name),
        user:users(full_name, avatar_url)
      `)
      .order('joined_at', { ascending: false });

    if (data) setMembers(data as any);
    setLoading(false);
  };

  const filteredMembers = members.filter(m => 
    m.user?.full_name?.toLowerCase().includes(search.toLowerCase()) ||
    m.household?.name?.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="space-y-8 animate-in fade-in duration-500">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h2 className="text-3xl font-bold tracking-tight">User Management</h2>
          <p className="text-gray-400 mt-1">Monitor household members and access roles.</p>
        </div>
        
        <div className="flex items-center gap-3">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-500" />
            <input 
              type="text" 
              placeholder="Search members..."
              className="bg-white/5 border border-white/10 rounded-xl py-2 pl-10 pr-4 focus:outline-none focus:ring-2 focus:ring-primary/50 text-sm"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
        {loading ? (
          <div className="col-span-full py-20 flex justify-center">
            <Loader2 className="w-8 h-8 text-primary animate-spin" />
          </div>
        ) : filteredMembers.map((member) => (
          <div key={member.id} className="glass p-6 rounded-3xl relative group overflow-hidden">
             {/* Role Badge */}
             <div className="absolute top-4 right-4">
                <div className={`flex items-center gap-1.5 px-3 py-1 rounded-full text-[10px] font-bold uppercase tracking-wider border ${
                  member.role === 'owner' 
                    ? 'bg-amber-500/10 text-amber-500 border-amber-500/20' 
                    : 'bg-indigo-500/10 text-indigo-400 border-indigo-500/20'
                }`}>
                  {member.role === 'owner' ? <Crown className="w-3 h-3" /> : <User className="w-3 h-3" />}
                  {member.role}
                </div>
             </div>

             <div className="flex items-center gap-4 mb-6">
                <div className="w-14 h-14 rounded-2xl bg-white/5 border border-white/10 flex items-center justify-center relative">
                  {member.user?.avatar_url ? (
                    <img src={member.user.avatar_url} alt="" className="w-full h-full rounded-2xl object-cover" />
                  ) : (
                    <UsersIcon className="w-6 h-6 text-primary" />
                  )}
                  <div className="absolute -bottom-1 -right-1 w-4 h-4 bg-emerald-500 border-2 border-[#0f172a] rounded-full" />
                </div>
                <div>
                  <h4 className="font-bold text-lg leading-tight">{member.user?.full_name || 'Anonymous'}</h4>
                  <div className="flex items-center gap-1.5 text-gray-500 text-xs mt-1">
                    <Shield className="w-3 h-3 text-secondary" />
                    <span>ID: ...{member.user_id.slice(-6)}</span>
                  </div>
                </div>
             </div>

             <div className="space-y-3">
                <div className="flex items-center gap-3 px-3 py-2 rounded-xl bg-white/5 border border-white/5">
                  <div className="p-1.5 rounded-lg bg-indigo-500/10 text-indigo-400">
                    <UsersIcon className="w-4 h-4" />
                  </div>
                  <div>
                    <p className="text-[10px] text-gray-500 font-bold uppercase tracking-tighter">Household</p>
                    <p className="text-sm font-semibold">{member.household?.name || 'Unknown'}</p>
                  </div>
                </div>
                
                <div className="flex items-center gap-3 px-3 py-2 rounded-xl bg-white/5 border border-white/5">
                  <div className="p-1.5 rounded-lg bg-secondary/10 text-secondary">
                    <Calendar className="w-4 h-4" />
                  </div>
                  <div>
                    <p className="text-[10px] text-gray-500 font-bold uppercase tracking-tighter">Joined Date</p>
                    <p className="text-sm font-semibold">{new Date(member.joined_at).toLocaleDateString()}</p>
                  </div>
                </div>
             </div>

             <button className="w-full mt-6 py-3 rounded-2xl border border-white/10 text-xs font-bold text-gray-400 hover:text-white hover:bg-white/5 transition-all">
               Manage Access
             </button>
          </div>
        ))}
      </div>
    </div>
  );
};
