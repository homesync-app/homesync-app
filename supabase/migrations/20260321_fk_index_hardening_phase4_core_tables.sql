-- Phase 4: FK index hardening for core finance/notification tables
BEGIN;

CREATE INDEX IF NOT EXISTS idx_application_logs_user_id
  ON public.application_logs (user_id);

CREATE INDEX IF NOT EXISTS idx_expense_template_history_template_id
  ON public.expense_template_history (template_id);

CREATE INDEX IF NOT EXISTS idx_expense_templates_household_id
  ON public.expense_templates (household_id);

CREATE INDEX IF NOT EXISTS idx_expense_templates_payer_default
  ON public.expense_templates (payer_default);

CREATE INDEX IF NOT EXISTS idx_expenses_created_by_id
  ON public.expenses (created_by_id);

CREATE INDEX IF NOT EXISTS idx_expenses_planned_expense_id
  ON public.expenses (planned_expense_id);

CREATE INDEX IF NOT EXISTS idx_household_activities_user_id
  ON public.household_activities (user_id);

CREATE INDEX IF NOT EXISTS idx_notifications_created_by_id
  ON public.notifications (created_by_id);

CREATE INDEX IF NOT EXISTS idx_planned_expenses_expense_id
  ON public.planned_expenses (expense_id);

CREATE INDEX IF NOT EXISTS idx_planned_expenses_payer_default
  ON public.planned_expenses (payer_default);

COMMIT;