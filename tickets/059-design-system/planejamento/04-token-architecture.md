---
title: How tokens are structured
type: grilling
status: closed
assignee: GessioMori
blocked_by: [01]
---

## Question

How are design tokens structured and delivered in code?

- What are the layers? Primitive brand values (`marine`, `orange`, …) underneath, semantic roles on top (`surface`, `text-primary`, `action-primary`, `status-error`, …)?
- How are they delivered: CSS variables in `index.css` exposed through `tailwind.config.js`, the Tailwind class constants dashV2 uses, or both? It must be **dark-mode-ready** (see Notes).
- shadcn's `--primary`/`--secondary`/`--muted`/… are zinc today. Should they be remapped to brand roles, and what visibly changes in the 138 files that use `components/ui` if they are?
- How `dashV2/tokens.ts` is absorbed without breaking its "nothing in V1 changes" rule.
- **The current config breaks Tailwind defaults** ([inventory](../pesquisa/01-ui-inventory.md)). Flat `red`/`orange`/`yellow`/`green`/`pink`/`purple` in `extend.colors` remove those default scales (~300 dead classes in 81 files), and the non-`extend` `animation`/`keyframes`/`backgroundImage` kill `animate-spin`/`animate-pulse`/`bg-gradient-*`. Should the token config restore the defaults, build brand scales (`orange-50…900`), or forbid default palettes? And what do the ~1,967 Tailwind-default color classes (`gray-*` 1,086) become?
- What the tokens must feed besides Tailwind: shadcn CSS variables (now confirmed as the only foundation), `react-toastify`'s `--toastify-color-*` variables, and the react-day-picker styles used by the DatePicker ([Which UI libraries to keep](03-library-strategy.md)).
- Naming conventions, and whether the flat legacy names (`green2`, `redError`, …) stay as deprecated aliases.

## Resolution

Decided in a grilling session on 2026-10-28, building on [Current UI inventory](01-ui-inventory.md) and [Which UI libraries to keep](03-library-strategy.md).

- **Two layers.**
  - **Primitives** are raw named values with no meaning.
  - **Semantic tokens** are roles that point at primitives.
  - Components and screens use **only semantic tokens**. There are no component tokens (`--button-primary-bg`); cva variants express that (`bg-primary text-primary-foreground` in `button.tsx`).
- **The semantic vocabulary is shadcn's**, extended. The set is `background`, `foreground`, `card`, `popover`, `primary`, `secondary`, `muted`, `accent`, `destructive`, `border`, `input`, `ring`, `chart-1…n` and `sidebar-*`, plus additions for gaps: `success`, `warning`, `info` (each with `-foreground`), `page` (the app background behind surfaces), `cta`/`cta-foreground`, and whatever [Color palette](05-color-palette.md) needs (for example a secondary text level). dashV2 roles are translated into these names: `surface` → `card`/`background`, `page` → `page`, `border` → `border`, `text.primary` → `foreground`, `text.muted` → `muted-foreground`, `action.primary` → `cta`, `action.destructive` → `destructive`, `invalid` → `destructive` border, `status.done` → `success`, and so on.
- **`primary` = marine, `primary-foreground` = white.** This is the standard solid color for the default `Button`, `Badge`, `Tooltip`, checked `Checkbox` and the `Skeleton` tint. Today it is zinc-900, so the visible change across the 133 `components/ui` files is near-black → navy.
- ~~**`cta` / `cta-foreground` = orange / marine**~~ **Amended in [Color palette](05-color-palette.md): `cta` = a darker orange (`#B35300`) with white text.** The rest of this bullet still holds: with a dedicated `Button` variant `cta`. dashV2's rule **"at most one per screen"** belongs to `cta`. `accent` keeps shadcn's meaning (subtle hover background in menus and selects) and is **not** orange.
- **Delivery: both layers are CSS variables in `src/index.css`.**
  - Primitives are channel values (`--orange-500: …`).
  - Semantic tokens point at them (`--primary: var(--marine-…);`).
  - `tailwind.config.js` only maps names to `hsl(var(--x) / <alpha-value>)`, so opacity modifiers (`bg-primary/90`) work.
  - Non-Tailwind consumers read the same variables: react-toastify (`--toastify-color-*: hsl(var(--success))`, …), the react-day-picker styles for the DatePicker, and chart palettes (through `getComputedStyle` or the `palette` export below).
- **Primitives get no Tailwind utilities.** They exist only as CSS variables. Legitimate raw-color uses (chart palettes, the home expressive layer, illustrations) read them through `var(--…)` or a small TypeScript `palette` export. Tailwind's color utilities offer exactly the semantic tokens plus the legacy names being retired.
- **Format: HSL channels**, as in shadcn v3 (`--marine-900: 212 73% 16%; /* #0B2747 */`), with the hex in a comment beside every primitive. Switch to OKLCH only if the project moves to Tailwind v4.
- **Legacy colors: restore, then retire.**
  - **Phase 0** is a standalone bug fix. *(Amended by [Migration plan](12-migration-plan.md): it ships as the first commit of the single migration PR, not on its own.)* In `tailwind.config.js`, each colliding brand name becomes `{ ...defaultScale, DEFAULT: brandHex }` (red, orange, yellow, green, pink, purple). `bg-red` keeps the brand value, and `text-red-600` & co. render again. `animation`, `keyframes` and `backgroundImage` move into `theme.extend`, which revives `animate-spin`, `animate-pulse` and `bg-gradient-*`. Expect a visible change in about 81 files (302 classes), which is the behavior their authors intended.
  - **After phase 0,** all legacy color utilities are **deprecated**: the flat brand names (`marine`, `grey`, `green2`, `redError`, …) and the Tailwind default families (`gray-*`, `slate-*`, `blue-*`, `amber-*`, …). Existing uses stay, a guard test blocks new ones (as a ratchet), and migration rewrites them to semantic tokens.
- **`dashV2/tokens.ts` is eventually deleted.** Its roles are now semantic token names. Its class combinations (`status.*.{chip,dot,icon}`, `focus`, `row`) become cva variants of the dashV2 components (for example `StatusBadge` `variant`). Its contrast decisions carry over into [Color palette](05-color-palette.md). **Its test grows into the design-system-wide guard test** (only token colors, no default families or arbitrary hex in new code, `cta` text is marine, …). The migration plan decides when.
- **Scoped themes re-point the same semantic variables.** `.dark { … }` (later; values are out of scope) and `[data-theme="marine|pink|green|yellow|neutral"] { --background: …; --foreground: …; --primary: …; … }` are the same mechanism, so any design-system component inside a section adapts without changes. The home's `--section-bg/fg/accent/accent-soft` variables are retired when the home migrates. Which tokens each section overrides is part of the expressive-layer work.
- **Naming:**
  - Everything is in **English**.
  - Semantic tokens are kebab-case, shadcn's `<role>` / `<role>-foreground` pattern, and **never mention a hue** (no `--orange-button`, no `--text-marine`).
  - Primitives are `--<hue>-<step>` on a 50–950 scale. Which hues and steps exist, and which step the exact brand hex sits on, is [Color palette](05-color-palette.md)'s job.
- **Non-color tokens** (type scale, spacing, shadows, breakpoints) are **static values in Tailwind's theme config** (`fontSize`, `spacing`, `boxShadow`, `screens`), with no primitive/semantic split (a named step like `text-heading-2` is already semantic). The exceptions, kept as CSS variables, are `--radius` (shadcn derives `sm`/`md`/`lg` from it) and anything a scoped theme must change.
