-- =============================================================================
-- settle_debt_v1: versioned, transactional, idempotent debt settlement
-- =============================================================================
-- Riesgo que cierra esta migracion (backlog seccion 1/4, prioridad financiera):
--   El cliente saldaba deudas llamando save_expense_v4 directo con
--   p_type:'settlement' y, en el camino offline, encolaba la MISMA accion con
--   params identicos y SIN idempotency key. Reintentar / reconectar registraba
--   el pago dos veces (doble settlement, balance inconsistente). En una app de
--   plata es el gap mas peligroso.
--
-- Estrategia (mismo patron que 20260514120000_task_commands_v1.sql):
--   1. Agregar columna request_id text a public.expenses + unique index
--      parcial (where request_id is not null). Filas historicas quedan null.
--   2. settle_debt_v1 reusa save_expense_v4 como capa canonica (no duplicamos
--      la logica de expense+splits) y agrega el guard de idempotencia:
--        - pre-check por request_id: si ya existe, devuelve esa expense (no-op).
--        - si no, crea via save_expense_v4 y taggea expenses.request_id.
--      El UPDATE del request_id choca contra el unique index si dos requests
--      identicos corren en paralelo; el UPDATE fallido hace rollback de la
--      expense recien creada (misma transaccion) => persiste exactamente UNA
--      liquidacion. Race-safe.
--   3. No hay wrapper legacy: el cliente nunca llamo a un RPC 'settle_debt';
--      saldaba via save_expense_v4 (que NO se rerutea porque lo usa toda la
--      creacion de gastos). El cliente pasa a settle_debt_v1 con un
--      request_id estable reusado entre el intento online y la cola offline.
--
-- Nota: settle_debt(p_user_id,p_household_id,p_to_user_id,p_amount) legacy
-- queda intacta; no la usa el cliente.
--
-- Contrato documentado en docs/rpc_contracts.md.
-- =============================================================================

-- 1. Columna de idempotencia ---------------------------------------------------

alter table public.expenses
  add column if not exists request_id text;

create unique index if not exists uq_expenses_request_id
  on public.expenses (request_id)
  where request_id is not null;


-- 2. settle_debt_v1 -----------------------------------------------------------

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

  -- Idempotencia: si ya se registro esta liquidacion, devolvemos la misma
  -- expense sin crear otra (caso comun: retry / replay de cola offline).
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

  -- Capa canonica: misma logica/validaciones que el resto de la creacion de
  -- gastos. save_expense_v4 valida auth y membresia de hogar/paid_by.
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

  -- Tag idempotente. Si dos requests identicos corren en paralelo, ambos
  -- pasaron el pre-check y crearon su expense; el segundo UPDATE viola
  -- uq_expenses_request_id y hace rollback de su expense (misma transaccion):
  -- queda exactamente una liquidacion.
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
    -- Carrera resuelta por el unique index: otra transaccion ya registro
    -- esta liquidacion. Devolvemos la existente (esta tx hizo rollback de su
    -- expense duplicada).
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

grant execute on function public.settle_debt_v1(text, uuid, uuid, uuid, numeric)
  to authenticated, service_role;
