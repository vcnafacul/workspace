---
title: Migration plan
type: grilling
status: closed
assignee: GessioMori
blocked_by: [10]
---

## Question

In what order, and under what coexistence rules, does `client-vcnafacul` move onto the design system?

- **Phase 0** (decided in [How tokens are structured](04-token-architecture.md)) is the standalone Tailwind config fix. Confirm its exact scope and whether it ships before anything else.
- **Phase 1 (foundations):** `src/styles/tokens.css`, the semantic Tailwind map, the type plugin, shadows, z-index, widths, `--header-h`, Raleway weights, the shadcn variables remapped (zinc → brand), and react-toastify restyled. Does this go in as one PR or several? What is visibly changed for users at that point (`primary` turns navy, the focus ring, input borders, text sizes)?
- **Phase 2 (components):** which `ui` components are built or restyled first, and where Storybook + the guard tests + the contrast test land.
- **Rollout order across surfaces** (admin dash, student area, public/home) and which screens go first. The MUI DataGrid screens, the V1 `ModalTemplate` users (73 files) and the V1 `Button` users (64 files) are the big blocks, along with the ~271 hand-styled raw `<button>`s and ~20 hand-rolled overlays.
- **Bridges:** do temporary adapters rebuild V1 `Button` and `ModalTemplate`/`ModalConfirmCancel` on the design system so the contrast and a11y fixes land everywhere at once, or does each screen move one by one? This pulls against dashV2's old "nothing in V1 changes".
- **The guard test's first ratchet baseline** (counts for deprecated colors, sizes, arbitrary values, banned imports, frozen folders) and how the counts go down (per PR, per phase).
- When `dashV2/tokens.ts` is deleted, when MUI / PrimeReact / headlessui / tailwind-variants / react-icons / heroicons / radix-icons / react-loading-skeleton / react-spinners leave `package.json`, and how retired legacy colors (including the 8 `logo*`) are rewritten to their nearest steps.
- Whether codemods help (for example `text-gray-500` → `text-muted-foreground`, react-icons → lucide), and how each phase is verified (Storybook, vitrine screenshots, homologation).
- How the work is sliced into issues/PRs for volunteers.

## Resolution

Decided in a grilling session on 2026-10-28.

- **One PR for everything.** About **519 of 1,327** non-test source files have something the design system replaces, and all of it lands in a single PR against `develop`.
  - Context: `develop` had 362 commits from 2 authors in the last 30 days, so coordination is easy.
  - Splitting by layer or by screen was recommended and rejected.
  - **No bridges.** V1 `Button` and `ModalTemplate`/`ModalConfirmCancel` are replaced at every call site, so the "adapter vs screen-by-screen" question no longer exists.
  - **All retired dependencies leave `package.json` in the same PR:** MUI (except what `@mui/x-charts` needs), PrimeReact, headlessui, tailwind-variants, react-icons, heroicons, `@radix-ui/react-icons`, react-loading-skeleton, react-spinners.
  - **The guard test is strict (zero deprecated uses) from the moment the PR merges.** It never ratchets on `develop`.
- **Structure:** **ordered commits, one per step. Every commit builds and passes the tests on its own.** The PR is merged with a **merge commit, not a squash**, so `git bisect` can find the step that broke something and `git revert <step>` can undo just that step.
- **Keeping up with `develop`:**
  - Branch from a fresh `develop`, **rebase daily, and re-run the codemods after each rebase**, so code written meanwhile gets swept automatically. The guard lists anything the codemods missed.
  - The two authors agree on a **2–3 day freeze of UI changes**, only for final QA and merge.
  - A long-lived integration branch and a freeze for the whole build were both rejected.
