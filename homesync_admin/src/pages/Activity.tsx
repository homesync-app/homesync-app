import { TrendingUp, BarChart3 } from 'lucide-react';

export const Activity = () => {
  return (
    <div className="space-y-6 animate-in fade-in duration-500">
      <div>
        <h2 className="text-3xl font-bold tracking-tight flex items-center gap-3">
          <TrendingUp className="w-8 h-8 text-emerald-400" />
          Actividad y Adopción
        </h2>
        <p className="text-gray-400 mt-1">
          Cohortes, funnel de onboarding y heatmap de features — conocé qué usa tu gente.
        </p>
      </div>

      <div className="glass-dark p-8 rounded-3xl border border-white/10">
        <div className="flex flex-col items-center justify-center py-12 text-center">
          <div className="w-16 h-16 bg-emerald-500/10 rounded-full flex items-center justify-center mb-6">
            <BarChart3 className="w-8 h-8 text-emerald-500" />
          </div>
          <h3 className="text-xl font-bold mb-2">Próximamente</h3>
          <p className="text-gray-400 text-sm max-w-md">
            Cohortes de retención, funnel de onboarding y heatmap de adopción de features.
            Disponible después del lanzamiento con datos reales.
          </p>
        </div>
      </div>
    </div>
  );
};
