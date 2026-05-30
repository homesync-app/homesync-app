-- ============================================
-- VALIDATION: Miembros solo pueden actualizar tasks_enabled
-- ============================================
-- Propósito: Permitir que cualquier miembro active/desactive tareas,
-- pero solo los owners puedan modificar otras columnas (name, household_type, etc.).
-- Aplica a: households TABLE
-- Creado: 2026-04-26
-- ============================================

-- 1) Crear función de validación
create or replace function public.validate_household_update()
returns trigger
language plpgsql
stable
set search_path = public
as $$
declare
  v_user_id uuid;
  v_is_owner boolean;
  v_changed_columns text[];
  v_col text;
begin
  -- Obtener usuario actual
  v_user_id := public.current_app_user_id();
  if v_user_id is null then
    raise exception 'No autenticado';
  end if;

  -- Obtener si es owner del hogar
  select exists (
    select 1 from public.household_members
    where household_id = NEW.id
      and user_id = v_user_id
      and role = 'owner'
  ) into v_is_owner;

  -- Si es owner, permitir cualquier cambio
  if v_is_owner then
    return NEW;
  end if;

  -- Si NO es owner: detectar columnas cambiadas (excluyendo columnas de sistema)
  v_changed_columns := array[
    case when OLD.name IS DISTINCT FROM NEW.name then 'name' end,
    case when OLD.household_type IS DISTINCT FROM NEW.household_type then 'household_type' end,
    case when OLD.tasks_enabled IS DISTINCT FROM NEW.tasks_enabled then 'tasks_enabled' end
  ];
  -- Filtrar nulls
  v_changed_columns := array_remove(v_changed_columns, null);

  -- Si no hay cambios relevantes (solo updated_at u otras), permitir
  if cardinality(v_changed_columns) = 0 then
    return NEW;
  end if;

  -- Verificar que SOLO tasks_enabled haya cambiado
  foreach v_col in array v_changed_columns loop
    if v_col != 'tasks_enabled' then
      raise exception 'Solo los propietarios pueden modificar la columna "%". Tu rol: miembro.', v_col;
    end if;
  end loop;

  return NEW;
end;
$$;

comment on function public.validate_household_update() is
  'Valida que solo owners puedan modificar columnas críticas de households. Miembros solo pueden cambiar tasks_enabled.';

-- 2) Crear trigger BEFORE UPDATE
drop trigger if exists trg_validate_household_update on public.households;

create trigger trg_validate_household_update
  before update on public.households
  for each row
  execute function public.validate_household_update();

-- 3) Actualizar política RLS: permitir a miembros actualizar households
-- (la validación de columnas la hace el trigger)
drop policy if exists "Owners can update households" on public.households;

create policy "Members can update households"
  on public.households for update
  using (public.is_current_household_member(id));

comment on policy "Members can update households" on public.households is
  'Permite a cualquier miembro actualizar households; el trigger restringe columnas editable a tasks_enabled para no-owners.';
