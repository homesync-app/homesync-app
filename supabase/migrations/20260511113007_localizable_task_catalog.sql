-- Reconstructed from remote migration history (version 20260511113007).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.

-- Localizable task catalog metadata.
-- Keeps user-authored task titles intact while allowing system catalog items
-- to render in the viewer's active locale.

begin;

alter table public.categories
  add column if not exists translation_key text;

alter table public.task_templates
  add column if not exists translation_key text;

alter table public.tasks
  add column if not exists source_template_id uuid references public.task_templates(id) on delete set null,
  add column if not exists title_key text;

create unique index if not exists categories_translation_key_unique
  on public.categories (translation_key)
  where translation_key is not null;

create unique index if not exists task_templates_translation_key_unique
  on public.task_templates (translation_key)
  where translation_key is not null;

create index if not exists tasks_source_template_id_idx
  on public.tasks (source_template_id)
  where source_template_id is not null;

with mapped(id, translation_key) as (
  values
  ('limpieza', 'taskCategoryCleaningGeneral'),
  ('cocina', 'taskCategoryKitchen'),
  ('dormitorio', 'taskCategoryBedroom'),
  ('baâ”œâ–’o', 'taskCategoryBathroom'),
  ('sala', 'taskCategoryCommonSpaces'),
  ('ropa', 'taskCategoryLaundry'),
  ('residuos', 'taskCategoryTrashRecycling'),
  ('compras', 'taskCategoryShoppingOrganization'),
  ('mascotas', 'taskCategoryPets'),
  ('exterior', 'taskCategoryOutdoorGarden'),
  ('mantenimiento', 'taskCategoryHomeMaintenance'),
  ('niâ”œâ–’os', 'taskCategoryKidsCare'),
  ('administracion', 'taskCategoryHomeAdmin')
)
update public.categories c
set translation_key = mapped.translation_key
from mapped
where c.id = mapped.id;

