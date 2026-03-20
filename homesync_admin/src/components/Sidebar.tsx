import React from 'react';
import { NavLink } from 'react-router-dom';
import {
  LayoutDashboard,
  Terminal,
  ClipboardList,
  Users,
  BarChart3,
  Home,
  Settings,
  ShieldAlert,
  Gift,
  X,
  type LucideIcon,
} from 'lucide-react';
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

const SidebarItem = ({
  to,
  icon: Icon,
  children,
  collapsed,
  onNavigate,
}: {
  to: string;
  icon: LucideIcon;
  children: React.ReactNode;
  collapsed: boolean;
  onNavigate?: () => void;
}) => (
  <NavLink
    to={to}
    onClick={onNavigate}
    className={({ isActive }) =>
      cn(
        'flex items-center gap-3 px-3 py-3 rounded-xl transition-all duration-200 group',
        isActive
          ? 'bg-primary/20 text-secondary border border-primary/20'
          : 'text-gray-300 hover:bg-white/10 hover:text-white',
        collapsed && 'justify-center px-2'
      )
    }
    title={typeof children === 'string' ? children : undefined}
  >
    <Icon className="w-5 h-5 transition-transform duration-200 group-hover:scale-110" />
    {!collapsed && <span className="font-medium whitespace-nowrap">{children}</span>}
  </NavLink>
);

export const Sidebar = ({
  mobileOpen,
  onCloseMobile,
  collapsed,
}: {
  mobileOpen: boolean;
  onCloseMobile: () => void;
  collapsed: boolean;
}) => {
  return (
    <>
      {mobileOpen && (
        <button
          aria-label="Close menu"
          onClick={onCloseMobile}
          className="fixed inset-0 bg-black/60 backdrop-blur-sm z-40 md:hidden"
        />
      )}

      <aside
        className={cn(
          'h-screen glass-dark border-r border-white/10 flex flex-col p-4 md:p-5 sticky top-0 z-50 transition-all duration-300',
          collapsed ? 'w-20' : 'w-64',
          'fixed left-0 top-0 md:static',
          mobileOpen ? 'translate-x-0' : '-translate-x-full md:translate-x-0'
        )}
      >
        <div className="flex items-center justify-between mb-8 px-1">
          <div className={cn('flex items-center gap-3 min-w-0', collapsed && 'justify-center w-full')}>
            <div className="w-10 h-10 bg-primary rounded-xl flex items-center justify-center glow-violet shrink-0">
              <Home className="text-white w-6 h-6" />
            </div>
            {!collapsed && (
              <div className="min-w-0">
                <h1 className="text-lg font-bold tracking-tight truncate">HomeSync</h1>
                <span className="text-[10px] uppercase tracking-widest text-secondary font-bold">
                  Admin Portal
                </span>
              </div>
            )}
          </div>

          <button
            onClick={onCloseMobile}
            className="md:hidden p-2 rounded-lg hover:bg-white/10 text-gray-300"
            aria-label="Close sidebar"
          >
            <X className="w-4 h-4" />
          </button>
        </div>

        <nav className="flex-1 space-y-2">
          <SidebarItem to="/" icon={LayoutDashboard} collapsed={collapsed} onNavigate={onCloseMobile}>
            Overview
          </SidebarItem>
          <SidebarItem to="/logs" icon={Terminal} collapsed={collapsed} onNavigate={onCloseMobile}>
            Logs & Errors
          </SidebarItem>
          <SidebarItem to="/crashes" icon={ShieldAlert} collapsed={collapsed} onNavigate={onCloseMobile}>
            Crash Reports
          </SidebarItem>
          <SidebarItem to="/templates" icon={ClipboardList} collapsed={collapsed} onNavigate={onCloseMobile}>
            Task Templates
          </SidebarItem>
          <SidebarItem to="/rewards" icon={Gift} collapsed={collapsed} onNavigate={onCloseMobile}>
            Reward Templates
          </SidebarItem>
          <SidebarItem to="/users" icon={Users} collapsed={collapsed} onNavigate={onCloseMobile}>
            User Management
          </SidebarItem>
          <SidebarItem to="/economy" icon={BarChart3} collapsed={collapsed} onNavigate={onCloseMobile}>
            Economic Balance
          </SidebarItem>
        </nav>

        <div className="mt-auto pt-6 border-t border-white/10">
          <SidebarItem to="/settings" icon={Settings} collapsed={collapsed} onNavigate={onCloseMobile}>
            Settings
          </SidebarItem>
        </div>
      </aside>
    </>
  );
};
