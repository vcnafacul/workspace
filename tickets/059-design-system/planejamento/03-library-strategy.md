---
title: Which UI libraries to keep
type: grilling
status: closed
assignee: GessioMori
blocked_by: [01]
---

## Question

Which component foundation does the design system standardize on, and what happens to the others?

- Is shadcn/Radix + Tailwind (`components/ui`) the base? Do we keep `class-variance-authority` or `tailwind-variants` (both are in use) as the variant mechanism?
- MUI (`@mui/material`), PrimeReact and headlessui: phase them out, keep them for specific widgets, or wrap them?
- The V1 kit (`molecules/button`, `atoms/buttonTemplate`, `atoms/input*`, …): absorb, wrap or retire it?
- Icons: one set (lucide? react-icons?) and the rule for the others.
- Toasts: keep `react-toastify` styled to the tokens, or switch?

## Resolution

Decided in a grilling session on 2026-10-28, based on [Current UI inventory](01-ui-inventory.md) (counts are from that file).

- **Foundation: shadcn/Radix + Tailwind is the only foundation.** Every design-system component is a shadcn (`components/ui`) component restyled with our tokens, the way dashV2 restyles through `tokens.ts`. Every other UI library leaves at the pace the migration plan sets.
- **MUI is retired entirely, DataGrid included** (63 files, 56 in dash). The DataGrid screens (`partnerClassWithStudents` and its attendance modals, `studentsEnrolled`, `partnerPrepInscritionStudentManager`, `panelMateria`) use checkbox row selection (5 files), server-side pagination (3) and server-side sorting (1). The design-system data table gains those capabilities by **extending `DashTable`**, with TanStack Table (headless) or hand-rolled internals decided when it's built. `@mui/material` and `@emotion/*` stay installed **only** because `@mui/x-charts` peer-depends on them, until the separate chart-library effort (out of scope). No design-system component may use them.
- **PrimeReact is retired.** `Calendar` (10 files) → a design-system DatePicker built from shadcn `Calendar` + `Popover` on the `react-day-picker` v9 that is already in `package.json` and unused. `Dropdown` (2 files, behind `InputSelect`/`InputFactory`) → shadcn `Select`, plus a `Combobox` (Popover + `cmdk`) only if a searchable select proves necessary. The global `md-light-indigo` theme import leaves `main.tsx`.
- **headlessui is retired.** Its only use (`atoms/dropdownMenu`, the header menu) → shadcn `DropdownMenu`, which adds `@radix-ui/react-dropdown-menu`.
- **Variants: `class-variance-authority` + `cn` only.** `tailwind-variants` (11 V1 files) leaves along with V1. Multi-part components use shadcn's compound-parts pattern (`Card`/`CardHeader`/…) rather than slots.
- **The V1 kit is frozen and retired.** No new imports from `atoms`/`molecules`/`templates` V1 components (enforced by a guard test in the style of `dashV2/tokens.test.ts`), and it is deleted once nothing imports it. **Not decided here:** temporary adapters that rebuild V1 `Button` (white-on-orange default, 77 uses) and `ModalTemplate`/`ModalConfirmCancel` (no dialog a11y, 73 + 23 files) on the design system so the fixes land early. That trade-off goes to the migration plan, and it pulls against dashV2's "nothing in V1 changes" rule.
- **Icons: lucide-react only** for UI icons. react-icons (71 files; Feather `fi` and `lu` first, since they map almost one-to-one), heroicons (14) and `@radix-ui/react-icons` (6, inside `ui/*`) are retired. **Local SVGs** (`src/assets/icons`) stay for brand marks and illustrations, and a brand logo missing from lucide becomes a local SVG rather than a library import.
- **Toasts: keep `react-toastify`**, restyled to the tokens through its CSS variables (`--toastify-color-*`) and container styling instead of `theme="colored"`. None of the ~367 calls change (including `toast.update`/`loading`/`dismiss` and `useToastAsync`). Sonner and a `notify` wrapper were rejected because each is a 130-file rewrite with no user-visible gain.
- **Loading: design-system `Skeleton`** (shadcn) and **`Spinner`** (lucide `Loader2` + `animate-spin`). `react-loading-skeleton` (6 home skeletons) and `react-spinners` (1) are retired, and the MUI loaders go with MUI. This depends on restoring `animate-pulse`/`animate-spin`, which is in [How tokens are structured](04-token-architecture.md).
