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
  ShieldAlert
} from 'lucide-react';
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

const SidebarItem = ({ to, icon: Icon, children }: { to: string, icon: any, children: React.ReactNode }) => (
  <NavLink 
    to={to} 
    className={({ isActive }) => cn(
      "flex items-center gap-3 px-4 py-3 rounded-xl transition-all duration-200 group",
      isActive 
        ? "bg-primary/20 text-secondary border border-primary/20" 
        : "text-gray-400 hover:bg-white/5 hover:text-white"
    )}
  >
    <Icon className={cn(
      "w-5 h-5 transition-transform duration-200 group-hover:scale-110",
      "group-[.active]:text-secondary"
    )} />
    <span className="font-medium">{children}</span>
  </NavLink>
);

export const Sidebar = () => {
  return (
    <aside className="w-64 h-screen glass-dark border-r border-white/10 flex flex-col p-6 sticky top-0">
      <div className="flex items-center gap-3 mb-10 px-2">
        <div className="w-10 h-10 bg-primary rounded-xl flex items-center justify-center glow-violet">
          <Home className="text-white w-6 h-6" />
        </div>
        <div>
          <h1 className="text-lg font-bold tracking-tight">HomeSync</h1>
          <span className="text-[10px] uppercase tracking-widest text-secondary font-bold">Admin Portal</span>
        </div>
      </div>

      <nav className="flex-1 space-y-2">
        <SidebarItem to="/" icon={LayoutDashboard}>Overview</SidebarItem>
        <SidebarItem to="/logs" icon={Terminal}>Logs & Errors</SidebarItem>
        <SidebarItem to="/crashes" icon={ShieldAlert}>Crash Reports</SidebarItem>
        <SidebarItem to="/templates" icon={ClipboardList}>Task Templates</SidebarItem>
        <SidebarItem to="/users" icon={Users}>User Management</SidebarItem>
        <SidebarItem to="/economy" icon={BarChart3}>Economic Balance</SidebarItem>
      </nav>

      <div className="mt-auto pt-6 border-t border-white/5">
        <SidebarItem to="/settings" icon={Settings}>Settings</SidebarItem>
      </div>
    </aside>
  );
};
