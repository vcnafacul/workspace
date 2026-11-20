---
title: Core components visual prototype
type: prototype
status: closed
assignee: GessioMori
blocked_by: [03, 05, 06, 07]
---

## Question

What do the design system's core components look like? Cover their variants, states and sizes, rendered with the decided tokens ([Color palette](05-color-palette.md), [Type scale](06-type-scale.md), [Spacing, radius, shadows and breakpoints](07-spacing-radius-elevation.md)), all on shadcn/Radix + cva ([Which UI libraries to keep](03-library-strategy.md)).

- **Actions & forms:** `Button` (cta, primary, secondary, outline, ghost, destructive, link; sizes; icon-only; loading; disabled), `Input`, `Textarea`, `Select`, `Combobox` (only if needed), `Checkbox`, `RadioGroup`, `Switch`, `DatePicker`, plus field anatomy (label, hint, error message, required marker).
- **Containers & data display:** `Card`, `Dialog` (with `size`), `AlertDialog`, `Sheet`, `DataTable` (moved from dashV2's `DashTable` into `ui`: selection, server-side pagination, sort, empty, loading), `DateRangePicker`, `Tabs`, `DropdownMenu`, `Tooltip`, `Popover`, `Badge`/`StatusBadge` (dot look in tables, tinted elsewhere), `Alert`, toast (restyled react-toastify), `Skeleton`, `Spinner`, `Pagination`.
- States for each: hover, focus-visible (solid orange-600 ring), active, disabled, invalid, loading.
- Tune the exact shadow values and any layout widths left open in the spacing ticket.
- Mobile (390) and desktop.

This may split into two sessions, "actions & forms" and "containers & data display". Link the prototype(s) in `prototypes/`. The prototype stays throwaway HTML (no client code in this map). The real catalog is Storybook ([Permanent component catalog](08-permanent-catalog.md)), and the list of variants and states decided here becomes the required story list.

## Assets

- Prototype: [prototypes/components.html](../prototipos/components.html). Switch presets with `?variant=A|B|C` or ← →, and width with the bar (`?w=mobile`):
  - **A, Compact:** 36px controls and 40px rows. Mobile tables scroll sideways and dialogs stay centered.
  - **B, Comfortable:** 40px controls and 48px rows. Dialogs become bottom sheets on mobile.
  - **C, Adaptive:** 36px on desktop and 44px touch targets on mobile. Mobile tables become cards and dialogs go full-screen.

  It covers Button (7 variants × 6 states, sizes, icons), form fields (Input/Textarea/Select/Checkbox/Radio/Switch/DatePicker/DateRangePicker with label, hint and error), DataTable (toolbar, selection bar, sort, dot StatusBadge, pagination, empty, loading), Dialog/AlertDialog/Sheet, DropdownMenu/Popover/Tooltip, StatusBadge (dot and tint)/Badge/Alert/Toast, and Card/Tabs/Pagination/Skeleton/Spinner. Everything uses only the decided tokens.

## Resolution

Decided in a prototype session on 2026-10-28 by reacting to [prototypes/components.html](../prototipos/components.html). **Preset C ("Adaptive")** won. Presets A and B are kept as the rejected alternatives. Everything listed here becomes the **required story list** in Storybook ([Permanent component catalog](08-permanent-catalog.md)).

- **Density and mobile behavior: adaptive.**
  - **Desktop:** 36px control height (`md` buttons, inputs, selects), 40px table rows (dashV2's current density).
  - **Under 768px:** **44px touch targets** for controls, options (checkbox/radio/switch rows) and menu items.
  - **Tables collapse into cards.**
  - **Dialogs go full-screen** with stacked, full-width buttons (primary action on top).
  - Rejected: Compact everywhere (sub-44px targets on phones, sideways-scrolling tables) and Comfortable everywhere (40px controls and 48px rows cost ~20% of admin density for a touch comfort only phones need).
- **Button:**
  - **Variants:** `cta`, `primary`, `secondary`, `outline` (border = `input`, 3:1), `ghost`, `destructive`, `link`.
  - **Sizes:** `sm` (control height − 4px), `md` (default), `lg` (control height + 8px), plus icon-only (`size="icon"`, **`aria-label` required**).
  - **States:**
    - hover: a 12% darken (`primary` lightens; `outline`/`ghost`/`secondary` get the `accent` background);
    - focus-visible: the solid orange-600 ring with a 2px white offset;
    - active: a 1px press;
    - disabled: 50% opacity, `not-allowed`;
    - loading: spinner + label, disabled.
  - At most one `cta` per screen.
- **Field anatomy** (one `Field` wrapper around every control):
  - `label` (13px/600), then the control.
  - Below it, either a **hint** (`caption`, `muted-foreground`) or an **error**: `destructive` border, red `x-circle` icon, message text in `muted-foreground`.
  - The error is associated through `aria-describedby`, and the control gets `aria-invalid`.
- **Required fields: red asterisk** after the label (`destructive`, `aria-hidden`). The control gets `required`/`aria-required`. Any form with required fields shows a one-line "* obrigatório" legend.
  - It matches the larger existing count: ~42 asterisk labels, mostly the student inscription steps and the cursinho registration form, against 19 "(opcional)" labels in newer dash code.
  - "(opcional)" markers are removed during migration.
- **Selection controls:** Checkbox (checked and indeterminate = `primary`), RadioGroup and Switch (on = `primary`, off = `input`), each with a disabled state.
- **DatePicker / DateRangePicker:** react-day-picker in a `Popover`, pt-BR month and weekday labels, previous/next icon buttons. The selected day is `primary`, range days use `accent`, and today has a 1px `input` ring. The trigger is a field with a calendar icon.
- **DataTable** (from dashV2 `DashTable`):
  - **Toolbar:** search, a "Filtros" button with an active-count badge, and the `cta`.
  - **Selection:** a selection bar appears when rows are selected (count + bulk actions; destructive actions shown as `ghost` text in `destructive`). The header checkbox has an indeterminate state, and selected rows use the `accent` background.
  - **Table:** sortable headers (the sorted one in `foreground` with a direction arrow), numbers right-aligned with tabular figures, **dot `StatusBadge`**, and a `⋯` row menu.
  - **Footer:** "Mostrando X–Y de N" plus pagination.
  - **Other states:** empty (icon, title, hint, "Limpar filtros") and loading (skeleton rows).
  - **Mobile cards:** each column declares `mobile: "title" | "meta" | "status" | "hidden"`. Defaults are derived: the first column is the title, the `StatusBadge` column is the status, the next 2 columns are meta (joined by "·"), and the rest are hidden. Selection and row actions always show. `hideBelow` maps to `mobile: "hidden"`. **`renderMobileCard(row)`** is the escape hatch for tables that need a custom card.
- **Overlays:**
  - **Dialog:** `size` `sm` 400 / `md` 560 / `lg` 800 / `full`, with a close icon button, title (`h3`) and description (`body-sm` muted). Footer: secondary action `outline`, main action `primary`/`cta`.
  - **AlertDialog:** names the action in its title and button ("Excluir prova", never "OK"), and the destructive button is `destructive`.
  - **Sheet:** slides in from the right.
  - All of them are `rounded-xl` + `shadow-lg` over a marine scrim, full-screen on mobile, with a Radix focus trap and Esc.
- **Menus:** DropdownMenu (optional label, leading icons, separators, destructive item in `destructive` text, optional shortcut hint), Popover and Tooltip (`primary` background, `caption` text). All are `shadow-md` at `z-popover`, with `accent` highlight.
- **Tabs: underline only.** A 1px `border` baseline; the active tab has a 2px `primary` underline and `foreground` text, and inactive tabs use `muted-foreground`. The pill/segmented style is not part of the design system. A segmented control for in-place switches (chart periods) can be proposed later as a separate component.
- **Feedback:**
  - **`StatusBadge`:** `look="dot"` in tables and lists, `look="tint"` elsewhere. Variants: `success`, `warning`, `destructive`, `info`, `neutral`.
  - **`Badge`:** `default` (`primary`), `secondary`, `outline`.
  - **Alert:** tinted (`*-muted` background, status-colored icon and title, `foreground` message).
  - **Toast** (react-toastify config + CSS):
    - white card, `border`, `shadow-md`, status-colored icon, title + optional message, close button;
    - **desktop:** top-right below `--header-h`; **mobile:** top, full width; always `z-toast`;
    - **success and info close after 5s, warning and error stay until dismissed**;
    - `pauseOnHover`, `limit: 3`;
    - set in the shared toast setup, so the ~367 call sites don't change.
- **Other:** Card (`border`, no shadow, `rounded-lg`; header/content/footer parts), Pagination (ghost pages, current page `primary`), Skeleton (`primary/10`, pulsing), Spinner (lucide `Loader2` spinning: inline, in a button, page-level).
- **Shadow values** (marine-tinted), which fill in [Spacing, radius, shadows and breakpoints](07-spacing-radius-elevation.md):
  - `shadow-sm` = `0 1px 2px rgba(11,39,71,.08)`
  - `shadow-md` = `0 4px 12px rgba(11,39,71,.10), 0 1px 3px rgba(11,39,71,.06)`
  - `shadow-lg` = `0 16px 40px rgba(11,39,71,.18), 0 2px 8px rgba(11,39,71,.08)`

