import { useEffect, useState, useCallback } from 'react';
import { supabase } from '../lib/supabase';
import {
  Bug,
  AlertCircle,
  Clock,
  Smartphone,
  User,
  ChevronDown,
  ChevronRight,
  RotateCcw,
  Copy,
  Check,
  Loader2,
  ShieldAlert,
  TrendingUp,
  Flame
} from 'lucide-react';
import { ErrorState } from '../components/PageState';

interface CrashLog {
  id: string;
  created_at: string;
  level: string;
  message: string;
  stack_trace?: string;
  context?: Record<string, unknown>;
  device_info?: Record<string, unknown>;
  user_id?: string;
}

interface CrashGroup {
  message: string;
  count: number;
  lastSeen: string;
  firstSeen: string;
  logs: CrashLog[];
  level: string;
}

const statToneClass: Record<'rose' | 'orange' | 'amber' | 'violet', string> = {
  rose: 'text-rose-500',
  orange: 'text-orange-500',
  amber: 'text-amber-500',
  violet: 'text-violet-500',
};

export const CrashReports = () => {
  const [crashes, setCrashes] = useState<CrashLog[]>([]);
  const [loading, setLoading] = useState(true);
  const [expandedGroup, setExpandedGroup] = useState<string | null>(null);
  const [expandedLog, setExpandedLog] = useState<string | null>(null);
  const [copied, setCopied] = useState<string | null>(null);
  const [timeRange, setTimeRange] = useState('7d');
  const [error, setError] = useState<string | null>(null);

  const fetchCrashes = useCallback(async () => {
    setLoading(true);
    setError(null);
    const now = new Date();
    const days = timeRange === '24h' ? 1 : timeRange === '7d' ? 7 : 30;
    const since = new Date(now.getTime() - days * 24 * 60 * 60 * 1000).toISOString();

    const { data, error } = await supabase
      .from('application_logs')
      .select('*')
      .in('level', ['critical', 'error'])
      .gte('created_at', since)
      .order('created_at', { ascending: false })
      .limit(200);

    if (error) {
      setError('No pudimos cargar los reportes de crash.');
      setLoading(false);
      return;
    }
    if (data) setCrashes(data);
    setLoading(false);
  }, [timeRange]);

  useEffect(() => {
    const timeoutId = window.setTimeout(() => {
      void fetchCrashes();
    }, 0);

    // Real-time: new critical logs appear instantly
    const channel = supabase
      .channel('crash_reports_live')
      .on('postgres_changes', {
        event: 'INSERT',
        schema: 'public',
        table: 'application_logs',
        filter: 'level=eq.critical'
      }, (payload) => {
        setCrashes(prev => [payload.new as CrashLog, ...prev]);
      })
      .subscribe();

    return () => {
      window.clearTimeout(timeoutId);
      supabase.removeChannel(channel);
    };
  }, [fetchCrashes]);

  // Group identical crashes by message prefix (first 80 chars)
  const crashGroups: CrashGroup[] = Object.values(
    crashes.reduce((acc, log) => {
      const key = log.message.substring(0, 80);
      if (!acc[key]) {
        acc[key] = {
          message: log.message,
          count: 0,
          lastSeen: log.created_at,
          firstSeen: log.created_at,
          logs: [],
          level: log.level,
        };
      }
      acc[key].count++;
      acc[key].logs.push(log);
      if (log.created_at > acc[key].lastSeen) acc[key].lastSeen = log.created_at;
      if (log.created_at < acc[key].firstSeen) acc[key].firstSeen = log.created_at;
      return acc;
    }, {} as Record<string, CrashGroup>)
  ).sort((a, b) => b.count - a.count);

  const totalCrashes = crashes.length;
  const criticalCount = crashes.filter(c => c.level === 'critical').length;
  const uniqueCrashes = crashGroups.length;
  const affectedUsers = new Set(crashes.map(c => c.user_id).filter(Boolean)).size;

  const copyForAI = (log: CrashLog) => {
    const text = `CRASH REPORT
------------
Timestamp: ${new Date(log.created_at).toLocaleString()}
Level: ${log.level.toUpperCase()}
Message: ${log.message}

STACK TRACE:
${log.stack_trace || 'No stack trace'}

CONTEXT:
${JSON.stringify(log.context, null, 2)}

DEVICE:
${JSON.stringify(log.device_info, null, 2)}`.trim();

    navigator.clipboard.writeText(text);
    setCopied(log.id);
    setTimeout(() => setCopied(null), 2000);
  };

  const timeAgo = useCallback((date: string) => {
    const now = Date.now();
    const diff = now - new Date(date).getTime();
    const hours = Math.floor(diff / 3600000);
    if (hours < 1) return `${Math.floor(diff / 60000)}m ago`;
    if (hours < 24) return `${hours}h ago`;
    return `${Math.floor(hours / 24)}d ago`;
  }, []);

  return (
    <div className="space-y-8 animate-in fade-in duration-500">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h2 className="text-3xl font-bold tracking-tight flex items-center gap-3">
            <ShieldAlert className="w-8 h-8 text-rose-500" />
            Crash Reports
          </h2>
          <p className="text-gray-400 mt-1">Grouped crash analysis — copy any crash to paste into the AI for a fix.</p>
        </div>
        <div className="flex items-center gap-3">
          {/* Time range selector */}
          <div className="flex bg-white/5 border border-white/10 rounded-xl overflow-hidden">
            {['24h', '7d', '30d'].map(range => (
              <button
                key={range}
                onClick={() => setTimeRange(range)}
                className={`px-4 py-2 text-sm font-bold transition-all ${
                  timeRange === range
                    ? 'bg-rose-500/20 text-rose-400'
                    : 'text-gray-400 hover:text-white'
                }`}
              >
                {range}
              </button>
            ))}
          </div>
          <button
            onClick={fetchCrashes}
            className="p-2 bg-white/5 border border-white/10 rounded-xl hover:bg-white/10 transition-colors"
          >
            <RotateCcw className="w-5 h-5" />
          </button>
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        {[
          { label: 'Total Crashes', value: totalCrashes, icon: Bug, color: 'rose' },
          { label: 'Critical', value: criticalCount, icon: Flame, color: 'orange' },
          { label: 'Unique Issues', value: uniqueCrashes, icon: AlertCircle, color: 'amber' },
          { label: 'Affected Users', value: affectedUsers, icon: User, color: 'violet' },
        ].map(({ label, value, icon: Icon, color }) => (
          <div key={label} className="glass-dark rounded-2xl p-5 border border-white/5">
            <div className={`${statToneClass[color as keyof typeof statToneClass]} mb-2`}>
              <Icon className="w-5 h-5" />
            </div>
            <p className="text-2xl font-bold">{loading ? '—' : value}</p>
            <p className="text-xs text-gray-500 mt-1">{label}</p>
          </div>
        ))}
      </div>

      {/* Crash groups */}
      <div className="space-y-3">
        {error && <ErrorState title="Error en crash reports" description={error} />}
        {loading ? (
          <div className="flex justify-center py-20">
            <Loader2 className="w-8 h-8 animate-spin text-rose-500" />
          </div>
        ) : crashGroups.length === 0 ? (
          <div className="glass-dark rounded-3xl border border-white/5 py-20 text-center">
            <Bug className="w-12 h-12 text-emerald-500 mx-auto mb-4 opacity-50" />
            <p className="text-emerald-400 font-bold text-lg">No crashes in this period 🎉</p>
            <p className="text-gray-500 text-sm mt-2">Your app is running clean.</p>
          </div>
        ) : (
          crashGroups.map((group, i) => {
            const isExpanded = expandedGroup === group.message;
            const isCritical = group.level === 'critical';
            return (
              <div
                key={i}
                className={`glass-dark rounded-2xl border transition-all duration-200 overflow-hidden ${
                  isCritical ? 'border-rose-500/30' : 'border-orange-500/20'
                }`}
              >
                {/* Group header */}
                <button
                  onClick={() => setExpandedGroup(isExpanded ? null : group.message)}
                  className="w-full px-6 py-4 flex items-center gap-4 text-left hover:bg-white/2 transition-colors"
                >
                  <div className={`p-2 rounded-xl flex-shrink-0 ${
                    isCritical ? 'bg-rose-500/15 text-rose-500' : 'bg-orange-500/15 text-orange-400'
                  }`}>
                    <Bug className="w-4 h-4" />
                  </div>

                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-semibold truncate text-white/90">
                      {group.message.length > 100 ? group.message.substring(0, 100) + '…' : group.message}
                    </p>
                    <div className="flex items-center gap-4 mt-1">
                      <span className="text-xs text-gray-500 flex items-center gap-1">
                        <Clock className="w-3 h-3" />
                        Last seen {timeAgo(group.lastSeen)}
                      </span>
                      <span className="text-xs text-gray-500">
                        First seen {timeAgo(group.firstSeen)}
                      </span>
                    </div>
                  </div>

                  <div className="flex items-center gap-3 flex-shrink-0">
                    {/* Frequency badge */}
                    <div className={`flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold ${
                      group.count >= 10 ? 'bg-rose-500/20 text-rose-400' :
                      group.count >= 3 ? 'bg-orange-500/20 text-orange-400' :
                      'bg-white/10 text-gray-400'
                    }`}>
                      <TrendingUp className="w-3 h-3" />
                      {group.count}×
                    </div>
                    <span className={`text-[10px] uppercase font-bold px-2 py-0.5 rounded-full border ${
                      isCritical
                        ? 'bg-rose-500/10 text-rose-500 border-rose-500/20'
                        : 'bg-orange-500/10 text-orange-400 border-orange-500/20'
                    }`}>
                      {group.level}
                    </span>
                    {isExpanded
                      ? <ChevronDown className="w-4 h-4 text-gray-400" />
                      : <ChevronRight className="w-4 h-4 text-gray-400" />
                    }
                  </div>
                </button>

                {/* Expanded: individual occurrences */}
                {isExpanded && (
                  <div className="border-t border-white/5 divide-y divide-white/5">
                    {group.logs.map(log => (
                      <div key={log.id} className="px-6 py-4 bg-black/20">
                        <div className="flex items-center justify-between">
                          <div className="flex items-center gap-3 text-xs text-gray-400">
                            <span className="flex items-center gap-1">
                              <Clock className="w-3 h-3" />
                              {new Date(log.created_at).toLocaleString()}
                            </span>
                            {!!log.device_info?.platform && (
                              <span className="flex items-center gap-1">
                                <Smartphone className="w-3 h-3" />
                                {String(log.device_info.platform)}
                              </span>
                            )}
                            {log.user_id && (
                              <span className="flex items-center gap-1">
                                <User className="w-3 h-3" />
                                {log.user_id.substring(0, 8)}…
                              </span>
                            )}
                          </div>
                          <button
                            onClick={() => copyForAI(log)}
                            className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-bold transition-all ${
                              copied === log.id
                                ? 'bg-emerald-500/20 text-emerald-400 border border-emerald-500/30'
                                : 'bg-violet-500/10 text-violet-400 border border-violet-500/20 hover:bg-violet-500/20'
                            }`}
                          >
                            {copied === log.id ? <Check className="w-3 h-3" /> : <Copy className="w-3 h-3" />}
                            {copied === log.id ? 'Copied!' : 'Copy for AI'}
                          </button>
                        </div>

                        {log.stack_trace && (
                          <div className="mt-3">
                            <button
                              onClick={() => setExpandedLog(expandedLog === log.id ? null : log.id)}
                              className="text-xs text-gray-500 hover:text-gray-300 flex items-center gap-1 mb-2"
                            >
                              {expandedLog === log.id ? <ChevronDown className="w-3 h-3" /> : <ChevronRight className="w-3 h-3" />}
                              Stack trace
                            </button>
                            {expandedLog === log.id && (
                              <pre className="text-[10px] text-rose-400/70 bg-black/40 p-3 rounded-xl overflow-x-auto whitespace-pre font-mono leading-relaxed">
                                {log.stack_trace}
                              </pre>
                            )}
                          </div>
                        )}
                      </div>
                    ))}
                  </div>
                )}
              </div>
            );
          })
        )}
      </div>
    </div>
  );
};
