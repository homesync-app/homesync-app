-- ============================================
-- Fix settle_debt_v1: clean UTF-8 title and harden idempotency contract
-- ============================================
-- Contexto:
--   La migración 20260519204019_settle_debt_v1.sql reconstruyó la RPC
--   settle_debt_v1 desde el history de prod, pero el título del expense
--   generado quedó con bytes mal decodificados
--   ('Liquidaciâ"o"n de balance' en vez de 'Liquidación de balance').
--
--   Como el cliente Flutter aún no llama a settle_debt_v1, este mojibake
--   no se ve hoy. Ahora que vamos a wirear el cliente al RPC
--   (idempotency con request_id), el título roto saldría directo al
--   feed. Esta migración reemplaza la función con el título limpio y
--   deja explícita la idempotencia para que el gate de smoke la
--   pueda validar.
--
-- Estrategia:
--   - CREATE OR REPLACE FUNCTION (no DROP) para no perder grants.
--   - Mantener el signature exacto y el comportamiento de idempotencia
--     vía SELECT-before-insert + EXCEPTION unique_violation. El cliente
--     ahora pasa p_request_id y ambos paths retornan el mismo
--     expense_id si se reintenta.
--   - No tocar expenses.request_id ni el índice uq_expenses_request_id
--     (ya quedaron en la migración 20260519).
-- ============================================

create or replace function public.settle_debt_v1(
  p_request_id text,
  p_household_id uuid,
  p_from_user_id uuid,
  p_to_user_id uuid,
  p_amount numeric
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_expense_id uuid;
  v_existing_id uuid;
  v_actor uuid := public.current_app_user_id();
begin
  if v_actor is null then
    return jsonb_build_object(
      'success', false, 'message', 'Not authenticated', 'status', 'unauthenticated'
    );
  end if;

  if p_request_id is null or length(trim(p_request_id)) = 0 then
    return jsonb_build_object(
      'success', false, 'message', 'request_id is required', 'status', 'invalid'
    );
  end if;

  if p_household_id is null or p_from_user_id is null or p_to_user_id is null then
    return jsonb_build_object(
      'success', false, 'message', 'household and users are required', 'status', 'invalid'
    );
  end if;

  if p_amount is null or p_amount <= 0 then
    return jsonb_build_object(
      'success', false, 'message', 'amount must be greater than 0', 'status', 'invalid'
    );
  end if;

  -- Idempotency check: si ya existe un expense con este request_id,
  -- devolvemos el mismo expense_id sin crear un duplicado. Esto cubre
  -- el caso de doble-tap o reintento por timeout de red.
  select id into v_existing_id
  from public.expenses
  where request_id = p_request_id;

  if found then
    return jsonb_build_object(
      'success', true,
      'message', 'Already settled',
      'status', 'idempotent',
      'expense_id', v_existing_id,
      'idempotent', true
    );
  end if;

  v_expense_id := public.save_expense_v4(
    p_id          := null,
    p_household_id := p_household_id,
    p_title       := 'Liquidación de balance',
    p_amount      := p_amount,
    p_category    := 'other',
    p_paid_by     := p_from_user_id,
    p_paid_at     := now(),
    p_description := 'Saldar balance acumulado',
    p_split_type  := 'fixed',
    p_is_shared   := true,
    p_type        := 'settlement',
    p_splits      := jsonb_build_array(
                       jsonb_build_object('user_id', p_to_user_id, 'amount', p_amount)
                     ),
    p_receipt_path := null
  );

  update public.expenses
  set request_id = p_request_id
  where id = v_expense_id;

  insert into public.audit_logs (
    request_id, user_id, household_id, action, entity_type, entity_id,
    new_value, reason, source
  ) values (
    p_request_id,
    v_actor,
    p_household_id,
    'settle_debt',
    'expense',
    v_expense_id,
    jsonb_build_object(
      'from_user_id', p_from_user_id,
      'to_user_id', p_to_user_id,
      'amount', p_amount
    ),
    'Debt settled',
    'rpc'
  );

  return jsonb_build_object(
    'success', true,
    'message', 'Debt settled',
    'status', 'settled',
    'expense_id', v_expense_id,
    'idempotent', false
  );
exception
  when unique_violation then
    -- Carrera: otra request con el mismo request_id se insertó primero.
    -- Resolvemos al expense ganador y devolvemos idempotente.
    select id into v_existing_id
    from public.expenses
    where request_id = p_request_id;

    return jsonb_build_object(
      'success', true,
      'message', 'Already settled',
      'status', 'idempotent',
      'expense_id', v_existing_id,
      'idempotent', true
    );
end;
$$;

-- Re-confirmar grants por si CREATE OR REPLACE alteró el acl.
grant execute on function public.settle_debt_v1(text, uuid, uuid, uuid, numeric)
  to authenticated, service_role;

-- Revocar explícitamente de anon si quedó de una iteración anterior.
revoke execute on function public.settle_debt_v1(text, uuid, uuid, uuid, numeric)
  from anon;
