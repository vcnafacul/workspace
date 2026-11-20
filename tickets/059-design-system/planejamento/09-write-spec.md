---
title: Write the design system spec
type: task
mode: AFK
status: closed
assignee: GessioMori
blocked_by: [03, 04, 05, 06, 07, 08, 10, 11, 12, 13, 14]
---

## Question

Turn the settled rules in the map's Notes and every ticket resolution into one implementation-ready `spec.md` next to the map. It should cover the tokens (values and delivery), the library decisions, the component inventory with variants, the catalog, the migration plan, the guidelines, and links to the HTML visualizer. Nothing should be left to decide before building. It must include the **legacy class → token mapping table** that the codemods use (see [Migration plan](12-migration-plan.md)), the commit order and the homologation checklist.

All fog has graduated; `blocked_by` lists every ticket on the route.

## Resolution

Written: **[spec.md](../spec.md)**, next to the map. It collects every ticket resolution into one implementation-ready document:

- foundations: full `tokens.css` with all primitives and their hex, semantic tokens, home themes; the `tailwind.config.js` shape; the type-scale plugin; spacing, radius, shadows, z-index, layout; `palette.ts`;
- the `ui` component catalog with APIs and states;
- library keep/retire and `package.json` changes;
- Storybook, guard, contrast and ESLint/jsx-a11y;
- the guideline pages;
- the single-PR migration: commit order, the full **legacy class → token codemod mapping**, the component mapping, the verification plan and the **homologation checklist**.

Small gaps closed while writing, all derived from earlier decisions and flagged in the spec:
- **`Combobox` (+ `cmdk`) is needed.** It replaces MUI `Autocomplete` (2 files), which is the "only if needed" condition from [Which UI libraries to keep](03-library-strategy.md).
- **`Progress` is added for parity.** It covers MUI `LinearProgress`, dashV2's `progress` tokens and the KPI bars.
- **Type-step weights are emitted under `:where()`**, so `font-*` utilities still override them regardless of plugin order.
- **Toast per-type defaults live in `src/lib/toast.ts`** (same API). Only the import path changes at the ~130 importing files; no call changes.
- **`white`/`black`/`transparent`/`current`/`inherit` stay allowed** (the guard doesn't flag them).
- **The `sidebar-*` tokens map** to white/marine/accent/border/ring.
- **The V1 `typeStyle="primary"` mapping:** it becomes `primary`, and the one most important action per screen becomes `cta`, chosen by hand.

