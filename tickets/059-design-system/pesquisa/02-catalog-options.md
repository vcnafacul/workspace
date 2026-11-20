# Research 02: Options for a permanent component catalog

Ticket: [02-catalog-options](../planejamento/02-catalog-options.md) · Researched 2026-10-28 against `client-vcnafacul` `origin/develop` and primary sources (npm registry, official docs, GitHub). This file presents trade-offs only. The choice belongs to ticket 08.

## TL;DR

- **The repo already has a dev-only in-app catalog.** `/dev/vitrine` (commit `202b760a`, 2026-10-16) is a hand-rolled showcase that mounts real feature components with fake `fetch` and auth. It is gated by `import.meta.env.DEV ? lazy(() => import(...)) : null` in `src/routes/PlatformRoutes.tsx`. So the "in-app route" option has a working precedent. A design-system section would extend a pattern the team already uses.
- **Storybook 10.6.5** (released 2026-10-27) supports Vite 5–8 and React 16.8–19. It reuses `vite.config.ts` automatically, so the `@/` alias, svgr and Tailwind via PostCSS work without extra setup. Docs/MDX, `ColorPalette`/`Typeset` token blocks and the axe a11y panel all work. **One catch:** the Vitest addon dropped Vitest 3 in 10.6.3 (2026-10-20). The repo is on Vitest 3, so using story-based tests means either upgrading Vitest to 4 or 5, or pinning Storybook at 10.6.2.
- **Ladle 5.1.1** is lighter and has a CSF-compatible story format, an axe addon and MDX, but no token doc blocks and no Vitest integration. Its last npm release was 2025-11-04. `main` moved to Vite 8 in June 2026 but has not been released since.
- **React Cosmos 7.4** is maintained and lean, but has no docs/MDX and no a11y addon. **Histoire** has no React support and requires Vite ^7.3, so it is ruled out.

## Repo facts that shape the options

| Fact | Source |
|---|---|
| React `^19.2.1`, Vite `^6.0.0` (6.4.x resolves today), Vitest `^3`, TS `^5.7`, Tailwind `^3.4` via `postcss.config.js` (`tailwindcss` + `autoprefixer`), react-router-dom `^7.1.3`, `@vitejs/plugin-react ^4.3` | `package.json` |
| Package manager: Yarn Classic (`yarn.lock`, CI uses `yarn install --frozen-lockfile`) | `.github/workflows/ci-homol.yml` |
| `vite.config.ts` has the plugins `react()`, `svgr()` and `VitePWA({... devOptions: { enabled: true }})`, the alias `@ → ./src`, **and a `test` block** (jsdom, `pool: "forks"`, setup `vitest.setup.ts`) | `vite.config.ts` |
| PR CI runs `yarn test:ci` and then `yarn build` on a 2-vCPU runner. A comment in it notes that one test file already saturates the runner and that Vitest RPC timed out | `ci-homol.yml`, `vite.config.ts` comments |
| Builds: `build`, `build:development` (`--mode development`), `build:homologation`, `build:qa`. No `.env.*` file sets `NODE_ENV`, so **every `vite build` has `import.meta.env.DEV === false`** | `package.json`, `.env.development/.homologation/.production` |
| The existing dev showcase is `src/pages/devVitrine/`: a list of `Vitrine { slug, titulo, arquivo, estados[{ slug, titulo, rotas?, render }] }`, URL `/dev/vitrine/:componente?/:estado?`, with fake `fetch` (`fetchFalso.ts`, answers 501 for routes it has no fake response for) and fake auth (`authFalso.ts`). It has a Vitest test (`fetchFalso.test.ts`) and 18 vitrine files | `git show origin/develop:src/pages/devVitrine/*` |

## Option A: Storybook

### Version and compatibility