with mapped(category_id, title, translation_key) as (
  values
  ('limpieza', 'Barrer pisos', 'taskTemplateSweepFloors'),
  ('limpieza', 'Aspirar pisos o alfombras', 'taskTemplateVacuumFloorsOrRugs'),
  ('limpieza', 'Trapear / fregar pisos', 'taskTemplateMopFloors'),
  ('limpieza', 'Limpiar polvo de muebles', 'taskTemplateDustFurniture'),
  ('limpieza', 'Limpiar ventanas', 'taskTemplateCleanWindows'),
  ('limpieza', 'Orden general de la casa', 'taskTemplateGeneralHouseTidying'),
  ('limpieza', 'Limpieza profunda general', 'taskTemplateDeepCleanGeneral'),
  ('cocina', 'Lavar los platos', 'taskTemplateWashDishes'),
  ('cocina', 'Guardar / vaciar lavavajillas', 'taskTemplateEmptyDishwasher'),
  ('cocina', 'Cocinar comida sencilla', 'taskTemplateCookSimpleMeal'),
  ('cocina', 'Cocinar comida completa', 'taskTemplateCookFullMeal'),
  ('cocina', 'Poner la mesa', 'taskTemplateSetTable'),
  ('cocina', 'Levantar la mesa', 'taskTemplateClearTable'),
  ('cocina', 'Limpiar mesada y superficies', 'taskTemplateCleanCounters'),
  ('cocina', 'Limpiar cocina completa', 'taskTemplateCleanFullKitchen'),
  ('cocina', 'Limpiar heladera', 'taskTemplateCleanFridge'),
  ('cocina', 'Limpiar horno', 'taskTemplateCleanOven'),
  ('cocina', 'Organizar despensa', 'taskTemplateOrganizePantry'),
  ('dormitorio', 'Hacer la cama', 'taskTemplateMakeBed'),
  ('dormitorio', 'Ordenar habitaciâ”œâ”‚n', 'taskTemplateTidyBedroom'),
  ('dormitorio', 'Cambiar sâ”œÃ­banas', 'taskTemplateChangeSheets'),
  ('dormitorio', 'Ordenar placard', 'taskTemplateOrganizeCloset'),
  ('dormitorio', 'Limpieza general del dormitorio', 'taskTemplateBedroomGeneralClean'),
  ('baâ”œâ–’o', 'Limpiar inodoro', 'taskTemplateCleanToilet'),
  ('baâ”œâ–’o', 'Limpiar lavamanos', 'taskTemplateCleanSink'),
  ('baâ”œâ–’o', 'Limpiar espejo', 'taskTemplateCleanMirror'),
  ('baâ”œâ–’o', 'Limpiar ducha / baâ”œâ–’era', 'taskTemplateCleanShowerTub'),
  ('baâ”œâ–’o', 'Reponer papel higiâ”œÂ®nico o jabâ”œâ”‚n', 'taskTemplateRestockBathroomSupplies'),
  ('baâ”œâ–’o', 'Limpieza completa del baâ”œâ–’o', 'taskTemplateCleanFullBathroom'),
  ('sala', 'Ordenar sala / living', 'taskTemplateTidyLivingRoom'),
  ('sala', 'Limpiar muebles', 'taskTemplateCleanFurniture'),
  ('sala', 'Limpiar sillones', 'taskTemplateCleanSofas'),
  ('sala', 'Limpiar mesa del comedor', 'taskTemplateCleanDiningTable'),
  ('sala', 'Aspirar o limpiar â”œÃ­rea comâ”œâ•‘n', 'taskTemplateCleanCommonArea'),
  ('ropa', 'Lavar ropa', 'taskTemplateWashLaundry'),
  ('ropa', 'Tender ropa', 'taskTemplateHangLaundry'),
  ('ropa', 'Usar secadora', 'taskTemplateUseDryer'),
  ('ropa', 'Doblar y guardar ropa', 'taskTemplateFoldPutAwayLaundry'),
  ('ropa', 'Planchar ropa', 'taskTemplateIronClothes'),
  ('ropa', 'Cambiar toallas', 'taskTemplateChangeTowels'),
  ('ropa', 'Organizar placard', 'taskTemplateOrganizeWardrobe'),
  ('residuos', 'Sacar la basura', 'taskTemplateTakeOutTrash'),
  ('residuos', 'Separar reciclaje', 'taskTemplateSortRecycling'),
  ('residuos', 'Llevar reciclaje', 'taskTemplateTakeRecycling'),
  ('compras', 'Hacer lista de compras', 'taskTemplateMakeShoppingList'),
  ('compras', 'Ir al supermercado', 'taskTemplateGoGroceryShopping'),
  ('compras', 'Guardar compras', 'taskTemplatePutAwayGroceries'),
  ('compras', 'Planificar menâ”œâ•‘ semanal', 'taskTemplatePlanWeeklyMenu'),
  ('mascotas', 'Dar de comer a la mascota', 'taskTemplateFeedPet'),
  ('mascotas', 'Pasear mascota', 'taskTemplateWalkPet'),
  ('mascotas', 'Limpiar arenero / â”œÃ­rea', 'taskTemplateCleanPetArea'),
  ('mascotas', 'Baâ”œâ–’ar mascota', 'taskTemplateBathePet'),
  ('mascotas', 'Limpieza general de zona de mascota', 'taskTemplatePetAreaGeneralClean'),
  ('exterior', 'Regar plantas', 'taskTemplateWaterPlants'),
  ('exterior', 'Limpiar patio / terraza', 'taskTemplateCleanPatioTerrace'),
  ('exterior', 'Juntar hojas', 'taskTemplateRakeLeaves'),
  ('exterior', 'Cortar câ”œÂ®sped', 'taskTemplateMowLawn'),
  ('exterior', 'Ordenar jardâ”œÂ¡n', 'taskTemplateTidyGarden'),
  ('mantenimiento', 'Cambiar bombillas', 'taskTemplateChangeLightBulbs'),
  ('mantenimiento', 'Pequeâ”œâ–’o arreglo del hogar', 'taskTemplateSmallHomeRepair'),
  ('mantenimiento', 'Revisiâ”œâ”‚n de filtros', 'taskTemplateCheckFilters'),
  ('mantenimiento', 'Desatascar desagâ”œâ•es', 'taskTemplateUnclogDrains'),
  ('mantenimiento', 'Arreglo mediano', 'taskTemplateMediumRepair'),
  ('mantenimiento', 'Arreglo grande', 'taskTemplateLargeRepair'),
  ('niâ”œâ–’os', 'Ordenar juguetes', 'taskTemplateTidyToys'),
  ('niâ”œâ–’os', 'Dar de comer', 'taskTemplateFeedKids'),
  ('niâ”œâ–’os', 'Ayudar con tareas escolares', 'taskTemplateHelpWithHomework'),
  ('niâ”œâ–’os', 'Llevar o buscar del colegio', 'taskTemplateSchoolPickupDropoff'),
  ('niâ”œâ–’os', 'Baâ”œâ–’ar niâ”œâ–’os', 'taskTemplateBatheKids'),
  ('administracion', 'Pagar facturas', 'taskTemplatePayBills'),
  ('administracion', 'Revisar gastos del hogar', 'taskTemplateReviewHouseholdExpenses'),
  ('administracion', 'Organizar documentos', 'taskTemplateOrganizeDocuments'),
  ('administracion', 'Planificar tareas del hogar', 'taskTemplatePlanHouseholdTasks')
)
update public.task_templates tt
set translation_key = mapped.translation_key
from mapped
where tt.category_id = mapped.category_id
  and tt.title = mapped.title;

