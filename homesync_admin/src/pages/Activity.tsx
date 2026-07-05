import { useCallback, useEffect, useState } from 'react';
import type { LucideIcon } from 'lucide-react';
import {
  TrendingUp,
  Users,
  Flame,
  Repeat,
  Activity as ActivityIcon,
  RefreshCcw,
  Info,
} from 'lucide-react';
import { adminGetActiveUserStats, type ActiveUserStats } from '../lib/adminApi';
import { ErrorState, LoadingState } from '../components/PageState';

type Tone = 'indigo' | 'emerald' | 'amber' | 'violet';

const toneClass: Record<Tone, { bg: string; text: string }> = {
  indigo: { bg: 'bg-indigo-500/10', text: 'text-indigo-400' },
  emerald: { bg: 'bg-emerald-500/10', text: 'text-emerald-400' },
  amber: { bg: 'bg-amber-500/10', text: 'text-amber-400' },
  violet: { bg: 'bg-violet-500/10', text: 'text-violet-400' },
};

const StatCard = ({
  label,
  value,
  hint,
  icon: Icon,
  tone,
}: {
  label: string;
  value: string | number;
  hint?: string;
  icon: LucideIcon;
  tone: Tone;
}) => (
  <div className="glass-dark rounded-2xl border border-white/5 p-5">
    <div className={`w-10 h-10 rounded-xl flex items-center justify-center ${toneClass[tone].bg}`}>
      <Icon className={`w-5 h-5 ${toneClass[tone].text}`} />
    </div>
    <p className="text-3xl font-bold mt-3">{value}</p>
    <p className="text-sm font-semibold text-gray-300 mt-1">{label}</p>
    {hint && <p className="text-xs text-gray-500 mt-1 leading-snug">{hint}</p>}
  </div>
);

const Sparkline = ({ data }: { data: ActiveUserStats['daily'] }) => {
  if (!data || data.length === 0) return null;
  const max = Math.max(1, ...data.map((d) => d.active_users));
  return (
    <div className="flex items-end gap-1.5 h-32">
      {data.map((d) => {
        const pct = Math.round((d.active_users / max) * 100);
        const day = new Date(d.day);
        return (
          <div key={d.day} className="flex-1 flex flex-col items-center gap-2 group">
            <div className="w-full bg-white/5 rounded-t-md relative flex-1 flex items-end" title={`${d.active_users} activos`}>
              <div
                className="w-full bg-gradient-to-t from-primary/60 to-secondary/60 rounded-t-md transition-all duration-500 group-hover:from-primary group-hover:to-secondary"
                style={{ height: `${Math.max(pct, 3)}%` }}
              />
            </div>
            <span className="text-[9px] text-gray-500">{day.getDate()}</span>
          </div>
        );
      })}
    </div>
  );
};

export const Activity = () => {
  const [stats, setStats] = useState<ActiveUserStats | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await adminGetActiveUserStats();
      setStats(data);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'No pudimos cargar las métricas.');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    const id = window.setTimeout(() => void load(), 0);
    return () => window.clearTimeout(id);
  }, [load]);

  return (
    <div className="space-y-6 animate-in fade-in duration-500">
      <div className="flex flex-wrap items-start justify-between gap-3">
        <div>
          <h2 className="text-3xl font-bold tracking-tight flex items-center gap-3">
            <TrendingUp className="w-8 h-8 text-emerald-400" />
            Actividad y Adopción
          </h2>
          <p className="text-gray-400 mt-1">
            Usuarios realmente activos según acciones en la app (tareas, gastos, premios).
          </p>
        </div>
        <button
          onClick={() => void load()}
          disabled={loading}
          className="inline-flex items-center gap-2 px-4 py-2 rounded-xl bg-white/10 hover:bg-white/15 text-sm font-bold disabled:opacity-50 transition-colors"
        >
          <RefreshCcw className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`} />
          Refrescar
        </button>
      </div>

      {error && <ErrorState title="Error cargando métricas" description={error} />}
      {loading && !stats && <LoadingState title="Calculando usuarios activos..." />}

      {stats && (
        <>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
            <StatCard
              label="Activos hoy"
              value={stats.active_1d}
              hint="Con al menos 1 acción en las últimas 24 h"
              icon={Flame}
              tone="amber"
            />
            <StatCard
              label="Activos (7 días)"
              value={stats.active_7d}
              hint="Usuarios distintos con actividad en la semana"
              icon={Users}
              tone="indigo"
            />
            <StatCard
              label="Recurrentes (7 días)"
              value={stats.recurrent_7d}
              hint="Activos en 3+ días distintos: señal de hábito"
              icon={Repeat}
              tone="emerald"
            />
            <StatCard
              label="Stickiness (DAU/MAU)"
              value={`${stats.stickiness_pct}%`}
              hint="Activos hoy ÷ activos en 30 días"
              icon={ActivityIcon}
              tone="violet"
            />
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
            <div className="lg:col-span-2 glass-dark p-6 rounded-3xl border border-white/5">
              <h3 className="text-lg font-bold mb-1">Activos diarios (14 días)</h3>
              <p className="text-xs text-gray-500 mb-6">Usuarios distintos con actividad por día.</p>
              <Sparkline data={stats.daily} />
            </div>

            <div className="glass-dark p-6 rounded-3xl border border-white/5 space-y-4">
              <h3 className="text-lg font-bold">Resumen</h3>
              <div className="bg-white/5 rounded-xl px-4 py-3">
                <p className="text-[10px] text-gray-500 uppercase tracking-widest mb-0.5">Usuarios totales</p>
                <p className="text-sm font-semibold">{stats.total_users}</p>
              </div>
              <div className="bg-white/5 rounded-xl px-4 py-3">
                <p className="text-[10px] text-gray-500 uppercase tracking-widest mb-0.5">Activos (30 días)</p>
                <p className="text-sm font-semibold">{stats.active_30d}</p>
              </div>
              <div className="flex items-start gap-2 text-xs text-gray-500 leading-snug pt-1">
                <Info className="w-4 h-4 shrink-0 mt-0.5" />
                <span>
                  "Activo" = realizó una acción en la app, no solo abrirla. "Recurrente" exige
                  actividad en 3+ días distintos en la semana.
                </span>
              </div>
              <p className="text-[10px] text-gray-600">
                Actualizado: {new Date(stats.generated_at).toLocaleString('es-AR')}
              </p>
            </div>
          </div>
        </>
      )}
    </div>
  );
};
