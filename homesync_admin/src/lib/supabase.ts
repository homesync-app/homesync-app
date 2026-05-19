import { createClient } from '@supabase/supabase-js';

const useLocalProxy = import.meta.env.VITE_ADMIN_LOCAL_PROXY === 'true';
const supabaseUrl = useLocalProxy
  ? `${window.location.origin}/admin-api/supabase`
  : import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  console.error('Missing Supabase environment variables');
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
