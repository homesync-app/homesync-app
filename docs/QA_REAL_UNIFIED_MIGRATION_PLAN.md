# QA Real Unified Migration Plan

## Purpose

Migrate the current `admin/testing` system to a unified QA system based on:

- real QA users
- real QA households
- real membership and permissions
- real product flows
- admin tools only for control, reset, and seed operations

This plan is designed to answer one central need:

> "I need to test the app as if it were real."

The goal is not to delete the existing admin/testing system.

The goal is to preserve the useful parts and replace the fake identity/membership core with real authenticated QA users and real household records.

## Executive summary

### What we keep

- debug/admin access
- scenario list
- QA households already seeded
- reset and seed RPCs
- fast switching tooling
- internal debug-only controls

### What we stop relying on

- forced `householdId` as the main flow
- fake `viewer` identity from providers
- fake membership resolution
- QA-only RPCs for normal app usage
- "impersonation" that does not use real auth

### What becomes the new source of truth

- real auth session
- real `currentUserId`
- real `household_members`
- real RLS / real permissions
- real queries / real mutations

## Diagnosis of the current system

The current admin/testing flow is useful but structurally limited.

It works well for:

- quick scenario selection
- seeded demo data
- layout and UX iteration
- debug-only shortcuts

It is weak for:

- member permissions
- editing profiles and roles
- validating who can see what
- validating task completion exactly like production
- validating avatar/profile updates
- validating switching between family members as real users

### Current architecture problem

Today the system simulates identity from providers:

- `currentUserIdProvider` can be overridden by admin state
- `householdIdProvider` can be forced by admin state
- household membership can be faked through QA helpers
- member reads can go through `qa_admin_get_household_members`

That means the app can look like one user while the session is not truly that user.

This is the root reason why testing loses credibility.

## Target architecture

The future system should have 2 layers.

## Layer 1. Real QA data plane

This is the truth layer.

It must use:

- real user accounts in auth
- real rows in `users`
- real rows in `households`
- real rows in `household_members`
- real tasks / rewards / expenses / shopping items
- normal providers and normal app screens

### Example

Family QA:

- `Padre QA`
- `Madre QA`
- `Hija QA`
- `Hijo QA`

All four users are real accounts.
All four belong to a real `Familia QA` household.

When the app runs as `Hija QA`, it must behave exactly as a real child member would behave in production.

## Layer 2. Admin control plane

This is the convenience layer.

It must help with:

- selecting a scenario
- logging in fast as a QA user
- resetting a scenario
- reseeding data
- opening onboarding preview
- optionally switching account quickly in debug

It must **not** become the main source of truth for:

- who the current user is
- what household they belong to
- what permissions they have

## Core product rule

Admin can manage QA scenarios.
Admin should not fake production identity for the main flows.

## Migration principles

### 1. Do not start from zero

The current system has useful infrastructure.

We should reuse:

- `AdminState`
- scenario metadata
- reset RPCs
- seed RPCs
- internal debug UI shell

### 2. Identity must become real

The app should stop depending on admin overrides for daily scenario execution.

The selected QA user should be a real authenticated session.

### 3. Scenarios remain curated

We still want controlled test environments.

That means:

- dedicated QA households
- deterministic QA data
- resettable state
- known roles and permissions

### 4. Real-user testing must be fast

If switching between family members takes too long, the system will not be used.

So the new system must optimize speed while preserving reality.

## Recommended target UX

## QA Control Center

Debug-only screen.

Sections:

### A. Scenario selector

Shows:

- `Familia QA`
- `Pareja QA`
- `Convivencia QA`
- future scenarios

Each scenario displays:

- household name
- mode
- last reset time
- members count
- available test accounts

### B. Enter as user

For each scenario, show explicit real-user entry buttons:

- `Entrar como Padre QA`
- `Entrar como Madre QA`
- `Entrar como Hija QA`
- `Entrar como Hijo QA`

This action must perform a real debug login or session switch to that actual QA account.

### C. Scenario tools

- `Resetear escenario`
- `Sembrar tareas`
- `Sembrar premios`
- `Sembrar compras`
- `Restaurar escenario completo`

### D. Debug helpers

- open onboarding preview
- inspect current auth user
- inspect current household
- inspect current member role

