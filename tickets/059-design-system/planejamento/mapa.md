---
label: wayfinder:map
source_issue: https://github.com/vcnafacul/client-vcnafacul/issues/343
status: spec-ready
---

# Map: Você na Facul design system (#343)

## Status: destination reached

The implementation-ready spec is **[spec.md](../spec.md)**. The next step is building the single migration PR it describes (§7). That's outside this map.

## Destination

An implementation-ready **spec** for a code-first design system in `client-vcnafacul` covering tokens, the component inventory with variants, library consolidation, the permanent component catalog and a phased migration plan. It comes with a throwaway **HTML visualizer** of the tokens and representative components (in `prototypes/`). Reaching it means someone can start building with nothing left to decide.

## Notes

- **Domain:** frontend UI. Repo: `client-vcnafacul` (React 19, Vite 6, Tailwind 3, shadcn/Radix in `components/ui`, plus MUI, PrimeReact and the V1 atoms/molecules kit). Always read code from `origin/develop` (`git show` / `git grep origin/develop`), because the local checkout is behind.
- **Skills:** `/grilling` + `/domain-modeling` for grilling tickets; `/prototype` (and `/frontend-design`) for prototype tickets; `/research` for research tickets. Grilling is **one question at a time**.
- **Tracker:** local files only, never GitHub issues, never inside a repo folder. Tickets live in `tickets/NN-<slug>.md` with frontmatter `type`, `status` (open|closed), `assignee`, `blocked_by`. A ticket is claimed by setting `assignee` before any work. Its answer goes under `## Resolution` at the end of the file. Research findings go in `research/`, prototypes in `prototypes/`.
- **Plan, don't do:** no code changes in `client-vcnafacul` during this map. Even the phase 0 config fix waits for the single PR ([Migration plan](12-migration-plan.md)). The HTML prototypes are throwaway assets.
- **Settled while charting** (these rules apply to every ticket):
  - **Code is the source of truth.** The spec defines tokens and components; a Figma library may mirror it later (out of scope).
  - **Visualizer:** a throwaway HTML prototype is this map's working asset. The *permanent* catalog (Storybook / in-app route / …) is decided in a ticket and goes into the spec.
  - **dashV2 is the seed.** The roles and decisions in `src/components/dashV2/tokens.ts` stay unless a ticket explicitly overturns one. They are: surface/page/border/text/action roles, at most one primary button per screen, ~~primary = `bg-orange text-marine`~~ (overturned in [Color palette](05-color-palette.md): the CTA is white on the darker orange `#B35300`, because white on `#FF7600` is only 2.68:1), and an invalid field gets a red border while its message stays in a neutral text color. The V1 white-on-orange primary is therefore a known migration item.
  - **Coverage:** one token foundation for all three surfaces: the public site/home, the student area, and the admin dashboards. The home `sectionThemes.css` becomes an "expressive" layer on the same tokens, not a separate palette. *Coverage* (all) is separate from *rollout order* (migration plan).
  - **Input:** the code on `develop` is the only source. No Figma or mockups are used.
  - **Dark mode:** values are out of scope, but the token structure must be **dark-mode-ready** (semantic tokens that a theme can remap).
- **Facts from the charting survey** (2026-10-28, `origin/develop` @ `bdb34525`):
  - Import counts by file: `@/components/ui/*` 138, `react-toastify` 194, `molecules/button` 65, `@mui/material` 63, `@mui/x-*` 23, `primereact` 14, `@headlessui` 1. Icons: lucide 91, react-icons 77, heroicons 14, radix-icons 6.
  - The shadcn CSS variables in `src/index.css` are still the default **zinc** grays (`--primary: 240 5.9% 10%`), unrelated to the brand. A `.dark` block exists and is unused.
  - The brand colors are flat names in `tailwind.config.js`: `marine #0B2747`, `orange #FF7600`, `pink #DA005A`, `green #37D6B5`, `yellow #FFE53C`, grays, and near-duplicates (`green2`/`darkGreen` both `#0F9B2C`, `green3`, `red`/`redError`). There are also `logo*` colors per area.
  - The font is Raleway (300–700, from Google Fonts in `index.html`). The custom breakpoints are `sm 768 / md 1200 / lg 1400 / xl 1565`.
  - There are about 25 arbitrary hex classes (`text-[#0b2747]`, `text-[#b35300]`, …), mostly on the home page.

