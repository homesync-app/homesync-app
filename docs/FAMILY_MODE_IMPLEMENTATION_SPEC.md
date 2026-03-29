# Family Mode Implementation Spec

## Purpose

Define and implement `family mode` as a full product vertical inside HomeSync, with its own rules, visibility, incentives, permissions, and UX.

This spec is intentionally written to be:

- usable by humans as product and architecture guidance
- usable by another AI as an implementation guide
- split into safe delivery chunks
- explicit about what must not be broken

## Core product definition

`family` is not just "shared household with more people".

It is a household mode with:

- real family structure
- adult and child dynamics
- household administration
- weekly contribution visibility
- personal and shared rewards
- conditional finances

It must not feel like:

- couple mode with more avatars
- a generic multi-member dashboard
- a task app with decorative family labels

It should feel like:

- a real family coordination system
- useful every day
- motivating without being childish by default
- adaptable to who is using it

## Product principles

### 1. Coordination over romance

Family mode must avoid:

- romantic copy
- couple-first assumptions
- flows designed for two people only
- rewards language that only makes sense in couple mode

### 2. Structure matters

A family is not just a list of members.

The system must distinguish:

- member type
- visible role
- admin permission

### 3. The home must answer real questions

The family home should answer:

- what needs to happen today
- who is contributing this week
- what is missing at home
- how the household is doing overall

### 4. Rewards must be functional

Coins, ranking, and rewards should support household behavior, not just decoration.

They must help:

- motivate task completion
- make contribution visible
- connect chores to meaningful rewards
- create family-level goals

## Member model

Each family member should be represented through 3 layers.

## Layer 1. Member type

Structural role in the household.

Initial values:

- `adult`
- `child`

## Layer 2. Visible role

Human-readable role shown in UI.

Examples:

- `Madre`
- `Padre`
- `Tutor/a`
- `Abuelo/a`
- `Hijo/a`
- `Hermano/a`
- `Otro integrante`

This is presentation, not permission.

## Layer 3. Admin permission

Defines whether this person can configure or manage the household.

Values:

- `admin`
- `non_admin`

## Important rule

`admin` is not a person type.

It is a permission.

Valid examples:

- Mother = `adult + admin`
- Father = `adult + admin`
- Grandmother = `adult + non_admin`
- Child = `child + non_admin`

## Permission matrix

### Adult admin

Can:

- invite and remove members
- edit visible roles
- change household name
- change household structure
- configure rewards and family catalog
- approve family-level rewards
- access finance configuration
- manage family settings

### Adult non-admin

Can:

- complete tasks
- earn coins
- redeem personal rewards
- view ranking
- view shopping
- view family activity
- access finances if product rules allow

Cannot:

- manage members
- change household structure
- edit global catalog

### Child

Can:

- see own tasks
- earn coins
- view family ranking
- redeem allowed rewards
- view shopping list

Cannot:

- manage members
- access admin settings
- access household finances
- create or approve family rules

## Visibility rules

The experience must depend on:

- household type = `family`
- current user member type
- current user admin permission
- number of adults in household
- whether finance data actually exists
- whether rewards are enabled

## Family home

## What the home must answer

- what must be done today
- who is leading this week
- what is still missing from shopping
- whether finance coordination matters right now

## What the home should not prioritize

- decorative avatars
- large member section with no daily value
- finance widget when there is no real financial coordination

## Final recommended home structure

### 1. Household weekly summary

This should be the top block.

Content:

- total weekly points
- tasks completed this week
- current leader or top 3
- short household state

Example messages:

- `Semana muy activa`
- `Buen ritmo en casa`
- `Quedan tareas por cerrar`

Goal:

- create weekly context
- connect tasks, ranking, and rewards

### 2. Weekly household ranking

This replaces the couple-style duel concept.

Recommended naming:

- `Ranking semanal`
- `Lo mejor de esta semana`
- `Quien viene liderando`

Content:

- position by member
- points or coins earned
- completed tasks
- first place highlight
- small weekly deltas if available later

Behavior:

- if children exist, make this more playful
- if only adults exist, keep it cleaner and more practical

### 3. Tasks for today

This should show real pending work.

Preferred content:

- current pending tasks
- visible assignee
- optional grouping by person or urgency
- CTA to full tasks panel

For children:

- prioritize "your tasks today"

For adults/admins:

- show mixed household view or grouped responsibilities

### 4. Shopping

Shopping should stay in the home.

This is one of the highest-value operational widgets.

Content:

- first pending items
- pending count
- CTA to full list

### 5. Finance

Finance in family home must be conditional.

It should not always appear.

#### Show finance widget in home if any of these are true

- there are 2 or more adults in the household
- current user is `adult + admin` and shared expenses exist
- shared finances are actively used

#### Hide finance widget in home if

- there is only 1 adult
- current user is a child
- no relevant shared expenses exist

In those cases:

- finance still exists in its own tab
- it just should not occupy home real estate

### 6. Recent activity

Keep it near the bottom.

It is useful, but not primary.

### 7. Members

