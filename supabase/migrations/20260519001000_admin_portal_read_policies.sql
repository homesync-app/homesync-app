-- Let authenticated app admins inspect the operational tables used by the
-- HomeSync admin portal without weakening normal user-facing RLS.

do $$
declare
  table_name text;
begin
  foreach table_name in array array[
    'application_logs',
    'categories',
    'error_issues',
    'household_activities',
    'ledger_entries',
    'ocr_scan_logs',
    'reward_templates',
    'shopping_items',
    'task_templates',
    'tasks'
  ]
  loop
    execute format(
      'drop policy if exists %I on public.%I',
      'admins can read ' || table_name,
      table_name
    );

    execute format(
      'create policy %I on public.%I for select to authenticated using (public.is_current_app_admin())',
      'admins can read ' || table_name,
      table_name
    );
  end loop;
end $$;

do $$
declare
  view_name text;
begin
  foreach view_name in array array[
    'v_manual_items_no_icon',
    'v_ocr_daily_stats',
    'v_ocr_dropped_items',
    'v_ocr_unmatched_items'
  ]
  loop
    execute format('grant select on public.%I to authenticated', view_name);
  end loop;
end $$;

notify pgrst, 'reload schema';
