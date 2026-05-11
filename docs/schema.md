# HomeSync — Schema de Base de Datos

## Tablas

### AUTH / USERS

#### `users`
| Columna | Tipo | Restricciones | Notas |
|---------|------|---------------|-------|
| id | UUID | PK, default gen_random_uuid() | ID interno del usuario |
| email | TEXT | | |
| full_name | TEXT | nullable | |
| avatar_url | TEXT | nullable | Emoji, URL, o premium://id |
| mercadopago_alias | TEXT | nullable | CVU/alias de Mercado Pago |
| firebase_uid | TEXT | nullable, unique (partial) | Firebase Auth UID |
| is_admin | BOOLEAN | default false | Solo para QA |
| updated_at | TIMESTAMPTZ | | |

#### `user_fcm_tokens`
| Columna | Tipo | Restricciones |
|---------|------|---------------|
| id | UUID | PK |
| user_id | UUID | FK → users(id) ON DELETE CASCADE |
| token | TEXT | NOT NULL |
| platform | TEXT | nullable |
| created_at | TIMESTAMPTZ | default now() |
| updated_at | TIMESTAMPTZ | default now() |

Unique: (user_id, token)

---

### HOUSEHOLD

#### `households`
| Columna | Tipo | Restricciones |
|---------|------|---------------|
| id | UUID | PK |
| name | TEXT | NOT NULL, default 'Mi Hogar' |
| household_type | TEXT | NOT NULL, 'couple'/'family'/'friends' |
| display_name | TEXT | nullable |
| tasks_enabled | BOOLEAN | default true |
| default_split_ratio | DOUBLE PRECISION | default 0.5, CHECK >= 0 AND <= 1 |
| created_at | TIMESTAMPTZ | default now() |
| updated_at | TIMESTAMPTZ | default now() |

#### `household_members`
| Columna | Tipo | Restricciones |
|---------|------|---------------|
| id | UUID | PK |
| household_id | UUID | FK → households(id) NOT NULL |
| user_id | UUID | FK → users(id) NOT NULL |
| role | TEXT | NOT NULL, 'owner'/'member'/'admin' |
| member_type | TEXT | NOT NULL, default 'parent', CHECK IN ('parent','guardian','teen','child') |
| display_role | TEXT | nullable, ej: 'Padre', 'Madre', 'Hijo/a' |
| onboarding_completed | BOOLEAN | NOT NULL, default false |
| joined_at | TIMESTAMPTZ | default now() |

Unique partial: (household_id, display_role) WHERE display_role IN ('Padre', 'Madre')

#### `household_invitations`
| Columna | Tipo | Restricciones |
|---------|------|---------------|
| id | UUID | PK |
| household_id | UUID | FK → households(id) |
| code | TEXT | UNIQUE, auto-generado |
| created_by | UUID | FK → users(id) |
| used_by | UUID | nullable |
| used_at | TIMESTAMPTZ | nullable |
| expires_at | TIMESTAMPTZ | default now() + 7 days |
| created_at | TIMESTAMPTZ | default now() |

Comportamiento: couple → single-use, family/friends → multi-use.

#### `household_activities`
| Columna | Tipo | Restricciones |
|---------|------|---------------|
| id | UUID | PK |
| household_id | UUID | FK → households(id) |
| user_id | UUID | FK → users(id) |
| event_type | TEXT | ej: 'task_completed', 'expense_added' |
| title | TEXT | |
| description | TEXT | nullable |
| metadata | JSONB | nullable |
| is_shared | BOOLEAN | default true |
| created_at | TIMESTAMPTZ | default now() |

---

### EXPENSES / FINANCE

