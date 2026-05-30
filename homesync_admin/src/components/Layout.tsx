import React, { useState } from 'react';
import { PanelLeftClose, PanelLeftOpen, Menu } from 'lucide-react';
import { Sidebar } from './Sidebar';
import { getEnvInfo, useAdminEmail, SKIP_AUTH } from '../lib/auth';

export const Layout = ({ children }: { children: React.ReactNode }) => {
  const [mobileOpen, setMobileOpen] = useState(false);
  const [collapsed, setCollapsed] = useState(false);
  const email = useAdminEmail();
  const env = getEnvInfo();
  const displayName = email ?? (SKIP_AUTH ? 'Dev (sin auth)' : 'Admin');
  const initial = (email ?? 'A').charAt(0).toUpperCase();

  return (
    <div className="flex min-h-screen bg-bg text-text-primary selection:bg-primary/30">
      <div className="fixed inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-[-10%] left-[-10%] w-[40%] h-[40%] bg-primary/10 rounded-full blur-[120px]" />
        <div className="absolute bottom-[-10%] right-[-10%] w-[30%] h-[30%] bg-secondary/10 rounded-full blur-[100px]" />
      </div>

      <Sidebar
        mobileOpen={mobileOpen}
        onCloseMobile={() => setMobileOpen(false)}
        collapsed={collapsed}
      />

      <main className="flex-1 relative min-w-0">
        <header className="h-14 md:h-16 border-b border-white/10 flex items-center justify-between px-4 md:px-6 sticky top-0 bg-bg/85 backdrop-blur-md z-30">
          <div className="flex items-center gap-2 md:gap-3">
            <button
              className="md:hidden p-2 rounded-lg border border-white/10 bg-white/5 hover:bg-white/10"
              onClick={() => setMobileOpen(true)}
              aria-label="Open menu"
            >
              <Menu className="w-4 h-4" />
            </button>
            <button
              className="hidden md:inline-flex p-2 rounded-lg border border-white/10 bg-white/5 hover:bg-white/10"
              onClick={() => setCollapsed((prev) => !prev)}
              aria-label="Toggle sidebar"
            >
              {collapsed ? <PanelLeftOpen className="w-4 h-4" /> : <PanelLeftClose className="w-4 h-4" />}
            </button>

            <div className="flex items-center gap-2">
              <span
                className={`text-[10px] md:text-xs font-bold px-2 py-0.5 rounded-full border ${
                  env.mode === 'Producción'
                    ? 'bg-rose-500/10 text-rose-300 border-rose-500/20'
                    : 'bg-emerald-500/10 text-emerald-300 border-emerald-500/20'
                }`}
                title={`Conectado a ${env.host}`}
              >
                {env.mode}
              </span>
              <span className="hidden sm:inline text-[11px] text-gray-500 font-mono">{env.host}</span>
            </div>
          </div>

          <div className="flex items-center gap-3">
            <div className="hidden sm:block text-right max-w-[180px]">
              <p className="text-xs font-semibold truncate">{displayName}</p>
              <p className="text-[10px] text-gray-400">HomeSync Admin</p>
            </div>
            <div className="w-8 h-8 rounded-lg bg-white/10 border border-white/20 flex items-center justify-center">
              <span className="text-xs font-bold text-primary">{initial}</span>
            </div>
          </div>
        </header>

        <div className="p-4 md:p-8 max-w-7xl mx-auto">{children}</div>
      </main>
    </div>
  );
};