## Authentication strategy

There are 3 possible strategies.

## Option A. Real email/password QA accounts

Each QA user is a normal auth user.

### Pros

- closest to production
- easiest mental model
- validates auth and membership fully

### Cons

- need credentials management
- switching between users is slower unless automated

## Option B. Admin session + secure debug account switch RPC

Admin authenticates once, then requests a debug-only backend-issued session for a selected QA user.

### Pros

- very fast switching
- still uses real QA users after switch
- good developer ergonomics

### Cons

- more complex to implement safely
- requires strong debug-only guardrails

## Option C. Magic-link or custom token helper for QA users

Debug tool obtains a login token for the selected QA account.

### Pros

- smoother than manual login
- still real auth-backed users

### Cons

- extra auth complexity
- can become brittle depending on current auth architecture

## Recommended choice

Start with **Option A** and evolve to **Option B** if needed.

Reason:

- Option A is simpler
- safer
- enough to validate real family flows
- lets us ship the architecture migration in steps

Once the real-QA model works, we can add a faster debug switcher.

## Data model requirements

The unified system needs explicit QA entities.

## Users

Create real QA users for each scenario.

Recommended naming:

- `qa.family.father@...`
- `qa.family.mother@...`
- `qa.family.daughter@...`
- `qa.family.son@...`
- `qa.couple.a@...`
- `qa.couple.b@...`
- `qa.roommates.1@...`
- `qa.roommates.2@...`

Each user should have:

- full name
- avatar
- role label seed
- optional metadata marking them as QA

## Households

Create real households:

- `Familia QA`
- `Pareja QA`
- `Convivencia QA`

Each household should use the real `household_type`.

## Membership

Use real `household_members` rows.

For family:

- adults
- children
- admin/non-admin permissions
- display roles

## Optional QA metadata

Add one of these:

- a `qa_scenarios` table
- or QA tags in existing tables

Recommended fields:

- `scenario_key`
- `is_seeded`
- `seed_version`
- `last_reset_at`

This helps reset and upgrade test data safely.

## What to keep from the current admin system

These parts are worth preserving:

### 1. Admin state shell

Keep:

- developer mode
- admin login state
- scenario selection UI
- onboarding preview toggle

Do not keep it as the identity authority.

### 2. Reset and seed RPCs

Keep and expand:

- reset household scenario
- add/remove dummy data where useful
- reseed tasks/rewards/shopping

These are still valuable in the new system.

### 3. Scenario definitions

Keep scenario catalog and enrich it with:

- real auth users
- emails / labels
- household ids
- member ids if needed

## What must change

## 1. Stop using admin override as the main `currentUserId`

Current pattern:

- admin picks scenario
- provider pretends current user is someone else

Target pattern:

- admin picks scenario
- app logs in as a real QA user
- `currentUserIdProvider` resolves from real auth

### Action

Refactor [core_providers.dart](/Users/Blas_/Documents/Aplicacion%20de%20Pareja/flutter_client/lib/core/providers/core_providers.dart):

- keep admin mode
- remove admin identity override from the main happy path
- make debug overrides opt-in only for diagnostic tools, not production-like testing

## 2. Stop forcing `householdId` for main scenario execution

Current pattern:

- selected scenario can directly drive household resolution

Target pattern:

- household comes from the logged-in QA user's real membership

### Action

Refactor [core_providers.dart](/Users/Blas_/Documents/Aplicacion%20de%20Pareja/flutter_client/lib/core/providers/core_providers.dart):

- `householdIdProvider` should resolve through real membership in normal QA usage
- admin-forced household should only exist for narrow debug diagnostics if still needed

## 3. Stop using QA RPC fetches for ordinary screen reads

Current pattern:

- members in QA can come from `qa_admin_get_household_members`
- tasks in QA can come from QA RPCs

Target pattern:

- tasks, members, rewards, expenses, shopping all read through the same production paths

### Action

Refactor repositories such as:

- [supabase_household_repository.dart](/Users/Blas_/Documents/Aplicacion%20de%20Pareja/flutter_client/lib/features/household/data/repositories/supabase_household_repository.dart)
- [supabase_task_repository.dart](/Users/Blas_/Documents/Aplicacion%20de%20Pareja/flutter_client/lib/features/tasks/data/repositories/supabase_task_repository.dart)