#### `expenses`
| Columna | Tipo | Restricciones |
|---------|------|---------------|
| id | UUID | PK |
| household_id | UUID | FK → households(id) NOT NULL |
| created_by_id | UUID | FK → users(id) |
| title | TEXT | NOT NULL, CHECK btrim <> '' |
| description | TEXT | nullable |
| category | TEXT | nullable |
| amount | NUMERIC | NOT NULL, CHECK > 0 |
| paid_by | UUID | FK → users(id) NOT NULL |
| paid_at | TIMESTAMPTZ | NOT NULL |
| split_type | TEXT | NOT NULL, default 'equal', CHECK IN ('equal','fixed','gift','personal') |
| is_shared | BOOLEAN | NOT NULL, default true |
| type | transaction_type | NOT NULL, default 'expense' ('expense'/'income'/'settlement') |
| receipt_path | TEXT | nullable |
| planned_expense_id | UUID | FK → planned_expenses(id) nullable |
| created_at | TIMESTAMPTZ | default now() |
| updated_at | TIMESTAMPTZ | default now() |

Trigger: enforce_expense_privacy_consistency() auto-setea is_shared desde split_type.

#### `expense_splits`
| Columna | Tipo | Restricciones |
|---------|------|---------------|
| id | UUID | PK |
| expense_id | UUID | FK → expenses(id) |
| user_id | UUID | FK → users(id) |
| amount | NUMERIC | NOT NULL |

#### `expense_templates`
| Columna | Tipo | Restricciones |
|---------|------|---------------|
| id | UUID | PK |
| household_id | UUID | FK → households(id) ON DELETE CASCADE |
| title | TEXT | NOT NULL |
| default_amount | NUMERIC | NOT NULL |
| category | TEXT | nullable |
| frequency | TEXT | default 'monthly' |
| day_of_month | INTEGER | NOT NULL, CHECK 1..31 |
| split_type | TEXT | NOT NULL |
| payer_default | UUID | FK → users(id) ON DELETE CASCADE |
| is_active | BOOLEAN | default true |
| next_execution_date | TIMESTAMPTZ | nullable |
| created_at | TIMESTAMPTZ | default now() |
| updated_at | TIMESTAMPTZ | default now() |

#### `planned_expenses`
| Columna | Tipo | Restricciones |
|---------|------|---------------|
| id | UUID | PK |
| household_id | UUID | FK → households(id) ON DELETE CASCADE |
| template_id | UUID | FK → expense_templates(id) nullable ON DELETE SET NULL |
| title | TEXT | NOT NULL |
| amount | NUMERIC | NOT NULL |
| category | TEXT | nullable |
| split_type | TEXT | NOT NULL |
| payer_default | UUID | FK → users(id) ON DELETE CASCADE |
| due_date | DATE | NOT NULL |
| status | TEXT | NOT NULL, default 'pending', CHECK IN ('pending','paid','skipped') |
| expense_id | UUID | FK → expenses(id) nullable ON DELETE SET NULL |
| created_at | TIMESTAMPTZ | default now() |

Unique: (template_id, due_date)

---

### TASKS

#### `tasks`
| Columna | Tipo | Restricciones |
|---------|------|---------------|
| id | UUID | PK |
| title | TEXT | NOT NULL |
| description | TEXT | nullable |
| category | TEXT | nullable, FK-like → categories(id) |
| assigned_to | UUID | FK → users(id) nullable |
| status | TEXT | 'active'/'assigned'/'pending_approval'/'pending_verification'/'verified'/'objected' |
| xp_reward | INTEGER | default 0 |
| coin_reward | INTEGER | default 0 |
| recurrence_type | TEXT | nullable, 'daily'/'weekly'/'monthly'/'custom' |
| recurrence_interval | INTEGER | default 1 |
| recurrence_weekdays | INTEGER[] | default '{}' |
| recurrence_month_days | INTEGER[] | default '{}' |
| due_at | TIMESTAMPTZ | nullable |
| household_id | UUID | FK → households(id) NOT NULL |
| priority | TEXT | 'low'/'medium'/'high'/'urgent' |
| type | TEXT | 'one_time'/'recurring' |
| difficulty | TEXT | 'easy'/'medium'/'hard' |
| created_by_id | UUID | FK → users(id) nullable |
| completed_at | TIMESTAMPTZ | nullable |
| completed_by | UUID | nullable |
| verified_by | UUID | nullable |
| verified_at | TIMESTAMPTZ | nullable |
| created_at | TIMESTAMPTZ | default now() |
| updated_at | TIMESTAMPTZ | default now() |

