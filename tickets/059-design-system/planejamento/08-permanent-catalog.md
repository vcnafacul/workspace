---
title: Permanent component catalog
type: grilling
status: closed
assignee: GessioMori
blocked_by: [02, 03]
---

## Question

Which living catalog does the design system ship with (see [Options for a permanent component catalog](02-catalog-options.md)), where does it live, how is it built and published, and what is the rule for when a new component must get an entry?

## Resolution

Decided in a grilling session on 2026-10-28, based on [Options for a permanent component catalog](02-catalog-options.md) ([research/02-catalog-options.md](../pesquisa/02-catalog-options.md)).

- **Audience: developers now, shareable later.** The tool must be able to produce a static site, but nothing is published yet. Publishing (where, and behind what access) is decided when a designer or reviewer actually needs it, for example whoever mirrors the spec into Figma (#343).
- **Tool: Storybook 10.6** (exact version pin; upgrades are deliberate PRs) for **design-system components**. **`/dev/vitrine` stays** for feature screens that need fake API/auth data. The boundary: **anything in the design-system folder has stories; anything that needs API data is a vitrine entry.**
  - Extending only the vitrine was the first recommendation (zero deps) but was rejected after discussion. Storybook's value (controls, autodocs from TS types, per-component axe checks in a real browser, viewport and theme toolbars, MDX docs, familiarity for new volunteers) pays off immediately in the build phase right after this map. Migrating vitrine states to stories later would cost more than starting with Storybook now.
  - Storybook for everything (migrating the vitrine's feature screens) was rejected. The vitrine's fake fetch/auth pattern is what those screens need.
- **No `@storybook/addon-vitest`**, so no Vitest 3 → 4/5 upgrade and no Playwright/Chromium in CI on the already-strained 2-vCPU runner. Instead:
  - **Story smoke tests:** stories are rendered in plain Vitest 3/jsdom through `composeStories` from `@storybook/react`.
  - **Token-contrast test:** a Vitest test computes WCAG 2.x contrast for every semantic foreground/background pair from the token values (the same math as the [Color palette](05-color-palette.md) prototype's table) and fails below 4.5:1 for text and 3:1 for UI.
- **Accessibility:** Storybook's **axe panel** for manual checks in a real browser, which catches render-time problems token math misses (opacity, `/10` tints, overlays, `className` overrides), plus the automated token-contrast test.
- **CI:** `build-storybook` runs on PRs that touch the design-system folder or `.storybook/`, so a broken story or config fails the PR instead of rotting silently.
- **Coverage rule:** every design-system component **must** have a colocated `*.stories.tsx`, with **one story per variant and one per state that changes its look** (disabled, invalid, loading, open, selected…). Autodocs and controls are on. A guard test (same style as `semComponenteNoRender.test.ts`) fails CI when a component file in the design-system folder has no matching stories file.
- **Docs (MDX):**
  - **Foundations pages** (colors, type, spacing, radius, shadows, z-index) built from token data with `ColorPalette`/`Typeset` and hand-made tables.
  - **Usage pages** for complex components (data table, DatePicker, Dialog): when to use, when not to.
  - The **written guidelines** (accessibility, writing tone, responsiveness; still in the map's fog) live here too.
- **Setup:**
  - `.storybook/preview` imports `src/index.css` and loads Raleway as `index.html` does, and wraps stories in router and toast decorators.
  - **Toolbars:** viewport presets at 390 / 768 / 1200 (the breakpoints), and a `[data-theme]` switcher (neutral, marine, pink, green, yellow; `.dark` later).
  - `viteFinal` filters out `VitePWA`.
  - Where `.storybook/` and the stories sit relative to the design-system folder follows [Where the design system lives and what it's called](11-location-and-naming.md); stories are colocated with components either way.

