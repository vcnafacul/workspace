---
title: Where the design system lives and what it's called
type: grilling
status: closed
assignee: GessioMori
blocked_by: [03]
---

## Question

Where does the design system's code live in `client-vcnafacul`, and how are its parts named?

- Extend `src/components/ui` (shadcn's folder, 133 importers), or start a new folder (for example `src/components/ds`)? Where do tokens (CSS in `index.css`), the Tailwind plugin (type steps) and the `palette` TypeScript export live?
- Does dashV2 (`DashTable`, `DashToolbar`, `StatusBadge`, `DashListTemplate`, …) move into the design system, stay a consumer of it, or split?
- Component and file naming: English (shadcn) or Portuguese (much of the codebase)? File casing (`button.tsx` like shadcn, or `Button.tsx`)?
- How the design system relates to the atoms/molecules/organisms/templates structure. Is that structure kept for domain components, or retired?
- Where the guard test lives and what it is called.

## Resolution

Decided in a grilling session on 2026-10-28.

- **`src/components/ui` is the design system.**
  - The shadcn CLI keeps writing there (`components.json` → `@/components/ui`), and the 133 existing importers keep their paths.
  - Restyled shadcn components and new ones (DatePicker, Spinner, `DataTable`, `StatusBadge`, `DateRangePicker`, …) all live there, and the Storybook coverage rule ([Permanent component catalog](08-permanent-catalog.md)) applies to this folder.
  - The unused `ui/accordion.tsx` and `ui/form.tsx` are adopted or deleted during the build.
  - **The spec replaces dashV2's rule "`components/ui/*` não são editados por trabalho do V2"** (`dashV2/README.md`). That rule protected V1 during the dashV2 POC, and design-system work restyles `ui` by definition ([How tokens are structured](04-token-architecture.md)).
  - A new `components/ds/` folder (133 import rewrites) and a top-level `src/design-system/` were rejected.
- **dashV2 is split now, and patterns are revisited after V1 is gone.**
  - **Into `ui`** (generic, needed beyond admin lists): `DataTable` (from `DashTable`, extended with selection and server-side pagination/sort per [Which UI libraries to keep](03-library-strategy.md)), `StatusBadge`, `DateRangePicker` (from `DashDateRangeFilter`), and the table skeletons from `DashTableEmpty`. They lose the "Dash" prefix and any V1 glue.
  - **Stays in `components/dashV2`** as a consumer of the design system: `DashListTemplate`, `DashToolbar`, `DashFilterBar`, `DashListFooter`, `deriveColumns`/`deriveActions`, `useAcimaDeSm`, `paginacao`, `sortRows`, `intervaloDeDatas`. Reason: they import V1 (`molecules/cardDash`, `molecules/button`, `@/context/dashCardContext`, `atoms/select`) and domain enums (`StatusContent`, `StatusEnum`). Inside `ui`, the design system would depend on code scheduled for deletion, and the template is driven by API/context data, which is vitrine territory, not Storybook.
  - **Revisit:** the spec records that `DashListTemplate` can be promoted to a documented design-system **pattern** once it no longer imports V1 and domain code (after `derive*` is gone and screens declare columns explicitly). Whether the design system has a "patterns" layer at all is decided then.
- **Naming:**
  - **English** component and prop names (`DataTable`, `StatusBadge`, `variant`, `size`, `loading`).
  - **Lowercase kebab-case files** in `ui`, as shadcn writes them (`data-table.tsx`, `status-badge.tsx`), with colocated `data-table.stories.tsx`.
  - **Domain code outside `ui` keeps its Portuguese convention** (`CardDeMetrica`, `intervaloDeDatas`), so the folder is the language line. Domain words map onto generic props at the call site (a screen maps "Concluída" to `StatusBadge variant="success"`).
  - PascalCase files and Portuguese design-system names were rejected.
- **The atomic folders (`atoms`, `molecules`, `organisms`, `templates`) are frozen.**
  - No new files go in them, enforced by the guard test.
  - New domain components go in `components/<domain>/` (as `indicadores`, `chat`, `push` already do), or are colocated with their page when only one page uses them.
  - Existing domain components move out when someone touches them, and the folders are deleted along with V1.
  - A one-shot reorganization was rejected as churn.
- **Where the other pieces live:**

  | Piece | Location |
  |---|---|
  | Token CSS variables (primitives, semantic, `[data-theme]` overrides, `--radius`, `--header-h`) | `src/styles/tokens.css`, imported at the top of `src/index.css` |
  | Tailwind wiring (semantic color map, shadows, z-index, widths, screens) | `tailwind.config.js` |
  | Type-step plugin | `tailwind/type-scale.js` |
  | `palette` TS export (charts, home expressive layer) | `src/lib/palette.ts` |
  | Guard tests (deprecated classes with ratchet counts, banned imports, frozen folders, missing stories) | `src/design-system/guard.test.ts` (absorbs `dashV2/tokens.test.ts`) |
  | Token-contrast test | `src/design-system/contrast.test.ts` |
  | Storybook config | `.storybook/` at the repo root |
  | MDX foundations, usage pages and guidelines | `src/design-system/docs/` |

  Putting everything inside `components/ui` was rejected: `ui` stays a pure component folder, as the shadcn CLI and the stories rule assume.