- **Current:** `storybook@10.6.5`, published 2026-10-27. The repo has 91k stars and is very active (last push 2026-10-28). Storybook 10.0 shipped on 2025-10-28. Its one breaking change was **ESM-only**, which needs Node 20.16+, 22.19+ or 24+. CI uses `lts/*` (Node 24), so that's fine. ([Storybook 10 blog](https://storybook.js.org/blog/storybook-10/), [npm](https://www.npmjs.com/package/storybook))
- `@storybook/react-vite@10.6.5` peers: `vite ^5 || ^6 || ^7 || ^8`, `react`/`react-dom ^16.8 … ^19`, `typescript >= 4.9.x`. **Vite 6 and React 19 are supported.** (npm registry metadata, `@storybook/react-vite@10.6.5`)
- **Verified locally:** I installed `storybook`, `@storybook/react-vite`, `@storybook/addon-docs` and `@storybook/addon-a11y` (all 10.6.5) into a throwaway Vite 6.4.5 + React 19 project in the scratchpad, not in the repo. One CSF story (`tags: ["autodocs"]`) and one MDX page using `ColorPalette`/`ColorItem`/`Typeset` built successfully with `storybook build`.

### Setup: Tailwind, `@/` alias, plugins

- The Vite builder **loads the project's `vite.config` automatically** ([Vite builder docs](https://storybook.js.org/docs/builders/vite)). Builder source (`@storybook/builder-vite@10.6.5`, `commonConfig`) calls `loadConfigFromFile(...)` and spreads everything except `build`. So the `@/` alias, `svgr()` and PostCSS/Tailwind come through without extra config. Overrides go in `viteFinal` in `.storybook/main.ts`, or in `viteConfigPath` to point at a different config.
- Tailwind: with Vite, "you can skip" PostCSS setup. You import the CSS (`src/index.css`) in `.storybook/preview.ts`. `@storybook/addon-themes` + `withThemeByClassName` gives a light/dark toggle that matches `darkMode: ["class"]` ([Tailwind recipe](https://storybook.js.org/recipes/tailwindcss)). This works for the map's goal that tokens be ready for dark mode.
- **Repo-specific caveats** (inferred from the config, not tested against the real repo):
  - `VitePWA` would also be loaded into Storybook. `devOptions.enabled: true` and `injectManifest` with `srcDir: "src", filename: "sw.ts"` could add SW work to `storybook dev`/`build`. The likely fix is to filter that plugin out in `viteFinal`.
  - Real components that call the API or read `useAuthStore` need the same mocking the vitrine does. Storybook has `sb.mock` module mocking (new in 10) ([blog](https://storybook.js.org/blog/storybook-10/)), and MSW decorators also work. Pure design-system primitives (Button, Field, Badge) don't need this.
- Expected new files: `.storybook/main.ts`, `.storybook/preview.ts`, `*.stories.tsx`/`*.mdx` next to components, and `package.json` scripts `storybook`/`build-storybook` (output `storybook-static/`) ([react-vite docs](https://storybook.js.org/docs/get-started/frameworks/react-vite)).

### Vitest integration (`@storybook/addon-vitest`)

- It turns every story into a Vitest test (render smoke test plus `play` assertions) and runs it in **Vitest browser mode with Playwright Chromium**. A running Storybook isn't needed. It can also report coverage ([Vitest addon docs](https://storybook.js.org/docs/writing-tests/integrations/vitest-addon)).
- **Version trap.** The docs still say "Vitest ≥ 3.0", but the published peer ranges are:

  | addon-vitest | `vitest` peer |
  |---|---|
  | 10.0.0 – 10.6.0 | `^3 \|\| ^4` |
  | 10.6.1 – 10.6.2 | `^3 \|\| ^4 \|\| ^5` |
  | **10.6.3 – 10.6.5 (latest)** | **`^4 \|\| ^5`** |

  (npm registry metadata. Vitest 3 support was dropped quietly in [10.6.3, "Support Vitest 5" #36671](https://github.com/storybookjs/storybook/blob/main/CHANGELOG.md).) The repo is on `vitest ^3`, so the choices are:
  1. **Upgrade Vitest to 4 or 5.** Vitest 4 requires Vite ≥ 6 and Node ≥ 20. Its main breaks are `poolOptions` moving to top-level, `workspace` becoming `projects`, an object-style browser `provider`, and coverage defaults ([v4 migration](https://v4.vitest.dev/guide/migration)). The repo only sets `pool: "forks"` and `teardownTimeout`, so this looks light. Vitest 5 (current `5.0.5`) needs Vite ≥ 6.4 and Node ≥ 22.12, and has many more semantic changes: `clearMocks` on by default, exact `toHaveTextContent`, top-level-only `vi.mock`, and others ([v5 migration](https://vitest.dev/guide/migration)).
  2. **Pin Storybook ≤ 10.6.2** and stay on Vitest 3. This misses later patches. 10.6.2 itself carries security fixes GHSA-f2ph-cmg5-wxc8 and GHSA-px85-f4q5-jh77.
  3. **Skip the Vitest addon.** You keep the Storybook UI, docs and the manual a11y panel, but get no CI gating from stories.
- **Config collision:** "If your Vite config has a `test` property, it merges into the Storybook test config". To isolate them, move it into a separate Vitest config or project ([docs](https://storybook.js.org/docs/writing-tests/integrations/vitest-addon)). This repo has such a `test` block.
- **CI cost:** browser mode needs Playwright Chromium installed in CI, and adds a second test project to a 2-vCPU runner that is already CPU-bound. The docs suggest `isolate: false` or `--shard` to reduce load.

### Accessibility addon

- `@storybook/addon-a11y` runs **axe-core in the real browser** on each story, with Violations, Passes and Incomplete tabs and a vision simulator. `parameters.a11y.test` can be `'off' | 'todo' | 'error'`. With `'error'`, violations fail under the Vitest addon in CI ([a11y docs](https://storybook.js.org/docs/writing-tests/accessibility-testing)).
- Because it runs in a real browser, **color-contrast rules work**. This is the map's central concern: white on `#FF7600` is 2.68:1. jsdom cannot check contrast (see Option C).
- Limits: axe catches "up to 57%" of WCAG issues, and the `region` rule is off by default ([docs](https://storybook.js.org/docs/writing-tests/accessibility-testing)).

### Docs and token display

- `@storybook/addon-docs` provides MDX pages, autodocs from TS props (react-docgen), and the doc blocks [`ColorPalette`/`ColorItem`](https://storybook.js.org/docs/api/doc-blocks/doc-block-colorpalette) (accepts any CSS color, including gradients, so it could show the rainbow `custom-gradient`) and [`Typeset`](https://storybook.js.org/docs/api/doc-blocks/doc-block-typeset) (font family, sizes, weight, sample text), which fits Raleway and the type scale. Both were verified to build (see above). Spacing, radius and elevation have no built-in block and would be custom MDX or JSX.

### Cost

- **Deps added (measured):** the four packages above added about 106 packages and about 70 MB to `node_modules` in the minimal project. Adding addon-vitest + `@vitest/browser-playwright` + `playwright` and the Chromium download comes on top. The real repo already shares some of these (Vite, Babel, Testing Library), so the actual delta would be smaller.
- **Build time:** about 5 s and 8.5 MB output for one story plus one MDX page. That is a lower bound only. Real cost grows with the number of stories and whatever heavy modules they import.
- **Maintenance:** about one minor release a month and frequent patches (10.6.0 → 10.6.5 in 8 weeks). Majors are yearly (9 in 2025-05, 10 in 2025-10, 11 is at `11.0.0-alpha.8`). `npx storybook@latest upgrade` runs automigrations. The catalog lives outside the app, so stories can drift from the components unless CI builds or tests them.
- **Hosting:** optional. A static `storybook-static/` can go anywhere. It can also stay local-only (`yarn storybook`).

## Option B: lighter catalog tools

### Ladle (`@ladle/react`)

- **Version and status:** `5.1.1`, **last npm release 2025-11-04**. GitHub `tajo/ladle` has 3.0k stars and is not archived. `main` got "upgrade Ladle to Vite 8" and dependency bumps on 2026-06-28, but nothing has been released since. That is roughly one maintainer burst per half-year, and the project is clearly smaller than Storybook. ([npm](https://www.npmjs.com/package/@ladle/react), [GitHub](https://github.com/tajo/ladle))
- **Compatibility:** peer `react >= 18`. It **bundles its own Vite as a dependency (`vite ^6.0.5`)**, which dedupes with the repo's Vite 6.4 (verified with `npm ls vite`). It reads the project's `vite.config` (aliases, optimizeDeps), replacing `root`, `server.port` and `build.outDir`, and adds `@vitejs/plugin-react` and `vite-tsconfig-paths` ([config docs](https://ladle.dev/docs/config)). So `@/` and Tailwind should work. The same VitePWA caveat applies, solvable with a separate `viteConfig` path.
- **Stories:** CSF-style (`export const Primary: Story = () => …`). Built-in addons: `a11y` (axe-core, [docs](https://ladle.dev/docs/a11y)), `control`, `width`, `theme`, `rtl`, `source`, `msw`, `action` ([config](https://ladle.dev/docs/config)).
- **Docs/MDX:** `*.stories.mdx` shows up as sidebar pages ([MDX docs](https://ladle.dev/docs/mdx)). There are **no token doc blocks**, so swatches and type scale would be hand-written JSX.
- **Testing:** there is no Vitest addon and no a11y-in-CI story. The documented path is `ladle build` → `ladle preview` → a Playwright spec that reads `meta.json` and screenshots each story ([visual snapshots](https://ladle.dev/docs/visual-snapshots)). Stories are plain components, so a Vitest test can import and render them in jsdom.
- **Cost (measured):** about 370 packages and about 73 MB added (it pulls in koa, msw, Babel, MDX and SWC). A one-story build took about 1 s and produced 0.46 MB.

### React Cosmos (`react-cosmos` + `react-cosmos-plugin-vite`)

- `7.4.1` (2026-08-31), with a canary build on 2026-10-19. 8.7k stars, 5 open issues, actively maintained ([npm](https://www.npmjs.com/package/react-cosmos), [GitHub](https://github.com/react-cosmos/react-cosmos)).
- It uses fixtures (`*.fixture.tsx`) and picks up `vite.config` automatically. It supports static export (`cosmos-export`) ([Vite guide](https://reactcosmos.org/docs/getting-started/vite)).
- It has **no MDX/docs layer, no a11y addon and no Vitest integration** (none are mentioned in the docs). It is a sandbox, not a documentation site.
- Cost (measured): about 136 packages and about 32 MB.

### Ruled out

- **Histoire**: `1.0.0-beta.1` peers `vite ^7.3.0`, which doesn't match the repo's Vite 6, and `@histoire/plugin-react` does not exist on npm. The project focuses on Vue and Svelte. (npm registry)
- **`@axe-core/react`** (runtime a11y logging for an in-app route): its README states "This package does not support React 18 and above" ([README](https://github.com/dequelabs/axe-core-npm/blob/develop/packages/react/README.md)).

## Option C: dev-only in-app route (`/design-system` or `/dev/…`)

### Keeping it out of production: already solved in this repo

Here is the existing pattern (`src/routes/PlatformRoutes.tsx` on `develop`):

```tsx
const DevVitrine = import.meta.env.DEV
  ? lazy(() => import("../pages/devVitrine"))
  : null;
// …
{DevVitrine && (
  <Route path={`${DEV_VITRINE}/:componente?/:estado?`}
         element={<Suspense fallback={null}><DevVitrine /></Suspense>} />
)}
```

- Why it works: Vite replaces `import.meta.env.*` constants statically at build time "to make tree-shaking effective". `DEV` is "always the opposite of `PROD`" ([Vite env and mode](https://vite.dev/guide/env-and-mode)). Rollup removes the dead branch, and with it the `import()`, so no chunk is emitted.
- **Verified locally** with the same shape in a Vite 6.4.5 + React 19 scratch project. A marker string in the lazy module was **absent and no extra chunk was emitted** for `vite build`, `--mode development` and `--mode homologation`. Positive controls: replacing the condition with `true` emitted a second chunk containing the marker, and so did running with `NODE_ENV=development vite build`.
- **The one real risk:** `vite build --mode development` still has `NODE_ENV=production` and `DEV=false`. But if anyone ever sets `NODE_ENV=development`, whether in the shell or in a `.env.[mode]` file, which Vite allows ([docs](https://vite.dev/guide/env-and-mode)), the catalog ships. Cheap guards: a CI step that greps `dist/` for a marker, or a unit test on the route table. Today no `.env.*` file sets `NODE_ENV`.
- Gating on a custom flag (`import.meta.env.VITE_SHOW_DS === "true"`) would also tree-shake, since it is a static replacement too. It would let homologation ship the catalog on purpose if that is ever wanted.

### What you get

- No new dependencies, no second build and no second config. Components render inside the real app shell with the real `index.css`, Tailwind, Raleway, router and providers. So there is zero config drift and no VitePWA/`test`-block conflicts.
- The team already knows the pattern and its tooling: fake `fetch`, fake auth, state URLs for screenshots, and states listed in TS.
- Tokens: swatches and type scale can be rendered from data. Either import the token TS module the spec defines, or use Tailwind v3 `resolveConfig(tailwindConfig)`. Tailwind warns that it "will transitively pull in a lot of our build-time dependencies", but that only matters for dev, because the route is eliminated from builds ([Tailwind v3 config docs](https://v3.tailwindcss.com/docs/configuration)).
- Vitest 3 integration is cheap. The `estados[].render()` functions can be iterated in a jsdom test as smoke tests, with `axe-core` (already the engine everywhere, `4.14.0`) run on the result.

### What you lose compared with Storybook

- **Contrast checks in tests:** jsdom can't compute color contrast ("color contrast checks do not work in JSDOM", [jest-axe README](https://www.npmjs.com/package/jest-axe)). Covering contrast needs a real browser: Vitest browser mode, Playwright with `@axe-core/playwright`, or a manual browser extension. Storybook's a11y panel and addon-vitest provide that out of the box.
- No interactive controls/args panel, autodocs props table, MDX doc blocks, viewport/theme toolbar or vision simulator. All of these would be hand-built. MDX is possible with `@mdx-js/rollup` ([MDX on Vite](https://mdxjs.com/docs/getting-started/#vite)), but that is another dependency.
- **No shareable static site.** By design it is only reachable on `yarn dev`, so designers or reviewers without a local setup can't browse it, unless it is gated by a flag on homologation (see above).
- Isolation: components render inside the app's global providers and CSS. That is fine for a design system, but less pure than an iframe per story.
- Ongoing UI work (navigation, search, state switcher) is owned by the team. The vitrine already has a basic version of this.

## Comparison

| | **Storybook 10.6** | **Ladle 5.1** | **React Cosmos 7.4** | **In-app dev route** (existing `/dev/vitrine` pattern) |
|---|---|---|---|---|
| Vite 6 + React 19 | Yes (peers `vite ^5–^8`, `react ^16.8–^19`). Verified build | Yes (bundles `vite ^6.0.5`, `react >=18`). Verified build | Yes (`vite *`, `react >=18`) | Native |
| `@/` alias / Tailwind | Auto via project `vite.config`. Import `index.css` in preview | Auto via `vite.config` + `vite-tsconfig-paths` | Auto via `vite.config` | Native, zero config |
| Repo-specific friction | Filter VitePWA in `viteFinal`. Split the `test` block out of `vite.config` for addon-vitest | Same VitePWA caveat | Same VitePWA caveat | `NODE_ENV` must never be `development` in builds (add a guard) |
| Vitest integration | `addon-vitest`, browser mode (Playwright). **Needs Vitest ≥ 4 at latest**, or pin ≤ 10.6.2 | None. Import stories into tests, or Playwright snapshots | None | Iterate `estados` in a jsdom Vitest 3 test |
| a11y | axe panel + CI gating (`test: 'error'`). **Contrast works** (real browser) | axe addon (UI only) | None | DIY: axe-core in jsdom (**no contrast**) or a browser runner |
| Docs / MDX | MDX + autodocs + doc blocks | MDX pages | None | Hand-written TSX (MDX only with an extra plugin) |
| Token display | `ColorPalette`, `Typeset` built in | Hand-built | Hand-built | Hand-built, can render from token/Tailwind data |
| Shareable static site | `build-storybook` | `ladle build` | `cosmos-export` | No (dev-only by design) |
| Deps added (measured, minimal project) | about 106 pkgs / about 70 MB (+ Playwright & Chromium with addon-vitest) | about 370 pkgs / about 73 MB | about 136 pkgs / about 32 MB | 0 |
| 1-story build (lower bound) | about 5 s, 8.5 MB | about 1 s, 0.46 MB | not measured | none (excluded from build) |
| Maintenance status | Very active, monthly minors, yearly majors | Last release 2025-11, unreleased `main` work 2026-06 | Active (2026-08 release, 2026-10 canary) | Team-owned code |
| Upgrade burden | Majors + automigrations, ESM-only since 10 | Low but bus-factor risk | Low | None external |

## Trade-offs for ticket 08 to weigh

1. **Extend the vitrine (zero deps) or adopt Storybook (rich docs and browser a11y).** The deciding questions are whether people other than developers need to browse the catalog (static site), and whether contrast must be gated automatically in CI (real browser).
2. If Storybook: **add the Vitest addon now** (requires a Vitest 3 → 4/5 upgrade, Playwright in CI on a 2-vCPU runner already noted as fragile), **pin 10.6.2**, or **run Storybook without addon-vitest** (docs and the a11y panel only, Vitest untouched).
3. A hybrid is possible: keep `/dev/vitrine` for feature screens with fake API data, and use a catalog tool only for design-system primitives and token pages. Or put a `ds` section inside the vitrine plus a Playwright + axe contrast check.
4. Ladle saves little over Storybook in dependencies here (it measured heavier), offers fewer docs features, and has slower releases. Its main advantage is build speed.

## Sources

- npm registry metadata (versions, publish dates, peers, deps), fetched 2026-10-28: [storybook](https://registry.npmjs.org/storybook), [@storybook/react-vite](https://registry.npmjs.org/@storybook/react-vite), [@storybook/addon-vitest](https://registry.npmjs.org/@storybook/addon-vitest), [@storybook/addon-a11y](https://registry.npmjs.org/@storybook/addon-a11y), [@storybook/addon-docs](https://registry.npmjs.org/@storybook/addon-docs), [@ladle/react](https://registry.npmjs.org/@ladle/react), [react-cosmos](https://registry.npmjs.org/react-cosmos), [react-cosmos-plugin-vite](https://registry.npmjs.org/react-cosmos-plugin-vite), [histoire](https://registry.npmjs.org/histoire), [vitest](https://registry.npmjs.org/vitest)
- Storybook: [Storybook 10 announcement](https://storybook.js.org/blog/storybook-10/), [React & Vite framework](https://storybook.js.org/docs/get-started/frameworks/react-vite), [Vite builder](https://storybook.js.org/docs/builders/vite), [Vitest addon](https://storybook.js.org/docs/writing-tests/integrations/vitest-addon), [Accessibility testing](https://storybook.js.org/docs/writing-tests/accessibility-testing), [ColorPalette](https://storybook.js.org/docs/api/doc-blocks/doc-block-colorpalette), [Typeset](https://storybook.js.org/docs/api/doc-blocks/doc-block-typeset), [Tailwind recipe](https://storybook.js.org/recipes/tailwindcss), [CHANGELOG](https://github.com/storybookjs/storybook/blob/main/CHANGELOG.md), `@storybook/builder-vite@10.6.5` dist source (`commonConfig`)
- Vitest: [v4 migration](https://v4.vitest.dev/guide/migration), [v5 migration](https://vitest.dev/guide/migration)
- Ladle: [config](https://ladle.dev/docs/config), [MDX](https://ladle.dev/docs/mdx), [a11y](https://ladle.dev/docs/a11y), [visual snapshots](https://ladle.dev/docs/visual-snapshots), [GitHub tajo/ladle](https://github.com/tajo/ladle) (commit log via GitHub API)
- React Cosmos: [Vite getting started](https://reactcosmos.org/docs/getting-started/vite), [GitHub](https://github.com/react-cosmos/react-cosmos)
- Vite: [Env variables and modes](https://vite.dev/guide/env-and-mode)
- Tailwind v3: [Configuration, Referencing in JavaScript](https://v3.tailwindcss.com/docs/configuration)
- Axe: [@axe-core/react README](https://github.com/dequelabs/axe-core-npm/blob/develop/packages/react/README.md), [jest-axe](https://www.npmjs.com/package/jest-axe)
- MDX: [Getting started, Vite](https://mdxjs.com/docs/getting-started/#vite)
- Repo (`origin/develop`): `package.json`, `vite.config.ts`, `src/routes/PlatformRoutes.tsx`, `src/routes/path.ts`, `src/pages/devVitrine/**`, `.github/workflows/ci-homol.yml`, `.github/workflows/ci-prod.yml`, `.env.*`, commit `202b760a`
- Local experiments (scratchpad, throwaway, outside the repo): Vite 6.4.5 / React 19 / Node 24.17 tree-shaking test; Storybook 10.6.5, Ladle 5.1.1 and Cosmos 7.4.1 install and build measurements
