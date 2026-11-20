---
title: Options for a permanent component catalog
type: research
mode: AFK
status: closed
assignee: GessioMori
blocked_by: []
---

## Question

What are the realistic options for a living component catalog in `client-vcnafacul` (React 19, Vite 6, Tailwind 3, TypeScript 5.7, Vitest 3), and what does each cost?

- **Storybook:** which current version supports Vite 6 + React 19? What is the setup and maintenance cost, the CI/build impact, and how does it handle Tailwind, path aliases (`@/`) and the Vitest integration?
- **Lighter alternatives** (for example Ladle), and how well they are maintained.
- **A dev-only in-app route** (`/design-system`) built with the existing Vite and router: how to exclude it from production builds.
- For each option: the docs or MDX story, a11y addon support, and whether it can show tokens (color swatches, type scale).

The output should be a findings file at `research/02-catalog-options.md` with sources.

## Resolution

Findings: [research/02-catalog-options.md](../pesquisa/02-catalog-options.md). This lays out the trade-offs only. Ticket 08 makes the choice.

- **An in-app catalog already exists:** `/dev/vitrine` (`src/pages/devVitrine`, commit `202b760a`). It is gated by `import.meta.env.DEV ? lazy(() => import(...)) : null`, which Vite removes from every build mode the repo uses (verified). It has zero deps and zero config drift. Its weaknesses: no static site to share, docs, controls and token pages are hand-built, and a11y checks in jsdom can't test color contrast. Risk to guard: a build with `NODE_ENV=development` would ship it.
- **Storybook 10.6.5** works with Vite 6 + React 19 and reuses `vite.config` (`@/`, svgr, Tailwind). It provides MDX, `ColorPalette`/`Typeset` token blocks, and browser-based axe checks that include contrast, with CI gating through addon-vitest. **The current addon-vitest needs Vitest 4 or 5.** The repo is on 3, so the options are to upgrade Vitest, pin Storybook ≤ 10.6.2, or skip the addon. Other friction: filter VitePWA, and move the `test` block out of `vite.config`. Cost is about 106 packages and about 70 MB, plus Playwright with the Vitest addon.
- **Ladle 5.1.1** is CSF-style, has an axe panel and MDX, and builds fast. But it has no token blocks and no Vitest integration, its last release was 2025-11, and it measured heavier than Storybook in dependencies. **React Cosmos** is maintained but has no docs or a11y layer. **Histoire** is ruled out (no React support, needs Vite ≥ 7.3).
- A hybrid is possible: keep the vitrine for feature screens, and use a catalog tool, or a vitrine `ds` section plus a Playwright + axe check, for design-system primitives and tokens.