Rule:

- production-like read path first
- QA RPC only for reset/seed/control operations

## 4. Replace "impersonation" with "real login as QA user"

Current pattern:

- `impersonate(userId)` changes provider identity

Target pattern:

- `enterAsQaUser(user)` establishes a real session for that QA account

### Action

Create a debug auth helper service:

- `QaSessionService`

Responsibilities:

- login as QA user
- logout QA user
- maybe cache QA credentials securely in debug only
- expose current QA session status

## Architecture proposal

## New service: `QaScenarioService`

Purpose:

- return available QA scenarios
- return members of each scenario
- expose reset and seed actions

This service should not fake auth.

It should only manage scenario metadata and admin operations.

## New service: `QaSessionService`

Purpose:

- log into a QA account
- switch QA user
- logout
- report current active QA actor

## New provider group

Suggested providers:

- `qaScenariosProvider`
- `qaScenarioControllerProvider`
- `qaSessionProvider`
- `qaIsRealSessionProvider`

These should live alongside current debug providers, not replace all app providers immediately.

## Suggested data flow

1. Open debug control center
2. Choose `Familia QA`
3. Press `Entrar como Hija QA`
4. App performs real QA login
5. `currentUserIdProvider` resolves actual QA user
6. `householdIdProvider` resolves actual membership
7. all family flows now use production-like logic
8. optional reset/seed actions still remain available from admin tools

## Security and safety rules

This part matters a lot.

## Rule 1. Debug-only gating

Any fast-switch or QA login helper must be available only when:

- debug build
- internal environment
- explicit admin permission

Never expose QA-switch tooling in production builds.

## Rule 2. QA data isolation

QA users and QA households must be clearly marked and isolated.

They should never mix with real customer households.

## Rule 3. No invisible privilege leaks

Once logged in as `Hija QA`, the app should have child permissions only.

Admin tools may still exist in a separate debug surface, but the main app flow should respect the selected QA user's actual permissions.

## Rule 4. Reset tools should be scenario-scoped

Resetting a QA family should only affect that scenario's QA data.

## Recommended rollout phases

## Phase 0. Audit and classify current admin/testing code

Goal:

- separate what is useful from what must be retired

Tasks:

- list every provider/repository path that branches on admin mode
- mark each branch as:
  - keep
  - migrate
  - delete later
- identify all QA RPCs
- identify all screens that depend on fake viewer logic

Deliverable:

- migration matrix

## Phase 1. Create real QA scenario data

Goal:

- create trustworthy QA families, couples, and roommates

Tasks:

- create QA auth users
- create QA households
- create real memberships
- seed avatars, display roles, member types
- seed representative tasks, rewards, expenses, shopping items

Deliverable:

- reproducible seed script or migration-backed seed workflow

## Phase 2. Build real QA login flow

Goal:

- enter the app as a real QA user quickly

Tasks:

- create `QaSessionService`
- add debug login UI for QA users
- support logout / switch account
- expose current QA actor in debug UI

Deliverable:

- debug-only "Enter as QA user" flow

Acceptance:

- selecting `Hija QA` results in a real authenticated session for that account
- `currentUserIdProvider` equals the actual QA user id

## Phase 3. Move family testing to real data paths

Goal:

- make family testing trustworthy

Tasks:

- disable QA override for family main flows
- resolve members from real `household_members`
- resolve tasks from real task queries / RPC
- resolve rewards from real rewards queries
- resolve shopping from real shopping queries

Deliverable:

- family scenario fully testable through real auth + real membership

Acceptance:

- role editing, avatar behavior, task completion, visibility rules, and rewards all behave consistently with real users

## Phase 4. Re-scope admin/testing

Goal:

- convert admin/testing into an operations layer

Tasks:

- keep scenario list
- keep reset buttons
- keep seed buttons
- remove fake identity assumptions from normal test execution

Deliverable:

- admin becomes "QA control center", not "fake viewer engine"

## Phase 5. Fast user switching

Goal:

- improve developer speed after correctness is achieved

Tasks:

- optional secure quick-switch between QA users
- optionally store debug-only QA credentials locally
- optionally implement controlled backend-assisted session switch