Members should not be a primary home section.

The current "avatars in home" idea is too decorative unless it becomes operational.

#### Recommendation

- remove it from the main home priority
- or transform it into an operational status section

If transformed, it should show:

- who is up to date
- who has pending work
- who is leading this week
- who needs attention

Not just pictures.

## Family hub

The family hub should become the admin and structure center of the household.

It should not compete with the home.

## Required hub sections

### 1. Members

Show:

- avatar
- display role
- member type
- admin badge
- status

Allow:

- edit visible role
- change adult/child type
- grant/remove admin
- remove member

### 2. Invitations

Show:

- current invite code
- share action
- regenerate action

### 3. Household structure

Show:

- adults only / adults and children
- number of adults
- number of children
- current admins

### 4. Family rewards

Show:

- family shared catalog
- approval-needed rewards
- featured family rewards

### 5. Rules and agreements

This can be v1.5, but the hub should be ready for it.

Examples:

- screen-time rules
- cleaning days
- household agreements

## Weekly ranking

## Purpose

Create a transversal loop between:

- tasks
- weekly contribution
- coins
- rewards

## Base rules

Each completed task should add:

- weekly ranking points
- personal coins

The ranking must show:

- weekly total per member
- completed tasks
- position in the household

## Tone

Do not use duel language in family mode.

Use tone that is:

- positive
- recognitional
- household-friendly
- not aggressive

Good examples:

- `Lidera esta semana`
- `Quien mas ayudo en casa`
- `Top del hogar`

## Structure adaptation

### If children exist

The ranking can be more playful.

Add:

- medals
- highlights
- small badges

### If only adults exist

The ranking should be lighter and more practical.

Add:

- summary of contribution
- top completed tasks
- simple weekly comparison

## Coins and store

## Core principle

Do not create one flat shared store for family mode.

The family economy should be split into:

- personal store
- catalog adapted by profile
- shared family section

## 1. Personal store per member

Each member sees their own coin balance and redeemable items.

### Child examples

- choose dessert
- choose dinner
- 30 extra minutes of screen time
- movie night pick
- choose weekend plan
- invite a friend

### Adult examples

- free afternoon
- choose outing
- favorite coffee
- preferred takeout
- small personal treat

For adults, the system can resemble couple rewards but without romance.

## 2. Catalog adapted by profile

The store should vary based on:

- member type
- logical age profile
- permissions

### Child sees

- effort rewards
- permissions
- small family choices

Does not see:

- finances
- adult-specific rewards

### Adult sees

- personal rewards
- shared rewards
- family rewards

### Admin can also

- create catalog items
- edit catalog items
- pause or enable rewards
- define costs
- define whether approval is required

## 3. Shared family section

There must be a family-wide rewards layer.

Examples:

- family movie night
- special outing
- order food
- ice cream afternoon
- weekend activity

These rewards may:

- be bought by one member
- require admin approval
- be unlocked collaboratively later

## Approval rules

Optional for v1.5, but should be designed now.

### Simple personal rewards

No approval required.

### Family-wide or expensive rewards

Can require:

- admin approval
- or approval by another adult

## Family finances

## Product role

Finances exist in family mode, but should not dominate the home by default.

## When finances matter most

- 2 or more adults
- real shared expenses
- recurring household spending coordination

## When finances should drop in priority

- only 1 adult
- child-centric experience
- current user is a child

## Recommended views

### Home

Only short conditional finance summary.

### Finance tab

Still available to allowed users.

### Restriction

Children should not see full finance panels.

## Family onboarding

## Recommended structure

1. Welcome
2. Personal identity
3. Household type
4. Create or join
5. Family setup
6. Invitation
7. Initial tasks

## Family setup step

Must capture:

- household name
- family structure: adults only / adults and children
- current user visible role

Optional in v1.1:

- whether the current user is admin
- whether the household prefers playful or neutral weekly competition

## UX rules

- family must not see couple-specific copy
- family must not go through romantic expense setup
- step 6 must be family-oriented, not couple-oriented

## Family settings

Settings must align with the member model.

## Must allow

- edit household name
- edit visible roles
- change member type
- promote or remove admins
- manage reward catalog
- configure household rules later

## Label rules

Avoid:

- `Amigo` as default in convivencia
- rigid fallback `Familiar`

Prefer:

- `Integrante`
- `Companero`
- `Adulto responsable`
- `Tutor/a`

## Architecture guidance

## Keep technical permission model stable first

Current technical role model:

- `owner`
- `member`

Keep using it for backend permission continuity in v1.

## Add presentation structure on top

Recommended fields or derived properties:

- `member_type`: `adult | child`
- `display_role`: normalized visible role
- `is_admin`: bool or derived mapping

## Incremental implementation strategy

### V1 without hard migration

Use:

- existing `role` for technical permission
- existing `display_role` for visible role
- lightweight metadata or heuristics for `adult/child`

### V2

Add stronger permission and member-type persistence if needed.

## Visibility summary by current user

### Current user is child

See:

- own tasks
- weekly ranking
- allowed rewards
- shopping

