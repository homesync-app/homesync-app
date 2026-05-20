# HomeSync performance audit

## Goal

Measure the flows users describe as slow with repeatable numbers before
optimizing. Run these checks on a physical Android device in profile mode,
preferably on a mid-range or low-end phone.

## Run

```bash
cd flutter_client
flutter run --profile --dart-define=ENABLE_PERF_LOGS=true
```

Filter logs for:

```text
[Perf]
```

## First measurements

Capture three runs for each flow and keep the median:

- Cold start to usable home.
- Auth bootstrap after reopening the app.
- Home critical preload.
- Initial task list.
- Household members.
- Expense balances.
- Combined finance feed.
- Recent activity stream mapping.

## Useful log names

- `startup.firebase_initialize`
- `startup.supabase_initialize`
- `startup.auth_bootstrap_provider`
- `startup.auth_state_provider`
- `startup.warm_critical_providers`
- `startup.main_screen.first_frame`
- `startup.home_screen.first_content_frame`
- `startup.blocking_provider.householdIdProvider`
- `startup.blocking_provider.userProfileProvider`
- `startup.blocking_provider.householdMembersProvider`
- `startup.blocking_provider.expenseBalancesProvider`
- `startup.blocking_provider.tasksProvider`
- `startup.precache_images`
- `provider.household_members`
- `provider.household`
- `provider.expense_balances`
- `provider.expense_controller.initial_expenses`
- `provider.combined_feed`
- `provider.tasks.initial_page`
- `repository.recent_activity.query`
- `repository.recent_activity.stream_map`

## Initial thresholds

- `startup.home_screen.first_content_frame` app elapsed above 2500 ms on a
  warm session, or above 4000 ms on cold start, is likely noticeable.
- Startup blocking provider above 700 ms: investigate.
- Warm critical providers above 1800 ms: likely visible startup cost.
- Any repository/provider query above 900 ms: inspect backend query/RPC and
  frontend invalidation pattern.
- Repeated identical `[Perf]` entries during a single screen view: inspect
  provider invalidation or widget rebuild/watch scope.

## Next optimization candidates

- Move non-essential startup work behind first paint if
  `startup.warm_critical_providers` dominates.
- Avoid blocking startup on avatar precache if `startup.precache_images` is
  consistently slow.
- Collapse repeated Supabase calls or add DB indexes if a provider query is
  consistently slow.
- Check Riverpod invalidations when providers rerun after simple UI actions.
