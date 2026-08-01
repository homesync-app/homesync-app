-- Indexes que cubren las 34 FKs sin indice reportadas por el advisor de performance.
-- Tablas chicas hoy; el costo de escritura es despreciable y evita seq-scans en
-- joins/cascadas de borrado a medida que crezcan.
-- Aplicada a prod via MCP el 2026-07-19.
create index if not exists idx_allowance_schedules_household_id on public.allowance_schedules (household_id);
create index if not exists idx_allowance_schedules_to_user_id on public.allowance_schedules (to_user_id);
create index if not exists idx_category_budgets_owner_user_id on public.category_budgets (owner_user_id);
create index if not exists idx_expense_pools_created_by on public.expense_pools (created_by);
create index if not exists idx_expense_pools_household_id on public.expense_pools (household_id);
create index if not exists idx_household_invitations_created_by on public.household_invitations (created_by);
create index if not exists idx_household_invitations_used_by on public.household_invitations (used_by);
create index if not exists idx_households_split_ratio_anchor_id on public.households (split_ratio_anchor_id);
create index if not exists idx_households_subscription_owner_user_id on public.households (subscription_owner_user_id);
create index if not exists idx_reward_redemptions_fulfilled_by on public.reward_redemptions (fulfilled_by);
create index if not exists idx_reward_redemptions_reward_id on public.reward_redemptions (reward_id);
create index if not exists idx_rewards_created_by on public.rewards (created_by);
create index if not exists idx_rewards_source_template_id on public.rewards (source_template_id);
create index if not exists idx_rewards_suggested_to on public.rewards (suggested_to);
create index if not exists idx_savings_contributions_goal_id on public.savings_contributions (goal_id);
create index if not exists idx_savings_contributions_user_id on public.savings_contributions (user_id);
create index if not exists idx_savings_goals_created_by on public.savings_goals (created_by);
create index if not exists idx_shopping_items_added_by on public.shopping_items (added_by);
create index if not exists idx_shopping_items_completed_by on public.shopping_items (completed_by);
create index if not exists idx_task_approvals_decided_by on public.task_approvals (decided_by);
create index if not exists idx_task_approvals_submitted_by on public.task_approvals (submitted_by);
create index if not exists idx_task_templates_category_id on public.task_templates (category_id);
create index if not exists idx_tasks_category on public.tasks (category);
create index if not exists idx_tasks_completed_by on public.tasks (completed_by);
create index if not exists idx_tasks_last_verified_by on public.tasks (last_verified_by);
create index if not exists idx_tasks_objected_by on public.tasks (objected_by);
create index if not exists idx_tasks_recurrence_parent_id on public.tasks (recurrence_parent_id);
create index if not exists idx_tasks_rejected_by on public.tasks (rejected_by);
create index if not exists idx_tasks_verified_by on public.tasks (verified_by);
create index if not exists idx_user_feedback_responses_responder_user_id on public.user_feedback_responses (responder_user_id);
create index if not exists idx_weekly_duel_history_loser_user_id on public.weekly_duel_history (loser_user_id);
create index if not exists idx_weekly_duel_history_winner_user_id on public.weekly_duel_history (winner_user_id);
create index if not exists idx_weekly_winners_user_id on public.weekly_winners (user_id);
-- Nota: task_templates tiene DOS constraints FK sobre category_id
-- (fk_task_templates_category y task_templates_category_id_fkey); un solo
-- indice cubre ambas. La constraint duplicada queda para limpiar aparte.