Do not see:

- finance home widget
- advanced settings
- household administration

### Current user is adult non-admin

See:

- tasks
- ranking
- shopping
- finances if applicable
- personal and family rewards

Do not see:

- full admin controls

### Current user is adult admin

See:

- all operational family sections
- admin controls
- invitation and household structure
- catalog and approval tools

## Engineering constraints

These are mandatory implementation rules.

### Do not break couple mode

- no copy changes in couple-only screens unless explicitly required
- no reward behavior changes in couple mode as side effects
- no changes to couple home unless explicitly required

### Prefer isolation over broad refactors

- isolate family logic inside family views, helpers, and capability rules
- avoid scattering `if family` across unrelated screens
- do not generalize shared code unless the gain is real and safe

### Reuse existing infrastructure

Prefer reusing:

- household capabilities
- task providers
- expense providers
- shopping providers
- reward providers if safe

But do not reuse copy or UX blindly.

### Gate sensitive features by capability helpers

Create or extend helpers for:

- `isFamilyAdult`
- `isFamilyChild`
- `isFamilyAdmin`
- `shouldShowFamilyFinanceHomeCard`
- `shouldShowFamilyRanking`

Do not hardcode those rules repeatedly inside widgets.

## Recommended file ownership by area

### Home family

Probable files:

- `flutter_client/lib/features/dashboard/presentation/screens/modes/home_family_view.dart`
- `flutter_client/lib/features/dashboard/presentation/screens/home_screen.dart`
- `flutter_client/lib/features/household/presentation/providers/household_providers.dart`

### Hub family

Probable files:

- `flutter_client/lib/features/dashboard/presentation/screens/household_social_hub_screen.dart`
- `flutter_client/lib/features/settings/presentation/screens/settings_screen.dart`

### Onboarding family

Probable files:

- `flutter_client/lib/features/household/presentation/screens/setup_screen.dart`

### Rewards and ranking

Probable files:

- family-specific ranking widgets or screens
- family-adapted reward screens or providers
- reward provider extensions

### Member model

Probable files:

- `flutter_client/lib/features/household/domain/models/member.dart`
- household repositories
- settings role editor

## Delivery strategy for another AI

Do not assign this entire spec in one prompt.

It should be delegated phase by phase.

Each phase should:

- touch a small, coherent file set
- have explicit acceptance criteria
- avoid backend + frontend + rewards all at once
- be reviewed before the next phase

## Safe phase order

### Phase 1. Family home restructure

Goal:

- make family home operational

Scope:

- ranking summary placeholder block
- shopping in home
- finance conditional visibility
- move or reduce members in home

Do not:

- touch couple home
- touch rewards backend
- refactor unrelated shared widgets

Acceptance criteria:

- family home answers the 4 main questions
- shopping is visible
- finance is conditional
- members are no longer decorative-first

### Phase 2. Family member roles and admin semantics

Goal:

- separate visible family role from admin permission

Scope:

- settings labels
- member cards
- family role suggestions
- admin badge logic

Do not:

- redesign rewards yet
- change couple reward logic

Acceptance criteria:

- member type, visible role, and admin are conceptually separated in UI
- family labels are coherent

### Phase 3. Weekly ranking

Goal:

- add family weekly competition loop

Scope:

- ranking widget
- leaderboard logic from tasks
- household weekly summary

Do not:

- merge this with full rewards redesign

Acceptance criteria:

- family home shows meaningful weekly ranking
- contribution is visible per member

### Phase 4. Personal and family store

Goal:

- adapt coin economy to family

Scope:

- member-adapted catalog
- child rewards
- adult rewards
- family shared section

Do not:

- rewrite couple rewards in the same task

Acceptance criteria:

- children and adults do not see the exact same store
- family shared rewards exist as a separate concept

### Phase 5. Admin approvals and family reward management

Goal:

- allow household-level control

Scope:

- approval rules
- reward creation/editing by admin
- family reward management UI

Acceptance criteria:

- admins can manage family rewards
- non-admins cannot change family catalog

### Phase 6. Hardening and QA

Goal:

- protect existing modes and validate rules

Scope:

- regression tests
- visibility tests
- family vs couple isolation tests

Acceptance criteria:

- family changes do not regress couple
- visibility rules behave correctly by member type

## Copy checklist

Never use in family:

- romantic approval wording
- couple-only labels
- duel framing

Prefer:

- hogar
- familia
- convivencia del hogar
- ranking semanal
- integrantes
- responsable

## Definition of done

Family mode is considered complete when:

- onboarding is family-specific
- home is operational
- shopping is first-class in home
- finance is conditional and sensible
- ranking is visible and useful
- rewards are segmented by profile
- family shared rewards exist
- settings support roles and admin semantics
- couple mode remains stable

## Final state expectation

When this spec is fully implemented, family mode should feel like:

- a real household coordination system
- useful for adults and children
- motivating week to week
- structured, not generic

It should not feel like:

- couple mode with extra members
- a generic shared-home dashboard
- an avatar gallery with chores
