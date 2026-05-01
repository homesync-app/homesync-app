import { useState } from 'react';
import { supabase } from '../lib/supabase';
import {
  Settings as SettingsIcon,
  LogOut,
  Key,
  User,
  Shield,
  Loader2,
  CheckCircle2,
} from 'lucide-react';

export const Settings = () => {
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null);

  const [currentPassword, setCurrentPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');

  const handleChangePassword = async (e: React.FormEvent) => {
    e.preventDefault();
    setMessage(null);

    if (newPassword !== confirmPassword) {
      setMessage({ type: 'error', text: 'Las contraseñas no coinciden.' });
      return;
    }

    if (newPassword.length < 6) {
      setMessage({ type: 'error', text: 'La contraseña debe tener al menos 6 caracteres.' });
      return;
    }

    setLoading(true);
    const { error } = await supabase.auth.updateUser({ password: newPassword });

    if (error) {
      setMessage({ type: 'error', text: error.message });
    } else {
      setMessage({ type: 'success', text: 'Contraseña actualizada correctamente.' });
      setCurrentPassword('');
      setNewPassword('');
      setConfirmPassword('');
    }
    setLoading(false);
  };

  const handleLogout = async () => {
    await supabase.auth.signOut();
  };

  return (
    <div className="space-y-8 animate-in fade-in duration-500">
      <div>
        <h2 className="text-3xl font-bold tracking-tight flex items-center gap-3">
          <SettingsIcon className="w-8 h-8 text-secondary" />
          Configuración
        </h2>
        <p className="text-gray-400 mt-1">
          Preferencias de administración y seguridad de la cuenta.
        </p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <div className="glass-dark p-8 rounded-3xl border border-white/5">
          <div className="flex items-center gap-3 mb-6">
            <div className="p-2.5 rounded-xl bg-primary/10 text-primary">
              <Key className="w-5 h-5" />
            </div>
            <div>
              <h3 className="text-lg font-bold">Cambiar Contraseña</h3>
              <p className="text-xs text-gray-500">Actualizá tu contraseña de acceso al admin.</p>
            </div>
          </div>

          <form onSubmit={handleChangePassword} className="space-y-4">
            <div>
              <label className="block text-xs font-bold text-gray-400 uppercase tracking-widest mb-2 px-1">
                Contraseña actual
              </label>
              <input
                type="password"
                required
                value={currentPassword}
                onChange={(e) => setCurrentPassword(e.target.value)}
                className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 focus:outline-none focus:ring-2 focus:ring-primary/50"
                placeholder="••••••••"
              />
            </div>
            <div>
              <label className="block text-xs font-bold text-gray-400 uppercase tracking-widest mb-2 px-1">
                Nueva contraseña
              </label>
              <input
                type="password"
                required
                value={newPassword}
                onChange={(e) => setNewPassword(e.target.value)}
                className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 focus:outline-none focus:ring-2 focus:ring-primary/50"
                placeholder="••••••••"
              />
            </div>
            <div>
              <label className="block text-xs font-bold text-gray-400 uppercase tracking-widest mb-2 px-1">
                Confirmar contraseña
              </label>
              <input
                type="password"
                required
                value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
                className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 focus:outline-none focus:ring-2 focus:ring-primary/50"
                placeholder="••••••••"
              />
            </div>

            {message && (
              <div
                className={`flex items-center gap-2 px-4 py-3 rounded-xl text-sm font-medium ${
                  message.type === 'success'
                    ? 'bg-emerald-500/10 border border-emerald-500/20 text-emerald-400'
                    : 'bg-rose-500/10 border border-rose-500/20 text-rose-400'
                }`}
              >
                {message.type === 'success' && <CheckCircle2 className="w-4 h-4" />}
                {message.text}
              </div>
            )}

            <button
              type="submit"
              disabled={loading}
              className="w-full py-3 bg-primary text-white font-bold rounded-xl hover:opacity-90 transition-all flex items-center justify-center gap-2"
            >
              {loading ? <Loader2 className="w-5 h-5 animate-spin" /> : 'Actualizar Contraseña'}
            </button>
          </form>
        </div>

        <div className="space-y-6">
          <div className="glass-dark p-8 rounded-3xl border border-white/5">
            <div className="flex items-center gap-3 mb-4">
              <div className="p-2.5 rounded-xl bg-indigo-500/10 text-indigo-400">
                <User className="w-5 h-5" />
              </div>
              <div>
                <h3 className="text-lg font-bold">Información de la Cuenta</h3>
                <p className="text-xs text-gray-500">Datos de tu sesión actual.</p>
              </div>
            </div>
            <div className="space-y-3">
              <div className="bg-white/5 rounded-xl px-4 py-3">
                <p className="text-[10px] text-gray-500 uppercase tracking-widest mb-0.5">Rol</p>
                <p className="text-sm font-medium">Administrador</p>
              </div>
              <div className="bg-white/5 rounded-xl px-4 py-3">
                <p className="text-[10px] text-gray-500 uppercase tracking-widest mb-0.5">Entorno</p>
                <p className="text-sm font-medium">Local (localhost)</p>
              </div>
            </div>
          </div>

          <div className="glass-dark p-8 rounded-3xl border border-white/5">
            <div className="flex items-center gap-3 mb-4">
              <div className="p-2.5 rounded-xl bg-secondary/10 text-secondary">
                <Shield className="w-5 h-5" />
              </div>
              <div>
                <h3 className="text-lg font-bold">Seguridad</h3>
                <p className="text-xs text-gray-500">Autenticación y acceso.</p>
              </div>
            </div>
            <div className="space-y-3">
              <div className="bg-white/5 rounded-xl px-4 py-3">
                <p className="text-[10px] text-gray-500 uppercase tracking-widest mb-0.5">Proveedor</p>
                <p className="text-sm font-medium">Supabase Auth (Email + Password)</p>
              </div>
              <div className="bg-white/5 rounded-xl px-4 py-3">
                <p className="text-[10px] text-gray-500 uppercase tracking-widest mb-0.5">Conexión</p>
                <p className="text-sm font-medium flex items-center gap-2">
                  <span className="w-2 h-2 rounded-full bg-emerald-500" />
                  Cifrada (HTTPS)
                </p>
              </div>
            </div>
          </div>

          <button
            onClick={handleLogout}
            className="w-full py-4 bg-rose-500/10 border border-rose-500/20 text-rose-400 font-bold rounded-2xl hover:bg-rose-500/20 transition-all flex items-center justify-center gap-2"
          >
            <LogOut className="w-5 h-5" />
            Cerrar Sesión
          </button>
        </div>
      </div>
    </div>
  );
};
