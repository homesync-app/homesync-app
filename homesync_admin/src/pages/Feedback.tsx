import { useCallback, useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import {
  MessageSquare,
  Bug,
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
  Send,
} from 'lucide-react';
import { EmptyState, ErrorState } from '../components/PageState';
import { Modal } from '../components/Modal';

interface FeedbackItem {
  id: string;
  user_id: string | null;
  email: string | null;
  type: 'bug' | 'suggestion';
  title: string;
  description: string | null;
  app_version: string | null;
  platform: string | null;
  device_model: string | null;
  os_version: string | null;
  locale: string | null;
  screen_name: string | null;
  resolved: boolean;
  status: 'open' | 'replied' | 'resolved' | 'closed';
  response_count: number;
  last_response_at: string | null;
  created_at: string;
}

const statToneClass: Record<'violet' | 'rose' | 'indigo' | 'emerald', string> = {
  violet: 'text-violet-400',
  rose: 'text-rose-400',
  indigo: 'text-indigo-400',
  emerald: 'text-emerald-400',
};

function timeAgo(date: string) {
  const diff = Date.now() - new Date(date).getTime();
  const hours = Math.floor(diff / 3600000);
  if (hours < 1) return `${Math.floor(diff / 60000)}m ago`;
  if (hours < 24) return `${hours}h ago`;
  return `${Math.floor(hours / 24)}d ago`;
}

export const Feedback = () => {
  const [items, setItems] = useState<FeedbackItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState<'all' | 'bug' | 'suggestion'>('all');
  const [showResolved, setShowResolved] = useState(false);
  const [expanded, setExpanded] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [togglingId, setTogglingId] = useState<string | null>(null);
  const [replyingTo, setReplyingTo] = useState<FeedbackItem | null>(null);
  const [replySubject, setReplySubject] = useState('');
  const [replyBody, setReplyBody] = useState('');
  const [replySending, setReplySending] = useState(false);
  const [replyError, setReplyError] = useState<string | null>(null);

  const fetchFeedback = useCallback(async () => {
    setLoading(true);
    setError(null);
    const { data, error } = await supabase
      .from('user_feedback')
      .select('*')
      .order('created_at', { ascending: false })
      .limit(300);

    if (error) {
      setError('No pudimos cargar el feedback.');
      setLoading(false);
      return;
    }
    setItems((data ?? []) as FeedbackItem[]);
    setLoading(false);
  }, []);

  useEffect(() => {
    const id = window.setTimeout(() => void fetchFeedback(), 0);

    // Real-time: new submissions appear instantly
    const channel = supabase
      .channel('feedback_live')
      .on('postgres_changes', { event: 'INSERT', schema: 'public', table: 'user_feedback' }, (payload) => {
        setItems((prev) => [payload.new as FeedbackItem, ...prev]);
      })
      .subscribe();

    return () => {
      window.clearTimeout(id);
      supabase.removeChannel(channel);
    };
  }, [fetchFeedback]);

  const toggleResolved = async (item: FeedbackItem) => {
    setTogglingId(item.id);
    const { error } = await supabase
      .from('user_feedback')
      .update({ resolved: !item.resolved })
      .eq('id', item.id);

    if (!error) {
      setItems((prev) =>
        prev.map((i) => (i.id === item.id ? { ...i, resolved: !i.resolved } : i))
      );
    }
    setTogglingId(null);
  };

  const openReply = (item: FeedbackItem) => {
    setReplyingTo(item);
    setReplySubject(`Respuesta de HomeSync: ${item.title}`);
    setReplyBody('');
    setReplyError(null);
  };

  const sendReply = async () => {
    if (!replyingTo || replySending || !replyBody.trim()) return;

    setReplySending(true);
    setReplyError(null);
    const { error: invokeError } = await supabase.functions.invoke('send-feedback-reply', {
      body: {
        feedback_id: replyingTo.id,
        subject: replySubject.trim(),
        body: replyBody.trim(),
      },
    });

    if (invokeError) {
      setReplyError(invokeError.message || 'No pudimos enviar la respuesta.');
      setReplySending(false);
      return;
    }

    setItems((prev) =>
      prev.map((i) =>
        i.id === replyingTo.id
          ? {
              ...i,
              resolved: true,
              status: 'replied',
              response_count: (i.response_count ?? 0) + 1,
              last_response_at: new Date().toISOString(),
            }
          : i
      )
    );
    setReplySending(false);
    setReplyingTo(null);
    setReplyBody('');
  };

  const filtered = items.filter((i) => {
    if (!showResolved && i.resolved) return false;
    if (filter !== 'all' && i.type !== filter) return false;
    return true;
  });

  const bugs = items.filter((i) => i.type === 'bug');
  const suggestions = items.filter((i) => i.type === 'suggestion');
  const pending = items.filter((i) => !i.resolved);
  const resolved = items.filter((i) => i.resolved);

  return (
    <div className="space-y-8 animate-in fade-in duration-500">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h2 className="text-3xl font-bold tracking-tight flex items-center gap-3">
            <MessageSquare className="w-8 h-8 text-violet-400" />
            User Feedback
          </h2>
          <p className="text-gray-400 mt-1">
            Bugs y sugerencias enviados desde la app — resolvé cada uno para mantener el backlog limpio.
          </p>
        </div>
        <button
          onClick={fetchFeedback}
          className="p-2 bg-white/5 border border-white/10 rounded-xl hover:bg-white/10 transition-colors self-start md:self-center"
        >
          <RotateCcw className="w-5 h-5" />
        </button>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        {[
          { label: 'Total', value: items.length, icon: MessageSquare, color: 'violet' as const },
          { label: 'Bugs', value: bugs.length, icon: Bug, color: 'rose' as const },
          { label: 'Sugerencias', value: suggestions.length, icon: Lightbulb, color: 'indigo' as const },
          { label: 'Resueltos', value: resolved.length, icon: CheckCircle2, color: 'emerald' as const },
        ].map(({ label, value, icon: Icon, color }) => (
          <div key={label} className="glass-dark rounded-2xl p-5 border border-white/5">
            <div className={`${statToneClass[color]} mb-2`}>
              <Icon className="w-5 h-5" />
            </div>
            <p className="text-2xl font-bold">{loading ? '—' : value}</p>
            <p className="text-xs text-gray-500 mt-1">{label}</p>
          </div>
        ))}
      </div>

      {/* Filters */}
      <div className="flex flex-wrap items-center gap-3">
        <div className="flex bg-white/5 border border-white/10 rounded-xl overflow-hidden">
          {(['all', 'bug', 'suggestion'] as const).map((f) => (
            <button
              key={f}
              onClick={() => setFilter(f)}
              className={`px-4 py-2 text-sm font-bold transition-all ${
                filter === f
                  ? 'bg-violet-500/20 text-violet-400'
                  : 'text-gray-400 hover:text-white'
              }`}
            >
              {f === 'all' ? 'Todos' : f === 'bug' ? 'Bugs' : 'Sugerencias'}
            </button>
          ))}
        </div>

        <button
          onClick={() => setShowResolved((v) => !v)}
          className={`flex items-center gap-2 px-4 py-2 text-sm font-bold rounded-xl border transition-all ${
            showResolved
              ? 'bg-emerald-500/10 border-emerald-500/30 text-emerald-400'
              : 'bg-white/5 border-white/10 text-gray-400 hover:text-white'
          }`}
        >
          <CheckCircle2 className="w-4 h-4" />
          {showResolved ? 'Ocultando resueltos' : 'Mostrar resueltos'}
        </button>

        {pending.length > 0 && (
          <span className="ml-auto px-3 py-1 text-xs font-bold rounded-full bg-rose-500/10 text-rose-400 border border-rose-500/20">
            {pending.length} pendiente{pending.length !== 1 ? 's' : ''}
          </span>
        )}
      </div>

      {/* List */}
      {error && <ErrorState title="Error cargando feedback" description={error} />}

      {loading ? (
        <div className="flex justify-center py-20">
          <Loader2 className="w-8 h-8 animate-spin text-violet-400" />
        </div>
      ) : filtered.length === 0 ? (
        <EmptyState
          title="Sin feedback"
          description={
            filter !== 'all'
              ? `No hay ${filter === 'bug' ? 'bugs' : 'sugerencias'} por ahora.`
              : 'Cuando los usuarios reporten algo aparecerá aquí.'
          }
        />
      ) : (
        <div className="space-y-3">
          {filtered.map((item) => {
            const isBug = item.type === 'bug';
            const isExpanded = expanded === item.id;
            return (
              <div
                key={item.id}
                className={`glass-dark rounded-2xl border transition-all duration-200 overflow-hidden ${
                  item.resolved
                    ? 'border-white/5 opacity-60'
                    : isBug
                    ? 'border-rose-500/20'
                    : 'border-indigo-500/20'
                }`}
              >
                {/* Row header */}
                <div className="px-5 py-4 flex items-center gap-4">
                  {/* Resolve toggle */}
                  <button
                    onClick={() => void toggleResolved(item)}
                    disabled={togglingId === item.id}
                    className="shrink-0 text-gray-500 hover:text-emerald-400 transition-colors"
                    title={item.resolved ? 'Marcar como pendiente' : 'Marcar como resuelto'}
                  >
                    {togglingId === item.id ? (
                      <Loader2 className="w-5 h-5 animate-spin" />
                    ) : item.resolved ? (
                      <CheckCircle2 className="w-5 h-5 text-emerald-500" />
                    ) : (
                      <Circle className="w-5 h-5" />
                    )}
                  </button>

                  {/* Type badge */}
                  <div
                    className={`shrink-0 p-2 rounded-xl ${
                      isBug
                        ? 'bg-rose-500/15 text-rose-400'
                        : 'bg-indigo-500/15 text-indigo-400'
                    }`}
                  >
                    {isBug ? <Bug className="w-4 h-4" /> : <Lightbulb className="w-4 h-4" />}
                  </div>

                  {/* Title + meta */}
                  <button
                    className="flex-1 text-left min-w-0"
                    onClick={() => setExpanded(isExpanded ? null : item.id)}
                  >
                    <p
                      className={`text-sm font-semibold truncate ${
                        item.resolved ? 'line-through text-gray-500' : 'text-white/90'
                      }`}
                    >
                      {item.title}
                    </p>
                    <div className="flex items-center gap-3 mt-1 flex-wrap">
                      <span className="text-xs text-gray-500 flex items-center gap-1">
                        <Clock className="w-3 h-3" />
                        {timeAgo(item.created_at)}
                      </span>
                      {item.email && (
                        <span className="text-xs text-gray-500 flex items-center gap-1">
                          <User className="w-3 h-3" />
                          {item.email}
                        </span>
                      )}
                      {item.platform && (
                        <span className="text-xs text-gray-500 flex items-center gap-1">
                          <Smartphone className="w-3 h-3" />
                          {item.platform}
                        </span>
                      )}
                      {item.device_model && (
                        <span className="text-xs text-gray-500">{item.device_model}</span>
                      )}
                    </div>
                  </button>

                  <button
                    onClick={() => setExpanded(isExpanded ? null : item.id)}
                    className="shrink-0 text-gray-500"
                  >
                    {isExpanded ? (
                      <ChevronDown className="w-4 h-4" />
                    ) : (
                      <ChevronRight className="w-4 h-4" />
                    )}
                  </button>
                </div>

                {/* Expanded detail */}
                {isExpanded && (
                  <div className="border-t border-white/5 px-6 py-5 bg-black/20 space-y-4">
                    {item.description && (
                      <p className="text-sm text-gray-300 leading-relaxed whitespace-pre-wrap">
                        {item.description}
                      </p>
                    )}
                    <div className="grid grid-cols-2 md:grid-cols-3 gap-3 pt-1">
                      {item.device_model && (
                        <div className="bg-white/5 rounded-xl px-3 py-2">
                          <p className="text-[10px] text-gray-500 uppercase tracking-widest mb-0.5">Dispositivo</p>
                          <p className="text-xs text-gray-200 font-medium">{item.device_model}</p>
                        </div>
                      )}
                      {item.os_version && (
                        <div className="bg-white/5 rounded-xl px-3 py-2">
                          <p className="text-[10px] text-gray-500 uppercase tracking-widest mb-0.5">OS</p>
                          <p className="text-xs text-gray-200 font-medium">{item.os_version}</p>
                        </div>
                      )}
                      {item.app_version && (
                        <div className="bg-white/5 rounded-xl px-3 py-2">
                          <p className="text-[10px] text-gray-500 uppercase tracking-widest mb-0.5">App version</p>
                          <p className="text-xs text-gray-200 font-medium">v{item.app_version}</p>
                        </div>
                      )}
                      {item.locale && (
                        <div className="bg-white/5 rounded-xl px-3 py-2">
                          <p className="text-[10px] text-gray-500 uppercase tracking-widest mb-0.5">Locale</p>
                          <p className="text-xs text-gray-200 font-medium">{item.locale}</p>
                        </div>
                      )}
                      {item.screen_name && (
                        <div className="bg-white/5 rounded-xl px-3 py-2">
                          <p className="text-[10px] text-gray-500 uppercase tracking-widest mb-0.5">Pantalla</p>
                          <p className="text-xs text-gray-200 font-medium">{item.screen_name}</p>
                        </div>
                      )}
                      {item.email && (
                        <div className="bg-white/5 rounded-xl px-3 py-2">
                          <p className="text-[10px] text-gray-500 uppercase tracking-widest mb-0.5">Email</p>
                          <p className="text-xs text-gray-200 font-medium">{item.email}</p>
                        </div>
                      )}
                      {item.response_count > 0 && (
                        <div className="bg-emerald-500/10 rounded-xl px-3 py-2">
                          <p className="text-[10px] text-emerald-400 uppercase tracking-widest mb-0.5">Respuesta</p>
                          <p className="text-xs text-emerald-100 font-medium">
                            {item.response_count} enviada{item.response_count !== 1 ? 's' : ''}
                          </p>
                        </div>
                      )}
                      {item.user_id && (
                        <div className="bg-white/5 rounded-xl px-3 py-2 col-span-2 md:col-span-3">
                          <p className="text-[10px] text-gray-500 uppercase tracking-widest mb-0.5">User ID</p>
                          <p className="text-xs text-gray-400 font-mono">{item.user_id}</p>
                        </div>
                      )}
                    </div>
                    <div className="flex justify-end pt-2">
                      <button
                        onClick={() => openReply(item)}
                        disabled={!item.email}
                        className="inline-flex items-center gap-2 px-4 py-2 rounded-xl bg-secondary/15 text-secondary border border-secondary/20 text-sm font-bold disabled:opacity-40 disabled:cursor-not-allowed hover:bg-secondary/20 transition-colors"
                      >
                        <Send className="w-4 h-4" />
                        Responder por email
                      </button>
                    </div>
                  </div>
                )}
              </div>
            );
          })}
        </div>
      )}

      <Modal
        isOpen={Boolean(replyingTo)}
        onClose={() => {
          if (!replySending) setReplyingTo(null);
        }}
        title="Responder feedback"
      >
        <div className="space-y-5">
          <div className="rounded-2xl border border-white/10 bg-white/5 p-4">
            <p className="text-xs text-gray-500 uppercase tracking-widest mb-1">Para</p>
            <p className="text-sm text-white font-semibold">{replyingTo?.email ?? 'Sin email'}</p>
            <p className="text-xs text-gray-400 mt-3">{replyingTo?.title}</p>
          </div>

          <label className="block">
            <span className="block text-xs text-gray-500 uppercase tracking-widest mb-2">Asunto</span>
            <input
              value={replySubject}
              onChange={(event) => setReplySubject(event.target.value)}
              className="w-full bg-white/5 border border-white/10 rounded-2xl px-4 py-3 text-sm"
            />
          </label>

          <label className="block">
            <span className="block text-xs text-gray-500 uppercase tracking-widest mb-2">Mensaje</span>
            <textarea
              value={replyBody}
              onChange={(event) => setReplyBody(event.target.value)}
              rows={7}
              className="w-full bg-white/5 border border-white/10 rounded-2xl px-4 py-3 text-sm resize-none leading-relaxed"
              placeholder="Hola, gracias por escribir. Lo estuve revisando..."
            />
          </label>

          {replyError && (
            <div className="rounded-xl border border-rose-500/20 bg-rose-500/10 px-4 py-3 text-sm text-rose-300">
              {replyError}
            </div>
          )}

          <button
            onClick={() => void sendReply()}
            disabled={replySending || !replyBody.trim() || !replyingTo?.email}
            className="w-full flex items-center justify-center gap-2 rounded-2xl bg-primary px-4 py-3 font-bold text-white disabled:opacity-50 disabled:cursor-not-allowed hover:opacity-90 transition-opacity"
          >
            {replySending ? <Loader2 className="w-5 h-5 animate-spin" /> : <Send className="w-5 h-5" />}
            Enviar respuesta
          </button>
        </div>
      </Modal>
    </div>
  );
};
