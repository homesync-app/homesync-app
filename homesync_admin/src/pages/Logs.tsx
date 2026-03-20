import { useCallback, useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import { 
  Terminal, 
  AlertCircle, 
  Info, 
  AlertTriangle, 
  RotateCcw,
  Smartphone,
  Calendar,
  Trash2,
  Copy,
  Check
} from 'lucide-react';
import { ErrorState, LoadingState } from '../components/PageState';

interface Log {
  id: string;
  created_at: string;
  level: string;
  message: string;
  stack_trace?: string;
  context?: Record<string, unknown> | null;
  device_info?: Record<string, unknown> | null;
  user_id?: string;
}

export const Logs = () => {
  const [logs, setLogs] = useState<Log[]>([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState('all');
  const [selectedLog, setSelectedLog] = useState<Log | null>(null);
  const [copied, setCopied] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const copyForAI = (log: Log) => {
    const text = `
SYSTEM LOG ENTRY
----------------
Timestamp: ${new Date(log.created_at).toLocaleString()}
Level: ${log.level.toUpperCase()}
Message: ${log.message}

STACK TRACE:
${log.stack_trace || 'No stack trace available'}

CONTEXT:
${JSON.stringify(log.context, null, 2)}

DEVICE INFO:
${JSON.stringify(log.device_info, null, 2)}
    `.trim();

    navigator.clipboard.writeText(text);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const fetchLogs = useCallback(async () => {
    setLoading(true);
    setError(null);
    const { data, error } = await supabase
      .from('application_logs')
      .select('*')
      .order('created_at', { ascending: false })
      .limit(100);

    if (error) {
      console.error('Error fetching logs:', error);
      setError('No se pudieron cargar los logs.');
    } else if (data) {
      setLogs(data);
    }
    setLoading(false);
  }, []);

  useEffect(() => {
    const timeoutId = window.setTimeout(() => {
      void fetchLogs();
    }, 0);

    // Enable Real-time subscription for logs
    const channel = supabase
      .channel('application_logs_changes')
      .on(
        'postgres_changes',
        { event: 'INSERT', schema: 'public', table: 'application_logs' },
        (payload) => {
          setLogs((currentLogs) => [payload.new as Log, ...currentLogs].slice(0, 100));
        }
      )
      .subscribe();

    return () => {
      window.clearTimeout(timeoutId);
      supabase.removeChannel(channel);
    };
  }, [fetchLogs]);

  const clearLogs = async () => {
    if (confirm('Are you sure you want to clear all system logs?')) {
      await supabase.from('application_logs').delete().neq('id', '00000000-0000-0000-0000-000000000000');
      fetchLogs();
    }
  };

  const filteredLogs = logs.filter(log => filter === 'all' || log.level === filter);

  const getLevelIcon = (level: string) => {
    switch (level) {
      case 'critical':
      case 'error': return <AlertCircle className="w-4 h-4 text-rose-500" />;
      case 'warning': return <AlertTriangle className="w-4 h-4 text-amber-500" />;
      default: return <Info className="w-4 h-4 text-blue-400" />;
    }
  };

  const getLevelClass = (level: string) => {
    switch (level) {
      case 'critical':
      case 'error': return "bg-rose-500/10 text-rose-500 border-rose-500/20";
      case 'warning': return "bg-amber-500/10 text-amber-500 border-amber-500/20";
      default: return "bg-blue-500/10 text-blue-400 border-blue-500/20";
    }
  };

  return (
    <div className="space-y-8 animate-in fade-in duration-500 relative">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h2 className="text-3xl font-bold tracking-tight flex items-center gap-3">
            <Terminal className="w-8 h-8 text-secondary" />
            System Diagnostics
          </h2>
          <p className="text-gray-400 mt-1">Real-time application telemetry and error tracking.</p>
        </div>
        
        <div className="flex items-center gap-3">
          <button 
            onClick={fetchLogs}
            className="p-2 bg-white/5 border border-white/10 rounded-xl hover:bg-white/10 transition-colors"
          >
            <RotateCcw className="w-5 h-5" />
          </button>
          <button 
            onClick={clearLogs}
            className="flex items-center gap-2 px-4 py-2 bg-rose-500/10 text-rose-500 border border-rose-500/20 rounded-xl font-bold hover:bg-rose-500/20 transition-all"
          >
            <Trash2 className="w-4 h-4" />
            <span>Clear Logs</span>
          </button>
        </div>
      </div>

      <div className="flex flex-wrap gap-2">
        {['all', 'error', 'warning', 'info'].map((lvl) => (
          <button
            key={lvl}
            onClick={() => setFilter(lvl)}
            className={`px-4 py-1.5 rounded-full text-sm font-bold capitalize transition-all border ${
              filter === lvl 
                ? 'bg-secondary/20 border-secondary text-secondary' 
                : 'bg-white/5 border-white/10 text-gray-200 hover:text-white'
            }`}
          >
            {lvl}
          </button>
        ))}
      </div>

      <div className="glass-dark rounded-3xl border border-white/10 overflow-hidden">
        {error && (
          <div className="p-4 border-b border-white/10">
            <ErrorState title="Error en diagnósticos" description={error} />
          </div>
        )}
        <div className="overflow-x-auto">
          <table className="w-full text-left">
            <thead>
              <tr className="border-b border-white/5 bg-white/2 px-6">
                <th className="px-6 py-4 text-xs font-bold uppercase tracking-widest text-gray-500">Timestamp</th>
                <th className="px-6 py-4 text-xs font-bold uppercase tracking-widest text-gray-500">Level</th>
                <th className="px-6 py-4 text-xs font-bold uppercase tracking-widest text-gray-500">Message</th>
                <th className="px-6 py-4 text-xs font-bold uppercase tracking-widest text-gray-500">Device</th>
                <th className="px-6 py-4 text-xs font-bold uppercase tracking-widest text-gray-500">Context</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-white/5">
              {loading ? (
                <tr>
                  <td colSpan={5} className="py-20 text-center">
                    <LoadingState title="Cargando logs..." />
                  </td>
                </tr>
              ) : filteredLogs.length === 0 ? (
                <tr>
                  <td colSpan={5} className="py-20 text-center text-gray-500 italic">
                    No logs found matching your criteria.
                  </td>
                </tr>
              ) : (
                filteredLogs.map((log) => (
                  <tr key={log.id} className="hover:bg-white/2 transition-colors group">
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-2 min-w-[140px]">
                        <Calendar className="w-3 h-3 text-gray-500" />
                        <span className="text-xs text-gray-400">
                          {new Date(log.created_at).toLocaleString()}
                        </span>
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <div className={`inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-[10px] font-bold uppercase tracking-wider border ${getLevelClass(log.level)}`}>
                        {getLevelIcon(log.level)}
                        {log.level}
                      </div>
                    </td>
                    <td className="px-6 py-4 max-w-md">
                      <p className="text-sm font-medium line-clamp-1 group-hover:line-clamp-none transition-all">
                        {log.message}
                      </p>
                    </td>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-2 text-xs text-gray-400">
                        <Smartphone className="w-3 h-3" />
                        {String(log.device_info?.platform ?? 'Unknown')}
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <button 
                        onClick={() => setSelectedLog(log)}
                        className="text-[10px] bg-white/5 px-2 py-1 rounded hover:bg-white/10 text-gray-400 transition-colors"
                      >
                        View Details
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Log Details Modal */}
      {selectedLog && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm animate-in fade-in duration-200">
          <div className="glass-dark w-full max-w-4xl max-h-[90vh] rounded-3xl border border-white/10 overflow-hidden flex flex-col shadow-2xl">
            <div className="p-6 border-b border-white/5 flex items-center justify-between bg-white/2">
              <div className="flex items-center gap-3">
                <div className={`p-2 rounded-xl border ${getLevelClass(selectedLog.level)}`}>
                  {getLevelIcon(selectedLog.level)}
                </div>
                <div>
                  <h3 className="font-bold text-lg">Log Details</h3>
                  <p className="text-xs text-gray-500">{new Date(selectedLog.created_at).toLocaleString()}</p>
                </div>
              </div>
              <div className="flex items-center gap-2">
                <button 
                  onClick={() => copyForAI(selectedLog)}
                  className={`flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-bold transition-all ${
                    copied 
                      ? 'bg-emerald-500/20 text-emerald-400 border border-emerald-500/30' 
                      : 'bg-secondary/10 text-secondary border border-secondary/20 hover:bg-secondary/20'
                  }`}
                >
                  {copied ? <Check className="w-4 h-4" /> : <Copy className="w-4 h-4" />}
                  <span>{copied ? 'Copied' : 'Copy for AI'}</span>
                </button>
                <button 
                  onClick={() => setSelectedLog(null)}
                  className="p-2 hover:bg-white/5 rounded-lg transition-colors"
                >
                  <Trash2 className="w-5 h-5 text-gray-400 rotate-45" />
                </button>
              </div>
            </div>
            
            <div className="flex-1 overflow-y-auto p-8 space-y-6">
              <div className="space-y-2">
                <p className="text-xs font-bold text-gray-500 uppercase tracking-widest">Message</p>
                <div className="p-4 rounded-2xl bg-white/5 border border-white/5 font-mono text-sm leading-relaxed whitespace-pre-wrap">
                  {selectedLog.message}
                </div>
              </div>

              {selectedLog.stack_trace && (
                <div className="space-y-2">
                  <p className="text-xs font-bold text-gray-500 uppercase tracking-widest">Stack Trace</p>
                  <div className="p-4 rounded-2xl bg-black/40 border border-white/5 font-mono text-xs text-rose-400/80 leading-relaxed overflow-x-auto whitespace-pre">
                    {selectedLog.stack_trace}
                  </div>
                </div>
              )}

              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="space-y-2">
                  <p className="text-xs font-bold text-gray-500 uppercase tracking-widest">Context</p>
                  <pre className="p-4 rounded-2xl bg-white/5 border border-white/5 text-[10px] overflow-x-auto">
                    {JSON.stringify(selectedLog.context, null, 2)}
                  </pre>
                </div>
                <div className="space-y-2">
                  <p className="text-xs font-bold text-gray-500 uppercase tracking-widest">Device Info</p>
                  <pre className="p-4 rounded-2xl bg-white/5 border border-white/5 text-[10px] overflow-x-auto">
                    {JSON.stringify(selectedLog.device_info, null, 2)}
                  </pre>
                </div>
              </div>
            </div>

            <div className="p-6 border-t border-white/5 bg-white/2 flex justify-end">
              <button 
                onClick={() => setSelectedLog(null)}
                className="px-6 py-2 bg-white/10 hover:bg-white/20 rounded-xl font-bold transition-all"
              >
                Done
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