- **Commit order:**
  1. **Phase 0:** Tailwind config fix ([How tokens are structured](04-token-architecture.md)). The 302 dead classes, `animate-*` and gradients come back.
  2. **Tokens:** `src/styles/tokens.css`, the semantic Tailwind color map, `tailwind/type-scale.js`, shadows, z-index, widths, `--header-h`, Raleway 400–800 + 400 italic in `index.html`, and the shadcn variables remapped from zinc to brand.
  3. **Lint and guards:** fix ESLint (legacy `.eslintrc.cjs` → `eslint.config.js`) and add `eslint-plugin-jsx-a11y`, added after this ticket closed, per [Written guidelines](13-written-guidelines.md). Violations are resolved in the component-family commits, so jsx-a11y starts as warnings in the branch and becomes errors at cleanup. Plus the **guard + contrast tests** in `src/design-system/`. Inside the branch the guard runs in **ratchet mode**, with today's counts as the baseline, so each later commit can lower them and still pass.
  4. **Storybook:** `.storybook/` setup (decorators, toolbars, VitePWA filtered) and the MDX foundation pages.
  5. **`ui` components**, restyled and new, each with its required stories ([Core components visual prototype](10-core-components-prototype.md)), including `DataTable`, `StatusBadge` and `DateRangePicker` moved from dashV2.
  6. **Codemod sweeps, one commit each:** colors → semantic tokens, sizes → type steps, arbitrary values (`[#hex]`, `text-[Npx]`, `p/m/gap-[Npx]`, `z-[N]`), radius/shadow/z-index, icons → lucide.
  7. **Component families, one commit each:** V1 `Button`; `ModalTemplate`/`ModalConfirmCancel` → Dialog/AlertDialog; V1 `Text` → step classes; MUI by family (Typography, Button/IconButton, TextField, Tooltip, Chip, loaders, Table/Paper); **one commit per DataGrid screen → `DataTable`**; PrimeReact `Calendar`/`Dropdown` → DatePicker/Select; headlessui menu → DropdownMenu; react-loading-skeleton/react-spinners → Skeleton/Spinner; react-toastify config and CSS.
  8. **dashV2 split:** the template, toolbar, filter bar and footer use `ui`, and `dashV2/tokens.ts` and its test are deleted (absorbed into the guard).
  9. **Home expressive layer**, per [Expressive layer for the home page](14-home-expressive-layer.md).
  10. **Cleanup:** delete the V1 kit files and `scripts/ds-codemods/`, remove the dependencies, switch the **guard to strict (zero)** and **jsx-a11y to errors**, and freeze the atomic folders.

  Sweeps go before component families on purpose. They are mechanical and re-runnable after each rebase, while the hand-written family commits are the ones most likely to conflict, so they come later, closer to the freeze.
- **Codemods:**
  - The **spec contains a mapping table** (every legacy class → its new token or step), so the decisions are documented, not buried in a script.
  - The codemod applies the **unambiguous rows** automatically (grays → `muted-foreground`/`border`/`muted`/`page`, brand names → semantic tokens, `text-*` sizes → steps, …).
  - **Ambiguous** uses get a `/* ds-review */` marker and keep the old class. Examples: `blue-*` (link vs info vs decoration), `amber-*` (warning vs decoration), `gray-400` (placeholder vs disabled), `rose-*`/`fuchsia-*`. They are resolved by hand in the sweep commit, and **the guard fails while any marker remains**.
  - The scripts live in **`scripts/ds-codemods/`** and are deleted in the cleanup commit.
  - Pure color-distance mapping and fully manual rewrites were both rejected.
- **Verification before merge:**
  1. **CI:** `tsc`, lint, Vitest (guard, token-contrast, `composeStories` smoke tests, existing suites), `build-storybook`, `vite build`.
  2. **Visual before/after:** a script screenshots **every `/dev/vitrine` state** at 390 and 1280 on `develop` and on the branch, and the pairs are reviewed side by side. Storybook covers the components themselves.
  3. **Homologation:** during the freeze, the branch is deployed and a **checklist of key flows** is walked:
     - **student:** inscription steps, taking a simulado, simulation history, account;
     - **admin:** provas list, question editor, class and attendance (the old DataGrid screens), enrollment manager, analytics;
     - **public:** home, cursinho map and registration, login.

     The checklist is written once and kept for reuse.
- **Scope rule: parity plus the decided improvements, nothing else.** Screens keep their features and flows. The only behavior changes are the ones the design system decided: accessibility (focus trap, Esc, labels, `aria-*`, required markers), toast timing, mobile cards, full-screen dialogs and 44px touch targets. **Bugs found along the way are logged as issues, not fixed in the PR**, unless the swap itself fixes them (for example the dead classes). **Existing tests are adapted, never deleted**, including the DataGrid screens' tests (`chamada.test.tsx`, `permissoesDaTurma.test.tsx`, …) with their behavior assertions intact.
- **Rollback:** `git revert -m 1 <merge>` for the whole change, or `git revert` of a single step commit.
- **Release:** the normal flow after homologation sign-off, with a short "what changed" note for cursinho coordinators, since every screen looks different.

