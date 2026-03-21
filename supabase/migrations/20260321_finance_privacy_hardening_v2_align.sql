-- Align local migrations with applied MCP migration finance_privacy_hardening_v2
-- Delta over 20260321_finance_privacy_hardening.sql: explicit drop for return-type replacement
-- and removal of legacy overloaded RPC signature.

DROP FUNCTION IF EXISTS public.get_expense_balance(UUID);

DROP FUNCTION IF EXISTS public.get_filtered_expenses(UUID, INTEGER, INTEGER, TEXT);