#### `categories`
| Columna | Tipo | Restricciones |
|---------|------|---------------|
| id | TEXT | PK, ej: 'limpieza', 'cocina' |
| name | TEXT | NOT NULL |
| icon | TEXT | ej: '🧹' |
| color | TEXT | ej: '#6366F1' |
| sort_order | INTEGER | default 0 |

13 entradas seedeadas. Orden: limpieza(1), cocina(2), baño(3), sala(4), ropa(5), residuos(6), compras(7), dormitorio(8), mascotas(9), exterior(10), mantenimiento(11), niños(12), administracion(13).

#### `task_templates`
| Columna | Tipo | Restricciones |
|---------|------|---------------|
| id | UUID | PK |
| category_id | TEXT | FK → categories(id) |
| title | TEXT | NOT NULL |
| difficulty | TEXT | 'small'/'normal'/'big'/'heavy' |
| xp_reward | INTEGER | |
| coin_reward | INTEGER | |
| sort_order | INTEGER | |

---

### SHOPPING

#### `shopping_items`
| Columna | Tipo | Restricciones |
|---------|------|---------------|
| id | UUID | PK |
| household_id | UUID | FK → households(id) |
| name | TEXT | NOT NULL |
| quantity | TEXT | nullable |
| unit | TEXT | nullable |
| category | TEXT | default 'general' |
| emoji | TEXT | default '🛒' |
| note | TEXT | nullable |
| added_by | UUID | FK → users(id) nullable |
| completed | BOOLEAN | default false |
| completed_by | UUID | nullable |
| completed_at | TIMESTAMPTZ | nullable |
| should_sync | BOOLEAN | default true |
| created_at | TIMESTAMPTZ | default now() |

#### `shopping_catalog_requests`
| Columna | Tipo | Restricciones |
|---------|------|---------------|
| id | UUID | PK |
| name | TEXT | NOT NULL, UNIQUE |
| emoji | TEXT | NOT NULL, default '🛒' |
| total_count | INTEGER | NOT NULL, default 1 |
| first_seen_at | TIMESTAMPTZ | NOT NULL, default now() |
| last_seen_at | TIMESTAMPTZ | NOT NULL, default now() |

---

### REWARDS

#### `rewards`
| Columna | Tipo | Restricciones |
|---------|------|---------------|
| id | UUID | PK |
| household_id | UUID | FK → households(id) |
| title | TEXT | NOT NULL |
| description | TEXT | nullable |
| cost | INTEGER | NOT NULL (en coins) |
| icon | TEXT | NOT NULL, default '🎁' |
| category | TEXT | nullable |
| created_by | UUID | FK → users(id) nullable |
| is_approved | BOOLEAN | default false |
| is_active | BOOLEAN | default true |
| target_type | TEXT | NOT NULL, default 'all', CHECK IN ('adult','child','all') |
| created_at | TIMESTAMPTZ | default now() |

#### `reward_redemptions`
| Columna | Tipo | Restricciones |
|---------|------|---------------|
| id | UUID | PK |
| user_id | UUID | FK → users(id) |
| household_id | UUID | FK → households(id) |
| reward_id | UUID | FK → rewards(id) |

---

### SAVINGS

