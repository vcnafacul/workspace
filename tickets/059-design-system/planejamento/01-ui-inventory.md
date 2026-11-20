---
title: Current UI inventory
type: research
mode: AFK
status: closed
assignee: GessioMori
blocked_by: []
---

## Question

What visual vocabulary does `client-vcnafacul` (`origin/develop`) actually use today, and how much of each?

- **Color:** every Tailwind brand color and arbitrary hex/rgb value, with usage counts and where each is concentrated (home / student area / dash). Also list the duplicates and near-duplicates.
- **Typography:** font sizes, weights and line heights in use, plus any heading components.
- **Spacing, radius, shadows:** which values are common and which are one-offs.
- **Components:** for each kind (button, text input, select, checkbox/radio, toggle, modal/dialog, card, table, tabs, menu/dropdown, tooltip, popover, loader/spinner/skeleton, toast, badge/status, pagination, accordion), list every implementation (V1 atoms/molecules, `components/ui` shadcn, MUI, PrimeReact, headlessui, dashV2) with file paths, usage counts and variants.
- **Icons:** usage per icon set and per area.

The output should be a findings file at `research/01-ui-inventory.md` that later tickets can cite.

## Resolution

Full findings, with methodology and `origin/develop` @ `bdb34525`: [research/01-ui-inventory.md](../pesquisa/01-ui-inventory.md)

- **Three separate color systems are mixed.** There are 1,918 brand/shadcn-named classes, 1,967 Tailwind-default palette classes (`gray-*` alone is 1,086, mostly in the dash), 42 arbitrary `[#hex]` classes (34 of them in homeV2) and ~288 raw hex literals (charts, inline styles, CSS). The dash uses more Tailwind defaults (1,417) than brand colors (839).
- **302 color classes in 81 files render nothing.** The flat `red/orange/yellow/green/pink/purple` in `theme.extend.colors` replace Tailwind's scales, so `text-red-600`, `bg-green-50` and the like produce no CSS. Non-`extend` `animation`, `keyframes` and `backgroundImage` also kill `animate-spin` (28), `animate-pulse` (20, including shadcn `Skeleton`) and `bg-gradient-to-*` (24). This was verified by compiling with tailwind 3.4.19.
- **There are many near-duplicates.** `green2` = `darkGreen` (exact); there are 3 live reds (`red`, `redError`, the zinc `destructive`) and 5 overlapping neutral systems (`grey`, `gray-*`, `slate-*`, zinc vars, `lightGray`/`gray2`/`darkGrey`); `darkOrange` is lighter than `orange`; blue is used widely (170 classes) but is not a brand color. No AA-text orange or green exists except the arbitrary `#b35300`/`#0d7a63` in the student dashboard.
- **Every component kind has 3 or more implementations.** Buttons alone come from V1 `molecules/button` (64 files), shadcn `ui/button` (61), MUI (28) and 271 raw `<button>`. Modals come from V1 `ModalTemplate` (73 files, no dialog role, focus trap or Esc), `ModalConfirmCancel` (23), shadcn Dialog/AlertDialog/Sheet, `AlertDialogUI` and 23 hand-rolled overlays.
- **The V1 button defaults to white on orange.** `primary` (white on `#FF7600`, 2.68:1) is 77 of 122 V1 Button uses, and `secondary` (orange on white) is 22. `tertiary` is unused. shadcn `outline` (56) is the most-used variant of any button.
- **Library themes are not brand-aware.** shadcn uses stock zinc, MUI has no `ThemeProvider` (default blue and a Roboto→Arial fallback, 63 files, 56 of them in the dash), PrimeReact loads the `md-light-indigo` theme globally just for `Calendar` (10 files) and toasts use react-toastify's default `colored` palette (130 files, 367 calls).
- **dashV2 is the de-facto seed.** All 9 admin list screens use `DashListTemplate`, and `dashCardTemplate` has 0 users. dashV2 is shadcn/Radix (`popover`, `tooltip`, `table`, `pagination`) restyled through `tokens.ts`, guarded by a vitest palette ratchet. `pages/devVitrine` is an existing dev-only showcase.
- **Type, spacing, radius and shadow values cluster tightly.** Text is `text-sm`/`text-xs` 75% of the time, weights are semibold/medium/bold, and `leading-*` is rarely set. 800/900 weights are used but not loaded. Spacing sits on 0.5–8 (`p-4`, `gap-2` dominate), radius on `md`/`lg`/`full` and shadows on `sm`–`xl`.
- **Icons come from 4 libraries in 21 import roots.** lucide is in 90 files across all areas, react-icons in 71 (17 sub-packs, `fi` ≈ lucide in 26 dash files), heroicons in 14 (dash/`dashProvas` only) and Radix in 6 (inside `ui/*`), plus 53 local SVGs, mostly for public.
