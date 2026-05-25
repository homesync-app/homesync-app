---
version: alpha
name: HomeSync
description: Product and brand context for HomeSync — a warm household coordination app for couples, families, friends/roommates, and solo users. Pairs with DESIGN.md (visual system) to keep generated UI on-brand instead of generic.
audience:
  primary: Argentine Spanish speakers (voseo) coordinating a shared or personal home
  segments: [couple, family, friends, solo]
  platform: Flutter mobile, single-column, mobile-first
  literacy: Everyday users, not power tools — finance and chores must feel light, never accountant-grade
brand-personality: [warm, practical, calm, collaborative, trustworthy, never cold or administrative]
anti-references:
  - Corporate fintech (cold blue, dense tables, "dashboard" energy)
  - Over-gamified kid apps (loud badges, confetti everywhere, points for everything)
  - Sterile productivity tools (Notion/Linear grayscale, dense, neutral-to-the-point-of-clinical)
  - Romantic kitsch (hearts everywhere, pink gradients, saccharine copy)
  - Generic AI slop (purple gradients, nested cards, stock hero with low-contrast text)
---

## What HomeSync is

HomeSync helps people run a home together without it feeling like admin. It covers the unglamorous coordination of real life — recurring chores, shared money and balances, approvals, shopping lists, savings goals, and light rewards — and makes it feel organized, warm, and human. The same app reshapes itself across four household modes so a couple, a family, a group of roommates, and a solo user each get copy and emphasis that fit their relationship, not a one-size-fits-all template.

The emotional target: "our home is handled, and it feels good." Never "I am doing data entry into a financial system."

## Who uses it

- **Primary audience:** Argentine Spanish speakers (source copy in **voseo**), coordinating either a shared household or their own life. Everyday people, not finance pros — money features must stay legible and unintimidating.
- **Context of use:** phone in hand, often mid-task (adding an expense at the supermarket, ticking a chore, approving a kid's request). Interactions should be fast and low-friction.
- **Four segments**, one component grammar, different tone (see Modes).

## Brand personality

HomeSync is **Scandi-warm**: soft paper backgrounds, peach as the action color, sage as reassurance, rounded geometry, generous breathing room. The voice is warm and human but never childish; practical but never clinical.

If HomeSync were a person: an organized, easygoing friend who keeps the household running, remembers whose turn it is, and never makes you feel judged about money or mess.

**Voice & tone**
- Argentine **voseo** in all source copy ("sumá", "registrá", "te toca"), routed through ARB.
- Short, warm, concrete. Prefer a human verb over a system noun ("Sumar algo" over "Crear registro").
- Encouraging, not pushy. Progress is celebrated quietly, not gamified into pressure.
- Tone bends per mode (below); the component grammar does not.

## Modes (personality per segment)

The shared system shifts emphasis through `HouseholdModeDesign` — same components, different register. Mode-aware i18n keys must select tone via ICU `select`.

- **Pareja (couple)** — *Cálido, cercano y emocional.* Accent: warm peach. Give the bond and shared balance the spotlight; allow expressive, affectionate microcopy without losing financial clarity. Dashboard: "Nuestro hogar." Primary action: "Sumar algo."
- **Familia (family)** — *Claro, colaborativo y contenedor.* Accent: sage. More operational than decorative: visible responsibilities, approvals, and rewards; separate adult / teen / kid views cleanly. Dashboard: "Hogar familiar." Primary action: "Organizar."
- **Compañeros / Convivencia (friends/roommates)** — *Ágil, neutral y práctico.* Accent: blue. Avoid romantic or family tones; prioritize splitting, debts, status, next steps. Direct, light language. Dashboard: "Convivencia." Primary action: "Resolver."
- **Solo** — *Calmo, personal y enfocado.* Accent: sage. Fewer elements per screen, more air; progress without competitive pressure. Personal, not social. Dashboard: "Tu espacio." Primary action: "Registrar."

## Core jobs to be done

Money & balances (expenses, who-owes-whom, settling up) · Recurring chores & task rotation · Approvals (esp. family) · Shopping lists · Savings goals · Light rewards (XP, coins, gold — celebratory, never coercive) · Weekly progress & stats. Map any new UI to one of these jobs; if it doesn't serve one, question whether it belongs.

## Anti-references — what HomeSync must NOT look or feel like

- **Not corporate fintech.** No cold blues as the lead, no dense tables, no "enterprise dashboard" density. Money is warm and legible here.
- **Not an over-gamified kid app.** Rewards are a quiet layer, not the point. No confetti on every action, no points for breathing.
- **Not a sterile productivity tool.** Avoid grayscale Notion/Linear neutrality and information density that feels clinical.
- **Not romantic kitsch.** Even in couple mode: warmth through copy and peach accents, not hearts-everywhere or pink gradients.
- **Not generic AI slop.** No purple gradients, no cards-inside-cards, no gradient used to fake hierarchy, no low-contrast text on hero images. (These mirror DESIGN.md's Don'ts.)

## How to use this file

Read **PRODUCT.md** (who/why/tone) together with **DESIGN.md** (tokens, components, visual rules) before generating or reviewing any UI. PRODUCT.md decides *register and intent*; DESIGN.md decides *form*. When they could conflict, mode tone (here) sets the emotional dial and DESIGN.md still governs the component grammar.