#### `savings_goals`
| Columna | Tipo | Restricciones |
|---------|------|---------------|
| id | UUID | PK |
| household_id | UUID | FK → households(id) ON DELETE CASCADE |
| title | TEXT | NOT NULL |
| target_amount | DECIMAL(12,2) | NOT NULL |
| current_amount | DECIMAL(12,2) | default 0.00 |
| color | TEXT | default '#FF7E67' |
| icon | TEXT | default '💰' |
| created_at | TIMESTAMPTZ | default now() |
| updated_at | TIMESTAMPTZ | default now() |

#### `savings_contributions`
| Columna | Tipo | Restricciones |
|---------|------|---------------|
| id | UUID | PK |
| goal_id | UUID | FK → savings_goals(id) ON DELETE CASCADE |
| user_id | UUID | FK → users(id) ON DELETE CASCADE |
| amount | DECIMAL(12,2) | NOT NULL |
| note | TEXT | nullable |
| created_at | TIMESTAMPTZ | default now() |

Trigger: tr_update_goal_amount — actualiza savings_goals.current_amount after INSERT/DELETE.

---

### GAMIFICATION / STATS

#### `ledger_entries`
| Columna | Tipo | Restricciones |
|---------|------|---------------|
| id | UUID | PK |
| household_id | UUID | FK → households(id) |
| user_id | UUID | FK → users(id) |
| type | TEXT | ej: 'xp_earned', 'coins_earned', 'coins_spent' |
| amount | INTEGER | |
| currency | TEXT | 'XP' o 'COIN' |
| reference_id | TEXT | FK-like a actividad/gasto |
| reference_type | TEXT | ej: 'activity' |
| description | TEXT | |
| source | TEXT | ej: 'rpc', 'qa_admin' |
| created_by | TEXT | |
| created_at | TIMESTAMPTZ | default now() |

Unique: (user_id, type, reference_id) — idempotente via ON CONFLICT DO NOTHING.

#### `weekly_winners`
| Columna | Tipo | Restricciones |
|---------|------|---------------|
| id | UUID | PK |
| household_id | UUID | FK → households(id) |
| user_id | UUID | FK → users(id) |
| week_start_date | DATE | |

#### `weekly_duel_history`
| Columna | Tipo | Restricciones |
|---------|------|---------------|
| id | UUID | PK |
| household_id | UUID | FK → households(id) |
| week_start_date | DATE | |
| winner_user_id | UUID | |
| winner_name | TEXT | |
| loser_user_id | UUID | |
| loser_name | TEXT | |
| winner_xp | INTEGER | |
| loser_xp | INTEGER | |
| created_at | TIMESTAMPTZ | default now() |

---

### NOTIFICATIONS

#### `notifications`
| Columna | Tipo | Restricciones |
|---------|------|---------------|
| id | UUID | PK |
| household_id | UUID | FK → households(id) |
| user_id | UUID | FK → users(id) — destinatario |
| created_by_id | UUID | FK → users(id) — actor |
| title | TEXT | |
| body | TEXT | |
| type | TEXT | ej: 'expense_added', 'system', 'generic' |
| related_entity_type | TEXT | nullable, ej: 'expense' |
| related_entity_id | UUID | nullable |
| is_read | BOOLEAN | default false |
| created_at | TIMESTAMPTZ | default now() |

---

### SOCIAL

#### `love_notes`
| Columna | Tipo | Restricciones |
|---------|------|---------------|
| id | UUID | PK |
| from_user_id | UUID | FK → users(id) |
| to_user_id | UUID | FK → users(id) |
| content | TEXT | NOT NULL |
| is_read | BOOLEAN | default false |
| created_at | TIMESTAMPTZ | default now() |

---

### PAYMENTS

#### `mercadopago_connections`
| Columna | Tipo | Restricciones |
|---------|------|---------------|
| user_id | UUID | PK, FK → users(id) ON DELETE CASCADE |
| mp_user_id | TEXT | nullable |
| access_token | TEXT | NOT NULL |
| refresh_token | TEXT | nullable |
| public_key | TEXT | nullable |
| live_mode | BOOLEAN | nullable |
| token_type | TEXT | nullable |
| expires_at | TIMESTAMPTZ | nullable |
| created_at | TIMESTAMPTZ | default now() |
| updated_at | TIMESTAMPTZ | default now() |

