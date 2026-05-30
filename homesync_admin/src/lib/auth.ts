import { useEffect, useState } from 'react';
import { supabase } from './supabase';

/**
 * Skipping auth is only ever allowed during local development (`vite dev`).
 * In any production build (`vite build`) `import.meta.env.DEV` is false, so the
 * login screen is always enforced regardless of what `VITE_SKIP_AUTH` says.
 * This prevents a stray `.env.local` from shipping an unauthenticated panel.
 */
export const SKIP_AUTH =
  import.meta.env.VITE_SKIP_AUTH === 'true' && import.meta.env.DEV;

export interface AdminEnvInfo {
  host: string;
  mode: 'Desarrollo' | 'Producción';
}

export function getEnvInfo(): AdminEnvInfo {
  const url = import.meta.env.VITE_SUPABASE_URL as string | undefined;
  let host = 'desconocido';
  if (url) {
    try {
      host = new URL(url).host;
    } catch {
      host = url;
    }
  }
  return {
    host,
    mode: import.meta.env.DEV ? 'Desarrollo' : 'Producción',
  };
}

/** Reactive access to the currently authenticated admin email (if any). */
export function useAdminEmail(): string | null {
  const [email, setEmail] = useState<string | null>(null);

  useEffect(() => {
    let active = true;

    supabase.auth.getUser().then(({ data }) => {
      if (active) setEmail(data.user?.email ?? null);
    });

    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, session) => {
      setEmail(session?.user?.email ?? null);
    });

    return () => {
      active = false;
      subscription.unsubscribe();
    };
  }, []);

  return email;
}
