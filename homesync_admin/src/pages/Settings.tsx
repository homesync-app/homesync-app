import { Settings as SettingsIcon } from 'lucide-react';

export const Settings = () => {
  return (
    <div className="space-y-6 animate-in fade-in duration-500">
      <div>
        <h2 className="text-3xl font-bold tracking-tight flex items-center gap-3">
          <SettingsIcon className="w-8 h-8 text-secondary" />
          Settings
        </h2>
        <p className="text-gray-400 mt-1">
          Configuration hub for admin preferences and integrations.
        </p>
      </div>

      <div className="glass-dark p-8 rounded-3xl border border-white/10">
        <p className="text-sm text-gray-300">
          Settings module is ready for rollout. Next step: add environment flags, alert thresholds, and audit controls.
        </p>
      </div>
    </div>
  );
};