---

### SYSTEM / LOGS

#### `audit_logs`
| Columna | Tipo | Restricciones |
|---------|------|---------------|
| id | UUID | PK |
| request_id | TEXT | idempotency key |
| user_id | UUID | FK → users(id) |
| household_id | UUID | FK → households(id) |
| action | TEXT | ej: 'complete_task' |
| entity_type | TEXT | ej: 'task' |
| entity_id | UUID | |
| new_value | JSONB | nullable |
| reason | TEXT | nullable |
| source | TEXT | ej: 'rpc', 'qa_admin' |
| created_at | TIMESTAMPTZ | default now() |

#### `application_logs`
| Columna | Tipo |
|---------|------|
| id | UUID PK |
| user_id | UUID nullable |
| level | TEXT |
| message | TEXT |
| stack_trace | TEXT nullable |
| context | JSONB nullable |
| device_info | JSONB nullable |
| created_at | TIMESTAMPTZ |

#### `error_issues`
Agrupacion operativa de `application_logs` para que Codex/admin puedan priorizar, marcar estado y cerrar errores sin leer cientos de filas crudas.

| Columna | Tipo | Restricciones |
|---------|------|---------------|
| id | UUID | PK |
| fingerprint | TEXT | UNIQUE |
| title | TEXT | |
| level | TEXT | `critical`, `error`, `warning`, `info` |
| status | TEXT | `open`, `investigating`, `fixed`, `ignored` |
| first_seen | TIMESTAMPTZ | |
| last_seen | TIMESTAMPTZ | |
| occurrences | INTEGER | default 0 |
| affected_users | INTEGER | default 0 |
| sample_log_id | UUID | nullable |
| sample_message | TEXT | nullable |
| sample_stack_trace_head | TEXT | nullable |
| app_frame | TEXT | nullable |
| screens | TEXT[] | default `{}` |
| environments | TEXT[] | default `{}` |
| first_seen_build | TEXT | nullable |
| last_seen_build | TEXT | nullable |
| fixed_in_build | TEXT | nullable |
| fixed_at | TIMESTAMPTZ | nullable |
| notes | TEXT | nullable |
| created_at | TIMESTAMPTZ | default now() |
| updated_at | TIMESTAMPTZ | default now() |

#### `system_events`
| Columna | Tipo |
|---------|------|
| id | UUID PK |
| user_id | UUID nullable |
| event_type | TEXT |
| entity_type | TEXT |
| entity_id | UUID nullable |
| household_id | UUID nullable |
| operation | TEXT |
| result | TEXT |
| source | TEXT |
| metadata | JSONB nullable |
| created_at | TIMESTAMPTZ |

#### `idempotency_keys`
| Columna | Tipo | Restricciones |
|---------|------|---------------|
| id | UUID | PK |
| user_id | UUID | FK → users(id) |
| key | TEXT | UNIQUE |
| created_at | TIMESTAMPTZ | default now() |

---

## Relaciones clave

```
users.id
  ← household_members.user_id
  ← expenses.created_by_id / paid_by
  ← expense_templates.payer_default
  ← expense_splits.user_id
  ← tasks.assigned_to / created_by_id
  ← shopping_items.added_by
  ← rewards.created_by
  ← ledger_entries.user_id
  ← notifications.user_id / created_by_id
  ← love_notes.from_user_id / to_user_id

households.id
  ← household_members.household_id
  ← household_invitations.household_id
  ← expenses.household_id
  ← tasks.household_id
  ← shopping_items.household_id
  ← rewards.household_id
  ← notifications.household_id
  ← ledger_entries.household_id

expenses.id ← expense_splits.expense_id, planned_expenses.expense_id
categories.id ← tasks.category, task_templates.category_id
savings_goals.id ← savings_contributions.goal_id
expense_templates.id ← planned_expenses.template_id
```