update public.tasks t
set source_template_id = tt.id,
    title_key = tt.translation_key
from public.task_templates tt
where t.source_template_id is null
  and t.title_key is null
  and tt.translation_key is not null
  and t.category = tt.category_id
  and t.title = tt.title;

create or replace function public.clone_task_templates(
  p_user_id uuid,
  p_template_ids uuid[] default null::uuid[]
)
returns integer
language plpgsql
security definer
set search_path to 'public'
as $$
declare
  v_household_id uuid;
  v_cloned_count integer := 0;
  v_template record;
begin
  select household_id into v_household_id
  from public.household_members
  where user_id = p_user_id
  limit 1;

  if v_household_id is null then
    insert into public.households (name)
    values ('Mi Hogar')
    returning id into v_household_id;

    insert into public.household_members (household_id, user_id, role)
    values (v_household_id, p_user_id, 'owner');
  end if;

  for v_template in
    select *
    from public.task_templates
    where p_template_ids is null or id = any(p_template_ids)
    order by category_id, sort_order
  loop
    insert into public.tasks (
      id, household_id, created_by_id, title, category, difficulty,
      xp_reward, coin_reward, status, source_template_id, title_key
    ) values (
      gen_random_uuid(), v_household_id, p_user_id, v_template.title,
      v_template.category_id, v_template.difficulty, v_template.xp_reward,
      v_template.coin_reward, 'active', v_template.id, v_template.translation_key
    );
    v_cloned_count := v_cloned_count + 1;
  end loop;

  return v_cloned_count;
end;
$$;

grant execute on function public.clone_task_templates(uuid, uuid[]) to authenticated;

create or replace function public.reject_sensitive_task_updates()
returns trigger
language plpgsql
volatile
set search_path = public
as $$
declare
  v_caller uuid;
  v_is_admin boolean;
  v_old_safe jsonb;
  v_new_safe jsonb;
begin
  if current_user in ('postgres', 'service_role', 'supabase_admin') then
    return NEW;
  end if;

  v_caller := public.current_app_user_id();
  if v_caller is null then
    raise exception 'Not authenticated' using errcode = '28000';
  end if;

  if NEW.household_id is distinct from OLD.household_id then
    raise exception 'Tasks cannot be moved between households'
      using errcode = '42501';
  end if;

  select exists (
    select 1
    from public.household_members hm
    where hm.household_id = OLD.household_id
      and hm.user_id = v_caller
      and hm.role in ('owner', 'admin')
  ) into v_is_admin;

  v_old_safe := to_jsonb(OLD)
    - 'title'
    - 'description'
    - 'category'
    - 'type'
    - 'difficulty'
    - 'xp_reward'
    - 'coin_reward'
    - 'priority'
    - 'assigned_to'
    - 'due_at'
    - 'recurrence_type'
    - 'recurrence_interval'
    - 'recurrence_weekdays'
    - 'recurrence_month_days'
    - 'rotation_pool'
    - 'rotation_strategy'
    - 'rotation_index'
    - 'source_template_id'
    - 'title_key'
    - 'updated_at';
  v_new_safe := to_jsonb(NEW)
    - 'title'
    - 'description'
    - 'category'
    - 'type'
    - 'difficulty'
    - 'xp_reward'
    - 'coin_reward'
    - 'priority'
    - 'assigned_to'
    - 'due_at'
    - 'recurrence_type'
    - 'recurrence_interval'
    - 'recurrence_weekdays'
    - 'recurrence_month_days'
    - 'rotation_pool'
    - 'rotation_strategy'
    - 'rotation_index'
    - 'source_template_id'
    - 'title_key'
    - 'updated_at';

  if v_new_safe is distinct from v_old_safe and not v_is_admin then
    raise exception 'Task completion and approval fields require RPC/admin flow'
      using errcode = '42501';
  end if;

  return NEW;
end;
$$;

comment on column public.categories.translation_key is
  'ARB key used by the client to localize system task category names.';
comment on column public.task_templates.translation_key is
  'ARB key used by the client to localize system task template titles.';
comment on column public.tasks.source_template_id is
  'Original system template for localizable catalog tasks. Null for user-authored custom tasks.';
comment on column public.tasks.title_key is
  'ARB key for localizing a system-origin task title. Null means display tasks.title as user-authored text.';
comment on function public.reject_sensitive_task_updates() is
  'Blocks direct member updates to task completion/approval fields and cross-household moves; allows task catalog localization metadata edits.';

commit;
