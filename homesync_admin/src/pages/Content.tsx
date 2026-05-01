import { useState } from 'react';
import { ClipboardList, Gift } from 'lucide-react';
import { TaskTemplates } from './TaskTemplates';
import { RewardTemplates } from './RewardTemplates';

type ContentTab = 'tasks' | 'rewards';

export const Content = () => {
  const [tab, setTab] = useState<ContentTab>('tasks');

  return (
    <div className="space-y-6 animate-in fade-in duration-500">
      <div>
        <h2 className="text-3xl font-bold tracking-tight">Contenido</h2>
        <p className="text-gray-400 mt-1">
          Gestioná las plantillas de tareas y premios disponibles para todos los hogares.
        </p>
      </div>

      <div className="flex bg-white/5 border border-white/10 rounded-xl overflow-hidden">
        <button
          onClick={() => setTab('tasks')}
          className={`flex items-center gap-2 px-6 py-2.5 text-sm font-bold transition-all flex-1 justify-center ${
            tab === 'tasks' ? 'bg-primary/20 text-secondary' : 'text-gray-400 hover:text-white'
          }`}
        >
          <ClipboardList className="w-4 h-4" />
          Tareas
        </button>
        <button
          onClick={() => setTab('rewards')}
          className={`flex items-center gap-2 px-6 py-2.5 text-sm font-bold transition-all flex-1 justify-center ${
            tab === 'rewards' ? 'bg-amber-500/20 text-amber-400' : 'text-gray-400 hover:text-white'
          }`}
        >
          <Gift className="w-4 h-4" />
          Premios
        </button>
      </div>

      {tab === 'tasks' ? <TaskTemplatesInner /> : <RewardTemplatesInner />}
    </div>
  );
};

const TaskTemplatesInner = () => {
  return <TaskTemplates />;
};

const RewardTemplatesInner = () => {
  return <RewardTemplates />;
};