---

## RPC Functions

### Identity & Auth
| Funcion | Retorna | Proposito |
|---------|---------|-----------|
| current_app_user_id() | UUID | Resuelve JWT sub/firebase_uid → users.id |
| ensure_user_profile(p_firebase_uid, p_email, p_full_name, p_avatar_url) | UUID | Crea o linkea perfil de usuario |
| update_own_profile(p_full_name, p_avatar_url) | BOOLEAN | Actualiza perfil (security definer) |
| current_auth_subject() | TEXT | JWT sub o auth.uid() |
| is_current_app_user(user_id) | BOOLEAN | Verifica si user_id coincide |
| is_current_household_member(target_household_id) | BOOLEAN | Verifica membresia |
| is_supabase_or_firebase_project_jwt() | BOOLEAN | Verifica origen del JWT |

### Household
| Funcion | Retorna | Proposito |
|---------|---------|-----------|
| ensure_household_for_user(p_household_type) | UUID | Crea hogar si no existe |
| generate_household_invitation(p_household_id) | TEXT | Genera codigo de invitacion |
| join_household_by_code(p_code) | JSONB | Une a hogar via codigo |
| complete_member_onboarding(p_member_type, p_display_role) | JSONB | Completa onboarding de miembro |
| get_available_family_roles(p_household_id) | JSONB | Roles disponibles para familia |
| reset_user_account() | JSONB | Reset completo de cuenta |

### Finance
| Funcion | Retorna | Proposito |
|---------|---------|-----------|
| save_expense_v4(...) | UUID | Crea/actualiza gasto + splits |
| get_combined_feed(p_household_id, p_limit, p_offset) | TABLE | Feed unificado de gastos |
| get_filtered_expenses(...) | TABLE | Gastos filtrados |
| get_expense_balance(p_household_id) | TABLE | Balance por miembro |
| get_expense_stats_by_category(p_user_id) | JSONB | Stats por categoria |
| get_personal_finance_summary(p_user_id) | JSONB | Resumen financiero personal |
| pay_planned_expense(...) | UUID | Paga gasto planificado |
| process_recurring_expenses() | VOID | Genera gastos planificados |

### Tasks
| Funcion | Retorna | Proposito |
|---------|---------|-----------|
| create_task(...) | UUID | Crea tarea |
| complete_task_transaction(...) | JSONB | Completa + XP/coins + reprograma |
| complete_tasks_batch(...) | JSONB | Completar batch |
| verify_task_transaction(...) | JSONB | Verifica tarea completada |
| reject_task_transaction(...) | JSONB | Rechaza tarea |
| get_task_stats_by_category(p_user_id) | TABLE | Stats por categoria |

### Stats / Gamification
| Funcion | Retorna | Proposito |
|---------|---------|-----------|
| get_weekly_ranking(p_household_id) | JSONB | Ranking semanal por miembro |
| award_weekly_winner(p_household_id) | JSONB | Premia ganador semanal |
| get_xp_history(p_user_id) | TABLE | Historial de XP |
| get_coin_history(p_user_id) | TABLE | Historial de coins |
| get_member_activity_stats(p_user_id) | TABLE | Stats de actividad |

---

## Notas de diseno

- **Auth**: `auth.uid()` NO se usa directamente en RLS — `current_app_user_id()` maneja el mapeo Firebase JWT → Supabase UUID
- **Enum**: `transaction_type` ('expense', 'income', 'settlement') en `expenses.type`
- **RLS**: Todas las tablas tienen RLS habilitado
- **Invitaciones**: couple → max 2 miembros, codigo single-use; family/friends → sin limite, codigo multi-use
- **Triggers**: `enforce_expense_privacy_consistency` (expenses), `tr_update_goal_amount` (savings_contributions)
