create or replace function public.qa_admin_seed_default_rewards(
  p_household_id uuid
)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_created_by uuid;
  v_inserted_count integer := 0;
  v_household_type text;
begin
  perform public.qa_admin_require_access();

  select household_type
    into v_household_type
  from public.qa_admin_household_defaults(p_household_id)
  where household_name is not null;

  if v_household_type is null then
    raise exception 'Escenario QA invalido';
  end if;

  if exists (
    select 1
    from public.rewards
    where household_id = p_household_id
  ) then
    return 0;
  end if;

  select hm.user_id
    into v_created_by
  from public.household_members hm
  where hm.household_id = p_household_id
  order by case when hm.role = 'owner' then 0 else 1 end, hm.joined_at, hm.user_id
  limit 1;

  if v_household_type = 'family' then
    insert into public.rewards (
      household_id,
      title,
      description,
      cost,
      icon,
      is_active,
      created_by,
      is_approved,
      category,
      target_type
    )
    values
      (
        p_household_id,
        'Postre especial',
        'Elegir un postre favorito para despues de cenar.',
        25,
        '🍨',
        true,
        v_created_by,
        true,
        'familia',
        'child'
      ),
      (
        p_household_id,
        'Elegir la cena',
        'Decidir el menu de una noche en casa.',
        40,
        '🍕',
        true,
        v_created_by,
        true,
        'familia',
        'child'
      ),
      (
        p_household_id,
        '15 minutos extra de pantalla',
        'Un ratito mas para jugar o mirar algo.',
        35,
        '📱',
        true,
        v_created_by,
        true,
        'familia',
        'child'
      ),
      (
        p_household_id,
        'Juguete o premio pequeno',
        'Canje por algo simple elegido con un adulto.',
        90,
        '🧩',
        true,
        v_created_by,
        true,
        'familia',
        'child'
      ),
      (
        p_household_id,
        'Cafe o mate preparado',
        'Un mimo simple tomado del modo pareja.',
        30,
        '☕',
        true,
        v_created_by,
        true,
        'familia',
        'adult'
      ),
      (
        p_household_id,
        '15 minutos de masajes',
        'Un premio corto para bajar un cambio.',
        60,
        '💆',
        true,
        v_created_by,
        true,
        'familia',
        'adult'
      ),
      (
        p_household_id,
        'Vale por elegir la peli',
        'Elegis que ver sin negociar esa noche.',
        55,
        '🎬',
        true,
        v_created_by,
        true,
        'familia',
        'adult'
      ),
      (
        p_household_id,
        'Cena casera especial',
        'Una noche distinta con algo rico hecho en casa.',
        95,
        '🍽️',
        true,
        v_created_by,
        true,
        'familia',
        'adult'
      ),
      (
        p_household_id,
        'Noche de peli',
        'Plan simple para disfrutar todos juntos.',
        80,
        '🎥',
        true,
        v_created_by,
        true,
        'familia',
        'all'
      ),
      (
        p_household_id,
        'Helado para todos',
        'Salida o pedido de helado familiar.',
        110,
        '🍦',
        true,
        v_created_by,
        true,
        'familia',
        'all'
      ),
      (
        p_household_id,
        'Pedir comida',
        'Una noche sin cocinar para toda la familia.',
        180,
        '🥡',
        true,
        v_created_by,
        true,
        'familia',
        'all'
      ),
      (
        p_household_id,
        'Plan del fin de semana',
        'Elegir una salida o actividad para hacer juntos.',
        160,
        '🌟',
        true,
        v_created_by,
        true,
        'familia',
        'all'
      );
  else
    insert into public.rewards (
      household_id,
      title,
      description,
      cost,
      icon,
      is_active,
      created_by,
      is_approved,
      category
    )
    select
      p_household_id,
      rt.title,
      rt.description,
      rt.cost,
      coalesce(rt.icon, '🎁'),
      true,
      v_created_by,
      true,
      rt.category
    from public.reward_templates rt
    order by rt.sort_order, rt.created_at, rt.title;
  end if;

  get diagnostics v_inserted_count = row_count;
  return v_inserted_count;
end;
$$;
