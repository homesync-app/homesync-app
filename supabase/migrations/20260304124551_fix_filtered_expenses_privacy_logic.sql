-- Reconstructed from remote migration history (version 20260304124551).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

CREATE OR REPLACE FUNCTION public.get_filtered_expenses(
  p_household_id uuid, 
  p_type text DEFAULT 'all', 
  p_sharing text DEFAULT 'all', 
  p_limit int DEFAULT 50, 
  p_offset int DEFAULT 0
)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    result jsonb;
BEGIN
  -- Logic for p_sharing explained:
  -- 'all': Everything in the household (Shared + Personal of everyone?) 
  --        Actually, usually one partner shouldn't see another's strictly personal stuff unless it's shared.
  --        But for a couple app, often you want to see everything.
  -- 'mine': Everything PAID BY me (Shared or Personal) + items where I'm a debtor?
  --         Let's keep it simple: Everything PAID BY me OR Shared with me.
  -- 'shared': Only items marked as is_shared = true.

  SELECT jsonb_agg(sub) INTO result
  FROM (
    SELECT 
      e.*,
      jsonb_build_object(
        'full_name', u.full_name,
        'email', u.email,
        'avatar_url', u.avatar_url
      ) as payer
    FROM public.expenses e
    JOIN public.users u ON e.paid_by = u.id
    WHERE e.household_id = p_household_id
      AND (p_type = 'all' OR e.type::text = p_type)
      AND (
        p_sharing = 'all' -- Show everything in the household
        OR (p_sharing = 'mine' AND (e.paid_by = auth.uid() OR e.is_shared = true)) -- Show my stuff or shared stuff
        OR (p_sharing = 'shared' AND e.is_shared = true)
      )
    ORDER BY e.paid_at DESC
    LIMIT p_limit
    OFFSET p_offset
  ) sub;
  
  RETURN COALESCE(result, '[]'::jsonb);
END;
$function$;
;