Deliverable:

- fast but real switching

## Detailed implementation tasks

## Backend

### Tables and data

- create or formalize QA scenario metadata
- ensure QA users are seeded deterministically
- ensure QA households are seeded deterministically
- ensure member roles/types/admin flags are seeded

### RPCs to keep

- `qa_admin_reset_scenario`
- scenario-specific seeding RPCs if useful

### RPCs to de-emphasize

- QA RPCs that replace normal reads for members/tasks

Those should stop being the primary path for app screens.

## Auth

### Debug login helper

Implement a debug-only login helper with:

- scenario user list
- credential mapping or secure lookup
- login result handling
- switch user support

### Important

This must create a real app session.

It should not just set a provider override.

## Providers

### Refactor strategy

Do not rewrite all providers at once.

Refactor in this order:

1. identity providers
2. household resolution
3. member providers
4. task providers
5. rewards
6. finance
7. shopping

### Rule

Every provider should have a single question:

> "Can this provider resolve through real auth + real household membership?"

If yes, make that the default.

## UI

### QA Control Center

Add explicit visual distinction:

- debug badge
- current QA scenario
- current QA actor
- reset controls

### Main app

No special visual behavior should be required for the app to behave correctly as a QA family member.

If the app only works because admin mode is active, that is a bug.

## Testing strategy

## What this new system should let us validate confidently

- family child vs adult visibility
- family admin vs non-admin permissions
- rewards store targeting
- role editing
- avatar editing
- task completion
- approval flows
- finance visibility
- shopping usage
- onboarding for fresh QA users if needed

## What should no longer be ambiguous

- "Is this a bug in family mode or a bug in admin/testing?"

That ambiguity is exactly what this migration is meant to remove.

## Acceptance criteria for the migration

The migration is successful when all of the following are true:

- QA family members are real auth users
- entering as a QA member creates a real session
- family screens use real membership and real data paths
- completing a task as `Hija QA` behaves like a real child member flow
- editing a member role/avatar behaves through real permissions and real persistence
- admin tools remain useful for reset/seed
- fake viewer overrides are no longer required for normal QA testing

## What to do with the current admin system right now

## Keep now

- admin login toggle
- scenario picker shell
- reset actions
- seeding actions
- onboarding preview

## Freeze or minimize

- fake impersonation
- forced household identity
- QA-only read paths for main screens

## Remove later

- any branches that only exist to make fake viewer mode work

## Recommended first implementation block

Do this first:

### Block 1. Real QA family users + debug login

Scope:

- seed real QA family users
- seed one real family household
- build debug entry UI
- login as a selected QA user
- verify `currentUserIdProvider` and `householdIdProvider` resolve naturally

Why this first:

- highest confidence gain
- lowest ambiguity
- immediately tells us whether `family` bugs are real product bugs

## Recommended second implementation block

### Block 2. Family main flows on real data

Scope:

- members
- tasks
- rewards
- shopping

Why:

- these are the highest-value day-to-day family flows

## Recommended third implementation block

### Block 3. Admin control center refactor

Scope:

- reset
- reseed
- switch QA account
- current actor indicator

## Risks

### Risk 1. Mixed-mode limbo

If half the app still uses fake overrides and half uses real QA users, debugging gets worse.

Mitigation:

- migrate by vertical
- explicitly mark which flows are already on real QA

### Risk 2. QA credentials sprawl

If QA accounts are managed ad hoc, the system becomes fragile.

Mitigation:

- centralize credential strategy
- document accounts and reset flow

### Risk 3. Admin leakage into production

Mitigation:

- strict debug gating
- feature flags
- assert against production environment

## Definition of done

This migration is done when:

- we can enter as a real QA family member in debug
- we can test family flows without relying on fake viewer overrides
- the admin panel is still useful for reset/seed
- bugs found in QA are trustworthy signals for real product behavior

## Final recommendation

Do not throw away the current admin/testing system.

Reframe it.

It should become:

- a control center
- a reset/seed tool
- a fast entry point into real QA accounts

It should stop being:

- the identity engine
- the fake household engine
- the main way we pretend to be real users

That shift gives HomeSync a QA environment that is:

- fast
- credible
- production-like
- maintainable
