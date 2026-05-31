import { supabase } from './supabase';

// ─── Types ───────────────────────────────────────────────────────────────────

export interface AdminUserRow {
  user_id: string;
  email: string | null;
  full_name: string | null;
  avatar_url: string | null;
  is_admin: boolean;
  is_deleted: boolean;
  household_id: string | null;
  household_name: string | null;
  household_type: string | null;
  plan_tier: string | null;
  premium_until: string | null;
  household_is_premium: boolean;
  household_role: string | null;
}

export interface ActiveUserStats {
  total_users: number;
  active_1d: number;
  active_7d: number;
  active_30d: number;
  recurrent_7d: number;
  stickiness_pct: number;
  daily: { day: string; active_users: number }[];
  generated_at: string;
}

// ─── RPC wrappers ──────────────────────────────────────────────────────────--

/** Search users by email or name (admin-gated server-side). */
export async function adminSearchUsers(query: string, limit = 25): Promise<AdminUserRow[]> {
  const { data, error } = await supabase.rpc('admin_search_users', {
    p_query: query,
    p_limit: limit,
  });
  if (error) throw error;
  return (data ?? []) as AdminUserRow[];
}

/** Toggle premium for a household (admin-gated server-side). */
export async function adminSetHouseholdPremium(
  householdId: string,
  isPremium: boolean,
  premiumUntil: string | null,
): Promise<void> {
  const { data, error } = await supabase.rpc('admin_set_household_premium', {
    p_household_id: householdId,
    p_is_premium: isPremium,
    p_premium_until: premiumUntil,
  });
  if (error) throw error;
  const result = data as { success?: boolean; message?: string } | null;
  if (result && result.success === false) {
    throw new Error(result.message ?? 'No se pudo actualizar el premium.');
  }
}

/** Active-user metrics (admin-gated server-side). */
export async function adminGetActiveUserStats(): Promise<ActiveUserStats> {
  const { data, error } = await supabase.rpc('admin_get_active_user_stats');
  if (error) throw error;
  return data as ActiveUserStats;
}
