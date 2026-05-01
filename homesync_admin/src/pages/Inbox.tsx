import { useCallback, useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import {
  MessageSquare,
  Bug,
  AlertCircle,
  AlertTriangle,
  Lightbulb,
  RotateCcw,
  ChevronDown,
  ChevronRight,
  Smartphone,
  User,
  Clock,
  Loader2,
  CheckCircle2,
  Circle,
  ShieldAlert,
  Copy,
  Check,
  Inbox as InboxIcon,
} from 'lucide-react';
import { EmptyState, ErrorState } from '../components/PageState';

type InboxTab = 'feedback' | 'crashes' | 'logs';

interface FeedbackItem {
  id: string;
  type: 'feedback';
  feedback_type: 'bug' | 'suggestion';
  title: string;
  description: string | null;
  resolved: boolean;
  created_at: string;
  user_id: string | null;
  email: string | null;
  platform: string | null;
  app_version: string | null;
  screen_name: string | null;
}

interface CrashLog {
  id: string;
  type: 'crash';
  level: string;
  message: string;
  stack_trace?: string;
  context?: Record<string, unknown>;
  device_info?: Record<string, unknown>;
  user_id?: string;
  created_at: string;
}

interface SystemLog {
  id: string;
  type: 'log';
  level: string;
  message: string;
  stack_trace?: string;
  context?: Record<string, unknown> | null;
  device_info?: Record<string, unknown> | null;
  user_id?: string;
  created_at: string;
}

type InboxItem = FeedbackItem | CrashLog | SystemLog;

function timeAgo(date: string) {
  const diff = Date.now() - new Date(date).getTime();
  const hours = Math.floor(diff / 3600000);
  if (hours < 1) return `${Math.floor(diff / 60000)}m`;
  if (hours < 24) return `${hours}h`;
  return `${Math.floor(hours / 24)}d`;
}

export const Inbox = () => {
  const [tab, setTab] = useState<InboxTab>('feedback');
  const [items, setItems] = useState<InboxItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [loadingMore, setLoadingMore] = useState(false);
  const [hasMore, setHasMore] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [expanded, setExpanded] = useState<string | null>(null);
  const [copied, setCopied] = useState<string | null>(null);
  const [togglingId, setTogglingId] = useState<string | null>(null);
  const [logFilter, setLogFilter] = useState('all');

  const PAGE_SIZE = 50;

  const fetchFeedback = useCallback(async (offset = 0) => {
    const { data, count } = await supabase
      .from('user_feedback')
      .select('*', { count: 'exact' })
      .order('created_at', { ascending: false })
      .range(offset, offset + PAGE_SIZE - 1);
    return {
      items: (data || []).map(
        (d: Record<string, unknown>): FeedbackItem => ({
          id: d.id as string,
          type: 'feedback',
          feedback_type: d.type as 'bug' | 'suggestion',
          title: d.title as string,
          description: d.description as string | null,
          resolved: d.resolved as boolean,
          created_at: d.created_at as string,
          user_id: d.user_id as string | null,
          email: d.email as string | null,
          platform: d.platform as string | null,
          app_version: d.app_version as string | null,
          screen_name: d.screen_name as string | null,
        })
      ),
      total: count || 0,
    };
  }, []);

  const fetchCrashes = useCallback(async (offset = 0) => {
    const { data, count } = await supabase
      .from('application_logs')
      .select('*', { count: 'exact' })
      .in('level', ['critical', 'error'])
      .order('created_at', { ascending: false })
      .range(offset, offset + PAGE_SIZE - 1);
    return {
      items: (data || []).map(
        (d: Record<string, unknown>): CrashLog => ({
          id: d.id as string,
          type: 'crash',
          level: d.level as string,
          message: d.message as string,
          stack_trace: d.stack_trace as string | undefined,
          context: d.context as Record<string, unknown> | undefined,
          device_info: d.device_info as Record<string, unknown> | undefined,
          user_id: d.user_id as string | undefined,
          created_at: d.created_at as string,
        })
      ),
      total: count || 0,
    };
  }, []);

  const fetchLogs = useCallback(async (offset = 0) => {
    const { data, count } = await supabase
      .from('application_logs')
      .select('*', { count: 'exact' })
      .order('created_at', { ascending: false })
      .range(offset, offset + PAGE_SIZE - 1);
    return {
      items: (data || []).map(
        (d: Record<string, unknown>): SystemLog => ({
          id: d.id as string,
          type: 'log',
          level: d.level as string,
          message: d.message as string,
          stack_trace: d.stack_trace as string | undefined,
          context: d.context as Record<string, unknown> | null,
          device_info: d.device_info as Record<string, unknown> | null,
          user_id: d.user_id as string | undefined,
          created_at: d.created_at as string,
        })
      ),
      total: count || 0,
    };
  }, []);

  const fetchData = useCallback(async (offset = 0) => {
    if (offset === 0) setLoading(true);
    else setLoadingMore(true);
    setError(null);
    try {
      let result: { items: InboxItem[]; total: number };
      if (tab === 'feedback') result = await fetchFeedback(offset);
      else if (tab === 'crashes') result = await fetchCrashes(offset);
      else result = await fetchLogs(offset);
      if (offset === 0) {
        setItems(result.items);
      } else {
        setItems((prev) => [...prev, ...result.items]);
      }
      setHasMore(offset + result.items.length < result.total);
    } catch {
      setError('No pudimos cargar los datos.');
    }
    setLoading(false);
    setLoadingMore(false);
  }, [tab, fetchFeedback, fetchCrashes, fetchLogs]);

  useEffect(() => {
    const id = window.setTimeout(() => void fetchData(0), 0);
    return () => window.clearTimeout(id);
  }, [fetchData]);

  useEffect(() => {
    if (tab === 'feedback') {
      const channel = supabase
        .channel('inbox_feedback')
        .on('postgres_changes', { event: 'INSERT', schema: 'public', table: 'user_feedback' }, () => {
          void fetchData(0);
        })
        .subscribe();
      return () => { supabase.removeChannel(channel); };
    }
    if (tab === 'crashes' || tab === 'logs') {
      const channel = supabase
        .channel('inbox_logs')
        .on('postgres_changes', { event: 'INSERT', schema: 'public', table: 'application_logs' }, () => {
          void fetchData(0);
        })
        .subscribe();
      return () => { supabase.removeChannel(channel); };
    }
  }, [tab, fetchData]);

  const toggleResolved = async (item: FeedbackItem) => {
    setTogglingId(item.id);
    const { error: updateError } = await supabase
      .from('user_feedback')
      .update({ resolved: !item.resolved })
      .eq('id', item.id);
    if (!updateError) {
      setItems((prev) =>
        prev.map((i) =>
          i.id === item.id && i.type === 'feedback'
            ? { ...i, resolved: !item.resolved }
            : i
        )
      );
    }
    setTogglingId(null);
  };

  const copyForAI = (item: CrashLog | SystemLog) => {
    const text = `TYPE: ${(item as CrashLog).level?.toUpperCase() || 'LOG'}
TIMESTAMP: ${new Date(item.created_at).toLocaleString()}
MESSAGE: ${item.message}

STACK TRACE:
${item.stack_trace || 'No stack trace'}

CONTEXT:
${JSON.stringify(item.context, null, 2)}

DEVICE:
${JSON.stringify(item.device_info, null, 2)}`.trim();

    navigator.clipboard.writeText(text);
    setCopied(item.id);
    setTimeout(() => setCopied(null), 2000);
  };

  const filteredLogs =
    tab === 'logs' && logFilter !== 'all'
      ? items.filter((i) => (i as SystemLog).level === logFilter)
      : items;

  const feedbackStats = {
    total: items.filter((i) => i.type === 'feedback').length,
    bugs: items.filter((i) => i.type === 'feedback' && (i as FeedbackItem).feedback_type === 'bug').length,
    suggestions: items.filter((i) => i.type === 'feedback' && (i as FeedbackItem).feedback_type === 'suggestion').length,
    pending: items.filter((i) => i.type === 'feedback' && !(i as FeedbackItem).resolved).length,
  };

  const tabs: { key: InboxTab; label: string; icon: typeof MessageSquare }[] = [
    { key: 'feedback', label: 'Feedback', icon: MessageSquare },
    { key: 'crashes', label: 'Crashes', icon: ShieldAlert },
    { key: 'logs', label: 'Logs', icon: AlertCircle },
  ];

  return (
    <div className="space-y-8 animate-in fade-in duration-500">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h2 className="text-3xl font-bold tracking-tight flex items-center gap-3">
            <InboxIcon className="w-8 h-8 text-violet-400" />
            Bandeja
          </h2>
          <p className="text-gray-400 mt-1">
            Feedback, crashes y errores del sistema — todo en un solo lugar.
          </p>
        </div>
        <button
          onClick={() => void fetchData(0)}
          className="p-2 bg-white/5 border border-white/10 rounded-xl hover:bg-white/10 transition-colors self-start md:self-center"
        >
          <RotateCcw className="w-5 h-5" />
        </button>
      </div>

      <div className="flex bg-white/5 border border-white/10 rounded-xl overflow-hidden">
        {tabs.map(({ key, label, icon: Icon }) => (
          <button
            key={key}
            onClick={() => { setTab(key); setExpanded(null); }}
            className={`flex items-center gap-2 px-5 py-2.5 text-sm font-bold transition-all flex-1 justify-center ${
              tab === key ? 'bg-primary/20 text-secondary' : 'text-gray-400 hover:text-white'
            }`}
          >
            <Icon className="w-4 h-4" />
            {label}
          </button>
        ))}
      </div>

      {tab === 'feedback' && (
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          {[
            { label: 'Total', value: feedbackStats.total, icon: MessageSquare, color: 'text-violet-400' },
            { label: 'Bugs', value: feedbackStats.bugs, icon: Bug, color: 'text-rose-400' },
            { label: 'Sugerencias', value: feedbackStats.suggestions, icon: Lightbulb, color: 'text-indigo-400' },
            { label: 'Pendientes', value: feedbackStats.pending, icon: AlertCircle, color: 'text-amber-400' },
          ].map(({ label, value, icon: Icon, color }) => (
            <div key={label} className="glass-dark rounded-2xl p-5 border border-white/5">
              <div className={`${color} mb-2`}><Icon className="w-5 h-5" /></div>
              <p className="text-2xl font-bold">{loading ? '—' : value}</p>
              <p className="text-xs text-gray-500 mt-1">{label}</p>
            </div>
          ))}
        </div>
      )}

      {tab === 'logs' && (
        <div className="flex flex-wrap gap-2">
          {['all', 'error', 'warning', 'info'].map((lvl) => (
            <button
              key={lvl}
              onClick={() => setLogFilter(lvl)}
              className={`px-4 py-1.5 rounded-full text-sm font-bold capitalize transition-all border ${
                logFilter === lvl
                  ? 'bg-secondary/20 border-secondary text-secondary'
                  : 'bg-white/5 border-white/10 text-gray-200 hover:text-white'
              }`}
            >
              {lvl === 'all' ? 'Todos' : lvl}
            </button>
          ))}
        </div>
      )}

      {error && <ErrorState title="Error cargando datos" description={error} />}

      {loading ? (
        <div className="flex justify-center py-20">
          <Loader2 className="w-8 h-8 animate-spin text-violet-400" />
        </div>
      ) : filteredLogs.length === 0 ? (
        <EmptyState
          title="Sin resultados"
          description="No hay items para mostrar."
        />
      ) : (
        <div className="space-y-3">
          {filteredLogs.map((item) => {
            const isExpanded = expanded === item.id;

            if (item.type === 'feedback') {
              const fb = item as FeedbackItem;
              const isBug = fb.feedback_type === 'bug';
              return (
                <div
                  key={fb.id}
                  className={`glass-dark rounded-2xl border transition-all duration-200 overflow-hidden ${
                    fb.resolved
                      ? 'border-white/5 opacity-60'
                      : isBug
                        ? 'border-rose-500/20'
                        : 'border-indigo-500/20'
                  }`}
                >
                  <div className="px-5 py-4 flex items-center gap-4">
                    <button
                      onClick={() => void toggleResolved(fb)}
                      disabled={togglingId === fb.id}
                      className="shrink-0 text-gray-500 hover:text-emerald-400 transition-colors"
                      title={fb.resolved ? 'Marcar como pendiente' : 'Marcar como resuelto'}
                    >
                      {togglingId === fb.id ? (
                        <Loader2 className="w-5 h-5 animate-spin" />
                      ) : fb.resolved ? (
                        <CheckCircle2 className="w-5 h-5 text-emerald-500" />
                      ) : (
                        <Circle className="w-5 h-5" />
                      )}
                    </button>
                    <div className={`shrink-0 p-2 rounded-xl ${
                      isBug ? 'bg-rose-500/15 text-rose-400' : 'bg-indigo-500/15 text-indigo-400'
                    }`}>
                      {isBug ? <Bug className="w-4 h-4" /> : <Lightbulb className="w-4 h-4" />}
                    </div>
                    <button
                      className="flex-1 text-left min-w-0"
                      onClick={() => setExpanded(isExpanded ? null : fb.id)}
                    >
                      <p className={`text-sm font-semibold truncate ${
                        fb.resolved ? 'line-through text-gray-500' : 'text-white/90'
                      }`}>{fb.title}</p>
                      <div className="flex items-center gap-3 mt-1 flex-wrap">
                        <span className="text-xs text-gray-500 flex items-center gap-1">
                          <Clock className="w-3 h-3" />{timeAgo(fb.created_at)}
                        </span>
                        {fb.email && (
                          <span className="text-xs text-gray-500 flex items-center gap-1">
                            <User className="w-3 h-3" />{fb.email}
                          </span>
                        )}
                        {fb.platform && (
                          <span className="text-xs text-gray-500 flex items-center gap-1">
                            <Smartphone className="w-3 h-3" />{fb.platform}
                          </span>
                        )}
                      </div>
                    </button>
                    <button onClick={() => setExpanded(isExpanded ? null : fb.id)} className="shrink-0 text-gray-500">
                      {isExpanded ? <ChevronDown className="w-4 h-4" /> : <ChevronRight className="w-4 h-4" />}
                    </button>
                  </div>
                  {isExpanded && (
                    <div className="border-t border-white/5 px-6 py-5 bg-black/20 space-y-3">
                      {fb.description && (
                        <p className="text-sm text-gray-300 leading-relaxed whitespace-pre-wrap">{fb.description}</p>
                      )}
                      <div className="grid grid-cols-2 md:grid-cols-3 gap-3 pt-1">
                        {fb.app_version && (
                          <div className="bg-white/5 rounded-xl px-3 py-2">
                            <p className="text-[10px] text-gray-500 uppercase tracking-widest mb-0.5">Versión</p>
                            <p className="text-xs text-gray-200 font-medium">v{fb.app_version}</p>
                          </div>
                        )}
                        {fb.screen_name && (
                          <div className="bg-white/5 rounded-xl px-3 py-2">
                            <p className="text-[10px] text-gray-500 uppercase tracking-widest mb-0.5">Pantalla</p>
                            <p className="text-xs text-gray-200 font-medium">{fb.screen_name}</p>
                          </div>
                        )}
                        {fb.email && (
                          <div className="bg-white/5 rounded-xl px-3 py-2">
                            <p className="text-[10px] text-gray-500 uppercase tracking-widest mb-0.5">Email</p>
                            <p className="text-xs text-gray-200 font-medium">{fb.email}</p>
                          </div>
                        )}
                      </div>
                    </div>
                  )}
                </div>
              );
            }

            const logItem = item as CrashLog | SystemLog;
            const isCritical = (logItem as CrashLog).level === 'critical';
            const isCrash = logItem.type === 'crash';
            const level = (logItem as CrashLog).level;

            return (
              <div
                key={logItem.id}
                className={`glass-dark rounded-2xl border transition-all duration-200 overflow-hidden ${
                  isCritical
                    ? 'border-rose-500/30'
                    : isCrash
                      ? 'border-orange-500/20'
                      : 'border-white/5'
                }`}
              >
                <div className="px-5 py-4 flex items-center gap-4">
                  <div className={`shrink-0 p-2 rounded-xl ${
                    isCritical ? 'bg-rose-500/15 text-rose-500' :
                    level === 'error' ? 'bg-orange-500/15 text-orange-400' :
                    level === 'warning' ? 'bg-amber-500/15 text-amber-400' :
                    'bg-blue-500/15 text-blue-400'
                  }`}>
                    {isCritical ? <ShieldAlert className="w-4 h-4" /> :
                     level === 'error' ? <AlertCircle className="w-4 h-4" /> :
                     level === 'warning' ? <AlertTriangle className="w-4 h-4" /> :
                     <AlertCircle className="w-4 h-4" />}
                  </div>
                  <button
                    className="flex-1 text-left min-w-0"
                    onClick={() => setExpanded(isExpanded ? null : logItem.id)}
                  >
                    <p className="text-sm font-semibold truncate text-white/90">{logItem.message}</p>
                    <div className="flex items-center gap-3 mt-1 flex-wrap">
                      <span className="text-xs text-gray-500 flex items-center gap-1">
                        <Clock className="w-3 h-3" />{timeAgo(logItem.created_at)}
                      </span>
                      <span className={`text-[10px] uppercase font-bold px-2 py-0.5 rounded-full border ${
                        isCritical ? 'bg-rose-500/10 text-rose-500 border-rose-500/20' :
                        level === 'error' ? 'bg-orange-500/10 text-orange-400 border-orange-500/20' :
                        level === 'warning' ? 'bg-amber-500/10 text-amber-500 border-amber-500/20' :
                        'bg-blue-500/10 text-blue-400 border-blue-500/20'
                      }`}>
                        {level}
                      </span>
                      {logItem.user_id && (
                        <span className="text-xs text-gray-500 flex items-center gap-1">
                          <User className="w-3 h-3" />{logItem.user_id.substring(0, 8)}…
                        </span>
                      )}
                    </div>
                  </button>
                  <div className="flex items-center gap-2 flex-shrink-0">
                    <button
                      onClick={() => copyForAI(logItem)}
                      className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-bold transition-all ${
                        copied === logItem.id
                          ? 'bg-emerald-500/20 text-emerald-400 border border-emerald-500/30'
                          : 'bg-violet-500/10 text-violet-400 border border-violet-500/20 hover:bg-violet-500/20'
                      }`}
                    >
                      {copied === logItem.id ? <Check className="w-3 h-3" /> : <Copy className="w-3 h-3" />}
                      {copied === logItem.id ? '¡Copiado!' : 'Copiar para IA'}
                    </button>
                    <button onClick={() => setExpanded(isExpanded ? null : logItem.id)} className="text-gray-500">
                      {isExpanded ? <ChevronDown className="w-4 h-4" /> : <ChevronRight className="w-4 h-4" />}
                    </button>
                  </div>
                </div>
                {isExpanded && (
                  <div className="border-t border-white/5 px-6 py-4 bg-black/20 space-y-4">
                    {logItem.stack_trace && (
                      <div>
                        <p className="text-xs text-gray-500 mb-2 font-bold uppercase tracking-widest">Stack Trace</p>
                        <pre className="text-[10px] text-rose-400/70 bg-black/40 p-3 rounded-xl overflow-x-auto whitespace-pre font-mono leading-relaxed">
                          {logItem.stack_trace}
                        </pre>
                      </div>
                    )}
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                      {logItem.context && Object.keys(logItem.context).length > 0 && (
                        <div>
                          <p className="text-xs text-gray-500 mb-2 font-bold uppercase tracking-widest">Contexto</p>
                          <pre className="text-[10px] text-gray-300 bg-white/5 p-3 rounded-xl overflow-x-auto">
                            {JSON.stringify(logItem.context, null, 2)}
                          </pre>
                        </div>
                      )}
                      {logItem.device_info && Object.keys(logItem.device_info).length > 0 && (
                        <div>
                          <p className="text-xs text-gray-500 mb-2 font-bold uppercase tracking-widest">Dispositivo</p>
                          <pre className="text-[10px] text-gray-300 bg-white/5 p-3 rounded-xl overflow-x-auto">
                            {JSON.stringify(logItem.device_info, null, 2)}
                          </pre>
                        </div>
                      )}
                    </div>
                  </div>
                )}
              </div>
            );
          })}
          {hasMore && (
            <div className="flex justify-center pt-4">
              <button
                onClick={() => void fetchData(items.length)}
                disabled={loadingMore}
                className="px-6 py-3 bg-white/5 border border-white/10 rounded-xl font-bold hover:bg-white/10 transition-all flex items-center gap-2 disabled:opacity-50"
              >
                {loadingMore ? (
                  <Loader2 className="w-4 h-4 animate-spin" />
                ) : null}
                Cargar más
              </button>
            </div>
          )}
        </div>
      )}
    </div>
  );
};