## Decisions so far

<!-- one line per closed ticket: [title](NN-slug.md) — gist -->

- [Options for a permanent component catalog](02-catalog-options.md) — a dev-only in-app showcase **already exists** at `/dev/vitrine` (zero deps, excluded from prod). Storybook 10.6.5 fits Vite 6 + React 19 but its Vitest addon needs Vitest ≥ 4 (the repo is on 3). Ladle and Cosmos are weaker, Histoire is ruled out, and a hybrid is possible. The choice belongs to the permanent-catalog ticket.
- [Current UI inventory](01-ui-inventory.md) — three color systems are mixed (brand, Tailwind defaults, ~330 raw hex). **About 300 color classes and `animate-spin`/`animate-pulse`/`bg-gradient-*` render nothing** because `tailwind.config.js` overrides the default scales. No library is themed to the brand (shadcn zinc, MUI default blue, PrimeReact indigo). Every component kind has 3+ implementations, including the V1 white-on-orange button (77/122 uses) and `ModalTemplate` without dialog a11y (73 files). dashV2 now backs all 9 admin lists.
- [Which UI libraries to keep](03-library-strategy.md) — **shadcn/Radix + Tailwind is the only foundation**, with variants in cva. MUI (DataGrid included → extend `DashTable`), PrimeReact (→ DatePicker on react-day-picker, `Select`), headlessui, tailwind-variants, react-icons/heroicons/radix-icons (→ lucide + local SVGs), react-loading-skeleton and react-spinners are retired. react-toastify stays, restyled. V1 is frozen and retired; whether to bridge `Button`/`ModalTemplate` belongs to the migration plan.
- [How tokens are structured](04-token-architecture.md) — two layers, both CSS variables in `index.css`. Primitives (`--<hue>-<step>`, HSL channels, no Tailwind utilities) sit under **shadcn's semantic vocabulary, extended** (`success`/`warning`/`info`/`page`/`cta`). **`primary` = marine; orange is `cta`** (at most one per screen; its colors were amended in [Color palette](05-color-palette.md)). **Phase 0 config fix** revives the dead classes, `animate-*` and gradients, after which legacy colors are deprecated behind a guard test. `.dark` and the home `[data-theme]` sections re-point the same semantic tokens. `dashV2/tokens.ts` is eventually folded into cva variants. Non-color tokens are static Tailwind theme values.
- [Color palette](05-color-palette.md) — **brand-led**: success = mint, warning = golden yellow, info = blueGeo blue, error = brand red, marine-tinted neutrals, 8 OKLCH scales with each brand hex pinned. **CTA = white on `#B35300`** (this overturns dashV2's marine-on-orange). Status shows as dots in tables and lists and as tints in alerts. There are two text levels, `input` borders are 3:1, the focus ring is solid orange-600, and every chart series is ≥ 3:1. All legacy colors, `logo*` included, are retired. Home overrides go to the expressive layer.
- [Type scale](06-type-scale.md) — **two densities**: 14px UI `body`, a 16–17px `prose` step for reading, and a weight-800 `display` for the home (retuned later to 30→48px, plus `text-hero` for the hero). Named steps from `display` to `caption` and `numeric`, **12px minimum**, one class per step generated by a small plugin that switches size at 768px. Raleway 400–800 plus 400 italic. Classes on semantic tags, no Text component, `prose` for rich text. Tailwind's default sizes are deprecated behind the guard test.
- [Spacing, radius, shadows and breakpoints](07-spacing-radius-elevation.md) — keep the 4px spacing scale (subsets documented, arbitrary px banned). Radius roles: 6px controls, 8px cards and overlays, 12px modals. **Borders, not shadows, for in-page surfaces**, with three marine-tinted shadow levels for floating elements. **The custom breakpoints stay** (`sm` 768 = mobile/desktop). Layout tokens: gutters, `prose-content`/`form`/`page` widths, Dialog `size`, `--header-h`. Named z-index layers with popovers above modals and toasts on top.
- [Permanent component catalog](08-permanent-catalog.md) — **Storybook 10.6 for design-system components** (exact pin, no Vitest add-on), and **the vitrine stays for feature screens** with fake API data. Story smoke tests run through `composeStories` in Vitest 3, plus a token-contrast math test. Every design-system component must have stories for each variant and state (a guard test enforces it). MDX holds the foundations, usage pages and guidelines. `build-storybook` runs in CI on design-system changes. Nothing is published yet.
- [Where the design system lives and what it's called](11-location-and-naming.md) — **`components/ui` is the design system** (the spec replaces dashV2's "don't edit `ui`" rule). **dashV2 is split**: `DataTable`, `StatusBadge`, `DateRangePicker` and the skeletons move into `ui`, and the template and toolbar stay as a consumer; making it a pattern is revisited after V1. English names with kebab-case files in `ui`, Portuguese domain code outside. The atomic folders are frozen. Tokens go in `src/styles/tokens.css`, guards and docs in `src/design-system/`, `palette` in `src/lib`.
- [Core components visual prototype](10-core-components-prototype.md) — **adaptive density**: 36px controls and 40px rows on desktop; on mobile, 44px touch targets, **tables become cards** (each column declares a role, `renderMobileCard` as escape hatch) and dialogs go full-screen. 7 button variants × 6 states. Field anatomy with a **red asterisk for required fields**. Underline tabs only. **Error and warning toasts stay until dismissed.** Marine-tinted shadow values. This becomes the required story list.
- [Migration plan](12-migration-plan.md) — **one PR for everything** (~519 files). No bridges, retired dependencies removed in the same PR, and the guard strict from the merge. **Ordered commits, each green, merged without squash** (bisect and revert per step). Rebase daily and re-run the codemods, with a 2–3 day UI freeze at the end. Codemods follow a mapping table, with `ds-review` markers for ambiguous classes. Verified by CI, before/after vitrine screenshots and a homologation checklist. Scope is parity plus the decided improvements: found bugs are logged, tests adapted.
- [Written guidelines](13-written-guidelines.md) — MDX pages in Storybook. **Voice:** friendly "você", sentence case, verb + object buttons, "!" only for celebrations, pt-BR formats. **Errors:** what happened + what to do, field errors under the field. **Accessibility:** heading order, required `aria-label` on icon buttons, no clickable divs, reduced motion, enforced by **jsx-a11y in CI** (the migration PR fixes the broken ESLint setup). **Mobile:** both menus as a left Sheet, single-column forms with full-width actions and a sticky bar, the right `inputMode`/`autoComplete`. One usage-rules page.
- [Expressive layer for the home page](14-home-expressive-layer.md) — **Faithful**: keep the `marine`/`neutral`/`yellow` themes, retire pink/green. Marine re-points tokens, including **`cta` = bright `#FF7600` with marine text on navy**. A new `highlight` token is used for eyebrows. The rainbow becomes `bg-brand-stripe` (header and footer stripe). **`text-hero`** keeps 48→72→96px for the hero only, and **`display` is retuned to 30→48** for section titles (amends the type scale). Hard-coded home colors map to their nearest step, with AA required for text.
- [Write the design system spec](09-write-spec.md) — **destination reached:** [spec.md](../spec.md) has the tokens (full values), Tailwind and type plugin, the `ui` components, libraries, Storybook, guard tests and lint, the guidelines, and the single-PR migration with its commit order, codemod and component mapping tables, and the homologation checklist.

## Not yet specified

_Nothing._ The map is complete; see [spec.md](../spec.md).

## Out of scope

- The Figma library asked for in #343. Code is the source of truth, and Figma can mirror the spec later.
- Dark-mode token values. Only the token structure must allow them.
- Building components or migrating screens. That is the handoff after the spec.
- Consolidating the chart libraries (MUI x-charts, nivo, chart.js, recharts). Only chart **colors** are in scope, through the palette ticket.
