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

## Measured baseline — 2026-06-11 (Galaxy S25 Ultra, profile, cold start)

Before/after of the startup optimization pass (see commits of that date):

| Metric | Before | After | What changed |
|---|---|---|---|
| `startup.google_sign_in_initialize` | serial, up to 5 s timeout | 4 ms, off critical path | warm-up runs in parallel, awaited just before `runApp` |
| `startup.auth_bootstrap_provider` | 835 ms | ~350 ms | network variance; unchanged code |
| `startup.precache_images` | 751 ms | ~210 ms | `CachedNetworkImageProvider` (disk cache) instead of `NetworkImage` |
| `startup.warm_critical_providers` | 1165 ms | ~490 ms | precache fix above |
| Minimum splash (800 ms) | added serially | runs in parallel | `_completeStartupGate` awaits it alongside the bootstrap chain |
| `startup.home_screen.first_content_frame` | 3266 ms | **1791 ms** | all of the above + lazy `FadeIndexedStack` tabs |

Notes for future runs:

- `flutter run` attaches its log reader late and misses early `[Perf]` lines.
  To capture a real cold start: `adb logcat -c`, `adb shell am force-stop
  com.blas.homesync`, launch via `adb shell monkey -p com.blas.homesync 1`,
  then read `adb logcat -d | grep "\[Perf\]"`.
- `dumpsys gfxinfo` does NOT see Flutter frames (single Skia/Impeller
  surface). For scroll jank, watch logcat for `Choreographer: Skipped N
  frames` from the app pid, or use DevTools timeline.
- The bottom-nav `BackdropFilter` (sigma 18) showed zero jank on the S25
  Ultra. Re-test on a mid-range device before touching it.

## Next optimization candidates

- Move non-essential startup work behind first paint if
  `startup.warm_critical_providers` dominates.
- Collapse repeated Supabase calls or add DB indexes if a provider query is
  consistently slow.
- Check Riverpod invalidations when providers rerun after simple UI actions.
- Bundle only the `idle` motion per premium mascot and download event motions
  (victory/versus/celebrate) on demand if APK size becomes a priority
  (~6-7 MB; download infra already exists in `premium_avatar_motion_cache`).
