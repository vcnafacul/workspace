# Research 01: current UI inventory of `client-vcnafacul`

- **Ticket:** [tickets/01-ui-inventory.md](../planejamento/01-ui-inventory.md)
- **Source:** `origin/develop` @ `bdb34525c8895437abecf5df1449bad4468c5568` ("Merge pull request #948", 2026-10-20). This was read on 2026-10-28 without changing the local checkout.
- **Primary sources:** the repo itself. That means `tailwind.config.js`, `src/index.css`, `src/styles/*.css`, `index.html`, `package.json`, `src/routes/PlatformRoutes.tsx`, `src/components/**` and `src/pages/**`. Tailwind's config-merge behaviour was checked by compiling with the repo's own `tailwindcss@3.4.19` (see §1.3).

---

## 0. Most decision-relevant facts

1. **Brand palette, Tailwind palette and shadcn tokens are three separate color systems.** Across `.ts/.tsx` there are **1,918** brand or shadcn-named color classes and **1,967** Tailwind-default palette classes (`gray-500`, `blue-600`, `red-600`, …), plus **42** arbitrary `[#hex]` classes and **~288** raw hex literals (charts, inline styles, CSS). The dash uses more Tailwind-default color (1,417) than brand color (839).
2. **302 color classes in 81 files render nothing.** `tailwind.config.js` sets `red`, `orange`, `yellow`, `green`, `pink` and `purple` as *flat strings* inside `theme.extend.colors`. That replaces Tailwind's whole scale, so `text-red-600`, `bg-green-50`, `bg-orange-100` and the rest produce no CSS. The same file defines `theme.keyframes`, `theme.animation` and `theme.backgroundImage` *outside* `extend`, which removes `animate-spin` (28 uses), `animate-pulse` (20, including shadcn `Skeleton`), `animate-ping` (2) and `bg-gradient-to-*` (24). All of these were verified by compiling.
3. **There are 3 or more implementations of every component kind.** For example, the button has 4 (V1 `molecules/button` in 64 files, shadcn `ui/button` in 61, MUI `Button` in 28, and 271 raw `<button>` elements), and the modal has 7. V1 `molecules/button` defaults to `primary` = **white on `#FF7600`** (2.68:1). That covers 77 of its 122 call sites.
4. **The shadcn layer has no brand.** Its CSS variables are the default zinc. `ui/button` `variant="outline"` (56) is the most-used button variant in the app. Brand color shows up only through ad-hoc `className` overrides such as `bg-orange text-white`.
5. **MUI runs without a `ThemeProvider` and PrimeReact runs on a global `md-light-indigo` theme.** That means 63 MUI files render in MUI's default blue (`#1976d2`) with Roboto→Helvetica/Arial, not Raleway: `Typography` ×153, `Button` ×54 and `DataGrid` ×8. They are almost entirely in the dash (56 of 63 files). PrimeReact is used only for `Calendar` (10 files) plus one `Dropdown`.
6. **dashV2 is already the de-facto seed.** All nine admin list screens render `<DashListTemplate>`, and `templates/dashCardTemplate` now has **0** users. dashV2 is built from **shadcn/Radix primitives** (`ui/popover`, `ui/tooltip`, `ui/table`, `ui/pagination` via `paginationWrapper`) restyled through `dashV2/tokens.ts`. It also has a vitest "palette ratchet" (`dashV2/tokens.test.ts`), which is precedent for lint-style guards.
7. **Typography is effectively `text-sm`/`text-xs`** (1,301 of 1,744 size classes) at `font-semibold`/`medium`/`bold`. `leading-*` is almost never set (68 uses). Raleway is loaded 300–700, but `font-black` (27) and `font-extrabold` (26) are used, so those are synthesized.
8. **The common spacing, radius and shadow values are few.** Spacing clusters on `2/3/4/6` (padding 4 = 540, gap 2 = 503), radius on `md` (281), `lg` (264) and `full` (167), and shadows on `sm/md/lg/xl` (151 of 189). About 124 distinct arbitrary `w/h/max-*` values are mostly modal sizes.
9. **Icons come from 4 libraries and 21 import roots.** lucide is in 90 files, react-icons in 71 (17 sub-packs, with `fi`, `md`, `fa` and `io5` leading), heroicons in 14 (dash only, mostly `dashProvas`), Radix icons in 6 (inside shadcn), and 53 local SVGs (`assets/icons`, used mainly in public/home). lucide is the only set used in every area.

---

## 1. Methodology (reproducible)

**Areas.** Each file under `src/pages/<dir>/` is classified by its route in `src/routes/PlatformRoutes.tsx`:

| Area | `src/pages/<dir>` | Page files (non-test) |
|---|---|---|
| **public** (home/site, auth, public flows) | `homeV2 homeLegacy newsPage quemSomos login forgot reset register cadastroGoogle googleRetorno conviteColaborador confirmEnrolled enrollmentConfirmation partnerPrepInscription paginaCursinhoPublica confirmEmail logout Geo geoSearch` | 98 |
| **student** (inside `DashTemplate`, no permission gate) | `dashboard mainSimulate simulate simulationHistories simulationHistory materia subject account essayWrite essayResult essayHistory support` | 68 |
| **dash** (admin and partner screens, `ProtectedRoutePermission`) | everything else, e.g. `dashProvas dashQuestionNew dashContent dashGeo dashNews dashPush dashRoles dashHome partner* managerCollaborator studentsEnrolled analytics indicadoresCursinho relatorioSimulado globalForm registrationMonitor essayThemeAdmin essayReview* essayViewDetail paginaCursinhoEdicao admin dash` | 339 |
| dev | `devVitrine` (dev-only route) | 22 |

**Shared components are attributed by reach.** I built the static import graph (`import … from`, `import()`, `@/` alias plus relative paths). Each `src/components/**` file is labelled with the set of page areas that reach it transitively. The seeds are `routes/baseRoutes.tsx` and `heroRoutes.tsx`, which count as public, and `templates/dashTemplate`, which counts as student and dash. A component reached from one area counts toward that area. One reached from several areas is **shared**. **Unreached** means it is only used from `App.tsx`/`main.tsx` (chat widget, cookie bar, …) or not used at all. Tables below show `public / student / dash / shared / unreached / dev`.

**Exclusions:** `*.test.*`, `*.spec.*` and `semComponenteNoRender.test.ts`. Comments are *not* stripped, which causes a small amount of over-counting.

**Regexes** (Python, run over a `git archive origin/develop src` extract):

- Named color class: `(variant:)*(bg|text|border(-[trblxyse])?|ring(-offset)?|fill|stroke|from|via|to|outline|divide|placeholder|decoration|shadow|accent|caret)-(<config color name>|transparent|current)(/opacity)?`
- Tailwind palette class: same prefixes followed by `-(slate|gray|…|rose)-\d{2,3}`
- Arbitrary color class: same prefixes followed by `-\[(#hex|rgba?(…)|hsla?(…))\]`
- Raw hex: `#[0-9a-f]{3|6|8}` preceded by a quote, space, `:`, `(` or `,`, excluding those already inside an arbitrary class

Equivalent `git grep` spot checks (all counts use `':!*.test.*'`):

```sh
R=origin/develop
git grep -l  -e "from ['\"]react-toastify" $R -- src ':!*.test.*' | wc -l        # 130
git grep -l  -E "components/ui/button[\"']" $R -- src ':!*.test.*' | wc -l        # 61
git grep -lE "(bg|text|border|ring|from|to|via|fill|stroke|divide|outline|placeholder)-(red|orange|yellow|green|pink|purple)-[0-9]{2,3}" $R -- src ':!*.test.*' | wc -l  # 81 files / 302 hits with -o
git grep -oE "animate-(spin|pulse|ping)" $R -- src ':!*.test.*' | wc -l           # 50
git grep -lE "<DashListTemplate($|[ /><])" $R -- src/pages ':!*.test.*'          # 9 screens
```

*Note on the map's survey numbers:* the map lists `react-toastify` as 194 files and `molecules/button` as 65. Excluding tests, I count **130** files with `from "react-toastify"` (367 `toast.*` calls) and **64** importers of `molecules/button`. The `@/components/ui/*` figure of 138 against my 133 is the same kind of gap: tests, and ui files importing each other.

---

## 2. Color

### 2.1 What is defined

| Source | Content |
|---|---|
| `tailwind.config.js` `extend.colors` (flat) | `white #FFFFFF`, `backgroundGrey #F8F8F8`, `lightGray #E0E0E0`, `grey #707070`, `darkGrey #545454`, `gray2 #A6A6A6`, `black #000000`, `marine #0B2747`, `backgroundMarine #001228`, `orange #FF7600`, `darkOrange #FC8621`, `yellow #FFE53C`, `lightYellow #fff4af`, `pink #DA005A`, `green #37D6B5`, `lightGreen #8cc408`, `darkGreen #0f9b2c`, `green2 #0F9B2C`, `green3 #19982B`, `red #F43535`, `redError #ff0000`, `purple #8A2BE2`, `blueGeo #4D8CCB`, `logoCursinho #E05C1A`, `logoProjeto #5B3F9E`, `logoAdmin #00A69C`, `logoLinguagens #D61F69`, `logoNatureza #1B3A5C`, `logoHumanas #3BAD5A`, `logoMatematica #7CB800`, `logoEstudos #F0B400` |
| `tailwind.config.js` shadcn block | `background foreground card popover primary secondary muted accent destructive border input ring chart-1..5 sidebar-*`, all `hsl(var(--x))` |
| `src/index.css` `:root` / `.dark` | Stock shadcn **zinc** values (`--primary: 240 5.9% 10%`, `--ring: 240 10% 3.9%`, `--radius: .5rem`). The `.dark` block exists, but `darkMode: ["class"]` is never toggled. |
| `src/styles/sectionThemes.css` | `[data-theme=marine\|pink\|green\|yellow\|neutral]` → `--section-bg/fg/accent/accent-soft`. It adds `#fff5f8`, `#edfef8` and `#f7b733`, none of which are in the config. |
| `tailwind.config.js` `backgroundImage` | `custom-gradient` (green→lightGreen→yellow→orange→pink) and `right-gradient` (white→`#0F9B2C`) |
| `src/pages/dashboard/theme.ts` | `chartColors` for Recharts: marine, green, orange, red, plus `#E2E8F0`, `#94A3B8` and `#EEF2F6` (Tailwind slate values) |
| `src/components/dashV2/tokens.ts` | Role map over config names: surface, page, border, text.{primary,secondary,muted}, invalid, action.{primary,secondary,ghost,destructive,menuItem,destructiveGhost}, focus, row, progress, status.{done,running,missing,info,neutral}.{chip,dot,icon} |

### 2.2 Brand and shadcn named classes: usage by area

These are class occurrences in non-test `.ts/.tsx` files, 1,918 in total.

| Color | Uses | Files | public | student | dash | shared | unreached | dev |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| white | 498 | 253 | 75 | 78 | 238 | 93 | 11 | 3 |
| **marine** | 467 | 180 | 37 | 128 | 234 | 56 | 9 | 3 |
| grey | 173 | 73 | 19 | 34 | 90 | 30 | 0 | 0 |
| **orange** | 166 | 73 | 27 | 26 | 80 | 31 | 2 | 0 |
| red | 76 | 34 | 4 | 7 | 59 | 6 | 0 | 0 |
| *muted-foreground* | 68 | 32 | 1 | 7 | 49 | 6 | 5 | 0 |
| *primary* | 59 | 23 | 0 | 10 | 40 | 9 | 0 | 0 |
| transparent | 50 | 36 | 9 | 5 | 19 | 17 | 0 | 0 |
| green2 | 48 | 22 | 5 | 8 | 33 | 2 | 0 | 0 |
| black | 37 | 33 | 8 | 4 | 17 | 7 | 1 | 0 |
| lightGray | 24 | 16 | 0 | 4 | 16 | 4 | 0 | 0 |
| green | 18 | 13 | 3 | 5 | 3 | 7 | 0 | 0 |
| *sidebar-** (all) | 50 | 1 | 0 | 0 | 0 | 50 | 0 | 0 |
| pink | 15 | 8 | 0 | 4 | 5 | 6 | 0 | 0 |
| *background / foreground* | 26 | 16 | 0 | 3 | 11 | 12 | 0 | 0 |
| *muted* | 13 | 9 | 0 | 0 | 12 | 1 | 0 | 0 |
| backgroundGrey | 13 | 8 | 0 | 0 | 7 | 6 | 0 | 0 |
| green3 | 12 | 7 | 1 | 2 | 7 | 2 | 0 | 0 |
| *ring / input / border* | 22 | 21 | 0 | 1 | 10 | 11 | 0 | 0 |
| redError | 8 | 4 | 1 | 0 | 7 | 0 | 0 | 0 |
| lightGreen | 8 | 4 | 0 | 7 | 1 | 0 | 0 | 0 |
| darkGrey | 7 | 5 | 0 | 0 | 5 | 2 | 0 | 0 |
| *destructive(-fg)* | 8 | 5 | 0 | 0 | 0 | 6 | 2 | 0 |
| *secondary(-fg), accent(-fg), popover(-fg), card(-fg), primary-foreground* | 25 | — | 0 | 0 | 5 | 20 | 0 | 0 |
| darkOrange | 5 | 4 | 0 | 1 | 2 | 2 | 0 | 0 |
| lightYellow | 3 | 3 | 0 | 2 | 1 | 0 | 0 | 0 |
| darkGreen | 3 | 2 | 0 | 0 | 3 | 0 | 0 | 0 |
| blueGeo | 3 | 1 | 0 | 0 | 3 (dashV2 tokens) | 0 | 0 | 0 |
| gray2, purple, yellow | 1 each | 1 | | | | | | |
| logo* (8 colors) | 1 each | 1 | 0 | 0 | 1 | 0 | 0 | 0 |
| backgroundMarine | 0 | 0 | | | | | | |

Notes:
- `backgroundMarine` and the bare `yellow`, `purple` and `gray2` are effectively unused as classes. `yellow` appears in `custom-gradient`, charts and `sectionThemes.css`.
- The `logo*` colors appear in exactly one file each, as class strings. They are area colors for logos, not UI.

### 2.3 Tailwind default palette: 1,967 uses, and 302 of them dead

| Family | Uses | public | student | dash | shared | Renders? |
|---|---:|---:|---:|---:|---:|---|
| gray | 1,086 | 92 | 81 | 853 | 33 | yes. This is the de-facto neutral in the dash, used alongside brand `grey` (#707070) |
| slate | 175 | 20 | 61 | 70 | 24 | yes |
| blue | 170 | 24 | 17 | 119 | 7 | yes. Blue is not a brand color, but it is used in `dashQuestionNew`, `dashProvas`, `studentsEnrolled` and `confirmEnrolled` |
| **red** | 132 | 20 | 5 | 100 | 6 | **no** |
| amber | 96 | 3 | 3 | 88 | 2 | yes |
| **green** | 87 | 11 | 9 | 65 | 2 | **no** |
| rose | 54 | 0 | 10 | 42 | 2 | yes |
| **yellow** | 39 | 9 | 5 | 25 | 0 | **no** |
| **orange** | 32 | 2 | 7 | 21 | 2 | **no** |
| fuchsia | 25 | 23 | 0 | 0 | 2 | yes (home) |
| emerald, zinc, sky, teal, indigo, lime, cyan, stone, violet | 59 | | | | | yes |
| **purple / pink** | 12 | | | | | **no** |

The most frequent shades are `gray-500` (208), `gray-600` (164), `gray-700` (131), `gray-200` (114), `gray-400` (101), `gray-100` (99), `gray-50` (98), `gray-300` (89) and `red-600` (49, dead).

**Why they're dead (verified).** `theme.extend.colors.red = "#F43535"` is a string, and Tailwind's `mergeExtensions` replaces a default object scale with a string. Running `resolveConfig` with tailwindcss 3.4.19 gives `typeof colors.red === "string"`. I compiled `text-red-600 bg-green-50 text-orange-500 text-yellow-50 animate-spin animate-pulse bg-gradient-to-r` against the config shape and **none produced CSS**. `bg-red`, `text-gray-500`, `bg-amber-50` and `animate-rotate` did. The dead uses split as public 43, student 27, dash 217, shared 14 and unreached 1, across **81 files**. Some of them are in shadcn-on-top overrides, for example `Badge className="bg-green-600"` and `Button className="text-red-600 hover:bg-red-50"`.

### 2.4 Arbitrary color classes: 42 uses, 9 values

| Value | Uses | Files | Area | Where |
|---|---:|---:|---|---|
| `#0b2747` (= marine) | 12 | 8 | public | `homeV2/sections/*`, `geoSearch/components/FiltroGaveta.tsx` |
| `#37d6b5` (= green) | 11 | 7 | public | `homeV2/sections/{About,Features,Hero}*` |
| `#da005a` (= pink) | 5 | 5 | public | `homeV2/sections/{Features,Hero,News}*` |
| `#b35300` (dark orange text, 5.06:1) | 4 | 4 | student 2 / dash 2 | `dashboard/components/KpiCard.tsx`, `dashboard/widgets/ProcessosTable.tsx`, `indicadores/CardDeMetrica.tsx` |
| `#0d7a63` (dark teal text, 5.27:1) | 4 | 3 | student 3 / dash 1 | `dashboard/components/KpiCard.tsx`, `dashboard/widgets/MeuCursinho.tsx`, `indicadores/CardDeMetrica.tsx` |
| `#f7b733` (sectionThemes yellow) | 2 | 2 | public | `homeV2/sections/{News,Sponsors}*` |
| `#2bbfa1` (darker green) | 2 | 2 | public | `homeV2/sections/{About,PrepCourses}*` |
| `#da005a22` | 1 | 1 | public | `homeV2/sections/VolunteersSection` |
| `#001b3a` (≈ backgroundMarine) | 1 | 1 | public | `homeV2/sections/HeroSection/HeroTriptych.tsx` |

34 of the 42 are in public (homeV2). Most of them restate config colors in hex. The student dashboard's `#b35300` and `#0d7a63` are new AA-text shades of orange and green that nobody has formalized yet.

### 2.5 Raw hex literals outside classes: ~288 uses, 110 values

By location: dash 93, CSS files 64, student 51, shared 34, public 29, unreached 14 and dev 3. About 92 of the TS hits are in chart files. Notable clusters:

| Cluster | Values | Files |
|---|---|---|
| Chart palettes (nivo, MUI x-charts, Recharts, chart.js) | `#ff7600 #37d6b5 #0b2747 #da005a #0f9b2c #ffe53c #8cc408` (brand); `#48c9b0 #5dade2 #f7dc6f #eb984e #a9dfbf #f9e79f #d35400 #ba4a00 #52be80` (flat-UI palette in `atoms/pieChartMui`, `atoms/barChartMuiFilter`, `organisms/renderCharts`); `#2e96ff #02b2af #b800d8 #60009b #2731c8 #03008d` (MUI x-charts default palette in `atoms/lineChartMui`, `molecules/essayEvolutionChart`, `essayHistory/*`); `#64748b #f87171 #4ade80 #fbbf24 #667eea #764ba2` (`simulationHistories/components/performanceChart.tsx`, `organisms/simulationHistoryHeader`) | ~20 |
| Tailwind hexes hard-coded in TS | `#3b82f6` (11), `#6b7280`, `#d1d5db`, `#f97316`, `#dc2626`, `#e5e7eb`, `#9ca3af`, `#fdba74`, `#93c5fd`, … | `atoms/permissionToggle/PermissionToggle.tsx`, `dashRoles/modals/ModalRole.tsx`, `managerCollaborator/modals/*`, `dashProvas/modals/newProva.tsx` |
| Map pins | `#707070` ×9 | `organisms/mapBoxInfo/mapBoxInfoGeo.tsx` |
| Skeleton theme | `#222`, `#64646426` | `organisms/*Skeleton` (react-loading-skeleton) |
| Component CSS | `#007bff #b6b6b6 #a7a7a7 #d9d9d9 #636363` | `pages/partnerPrepInscription/steps/styles.css` |
| | `#10b981 #f0fdf4 #bbf7d0 #dbeafe …` | `molecules/uploadButton/style.css` |
| | (various) | `molecules/selector/styles.css`, `atoms/docxPreview/style.css`, `organisms/aboutUs|actionAreas|features/styles.css` |
| One-off home values | `#8dc63f #d96b45 #d9af45` | `quemSomos/NossosValores.tsx` |

### 2.6 Color mix by area

Counted in class occurrences.

| Area | Brand names | Tailwind default | shadcn semantic | Arbitrary | Dead classes |
|---|---:|---:|---:|---:|---:|
| public | 190 | 209 | 1 | 34 | 43 |
| student | 316 | 203 | 21 | 5 | 27 |
| dash | 839 | **1,417** | 127 | 3 | **217** |
| shared components | 273 | 107 | 115 | 0 | 14 |

The dash relies most on the Tailwind defaults. Its biggest consumers are `dashQuestionNew` (169 gray/slate), `dashProvas` (127), `partnerPrepManager` (71), `studentsEnrolled` (60) and `managerCollaborator` (52). Public is the only area with arbitrary hex. The student area leans most on brand (`marine` 128).

### 2.7 Duplicates and near-duplicates

Contrast is measured against white with the WCAG 2.x formula.

| Group | Members | Notes |
|---|---|---|
| Dark green | `green2 #0F9B2C` = `darkGreen #0f9b2c` (**exact duplicate**), `green3 #19982B`, `right-gradient #0F9B2C`, plus dead `green-*` classes | 3.66 / 3.77:1. `green2` gets 48 uses, `darkGreen` 3, `green3` 12 (dashV2 `done` uses `green3`). |
| Teal/mint | `green #37D6B5` (1.83:1), `#2bbfa1` (2.32), `#0d7a63` (5.27), `logoAdmin #00A69C`, `#48c9b0`, `#02b2af` | The brand "green" is a mint. Its AA text shade exists only as an arbitrary hex. |
| Light green / lime | `lightGreen #8cc408`, `logoMatematica #7CB800`, `#8dc63f`, `logoHumanas #3BAD5A` | |
| Red | `red #F43535` (3.88), `redError #ff0000` (4.0), `destructive` (zinc-theme `0 84% 60%` ≈ `#ef4444`), hex `#dc2626 #ef4444 #f87171`, plus 132 dead `red-*` classes | Three live reds and one dead scale. |
| Orange | `orange #FF7600` (2.68), `darkOrange #FC8621` (2.45, **lighter than "orange" despite the name**), `logoCursinho #E05C1A` (3.67), `#b35300` (5.06), `#f97316`, `#d35400`, plus dead `orange-*` | No AA-text orange token. |
| Yellow | `yellow #FFE53C`, `lightYellow #fff4af`, `#f7b733` (sectionThemes), `logoEstudos #F0B400`, `#fbbf24`, `#f59e0b`, plus dead `yellow-*`, live `amber-*` (96) | `amber` is the de-facto "warning" in the dash. |
| Navy | `marine #0B2747`, `backgroundMarine #001228` (0 class uses), `#001b3a`, `logoNatureza #1B3A5C` | |
| Pink | `pink #DA005A` (5.09), `logoLinguagens #D61F69`, live `rose-*` (54), `fuchsia-*` (25, home) | |
| Neutral grays | `grey #707070` (4.95), `gray-500 #6b7280` (4.83), `darkGrey #545454`, `gray2 #A6A6A6` (2.43), `lightGray #E0E0E0` = hex `#e0e0e0`, `backgroundGrey #F8F8F8`, zinc shadcn vars, `slate-*` (175), `gray-*` (1,086) | Five overlapping neutral systems. |
| Blue | `blueGeo #4D8CCB` (3.54), `blue-*` (170), `#3b82f6` (11 hex), `#2563eb`, `#007bff`, `#2e96ff`, MUI primary `#1976d2`, PrimeReact indigo | There is no brand blue, yet blue is widespread. |
| Purple | `purple #8A2BE2`, `logoProjeto #5B3F9E`, `#667eea`/`#764ba2` (gradient) | |

---

## 3. Typography

**Family.** `font-raleway` is applied once on the root wrapper (`src/main.tsx`). Google Fonts loads Raleway at **300–700** (`index.html`). There are 8 uses of `font-mono` and 5 of `font-raleway` as classes. **MUI components have no theme**, so they use MUI's default `"Roboto","Helvetica","Arial"`. Roboto is not loaded, so they fall back to Helvetica/Arial. That affects every MUI `Typography`/`Button`/`TextField` (dash).

**Sizes** (1,744 uses):

| Class | Uses | public | student | dash | shared |
|---|---:|---:|---:|---:|---:|
| text-sm | 888 | 53 | 98 | 679 | 44 |
| text-xs | 413 | 19 | 41 | 324 | 26 |
| text-lg | 120 | 16 | 17 | 73 | 12 |
| text-base | 97 | 31 | 9 | 39 | 16 |
| text-2xl | 72 | 14 | 10 | 43 | 3 |
| text-xl | 54 | 7 | 7 | 32 | 6 |
| text-3xl | 40 | 20 | 7 | 11 | 1 |
| text-5xl | 14 | 10 | 3 | 0 | 1 |
| text-4xl | 10 | 6 | 2 | 1 | 1 |
| text-[10px] | 12 | 3 | 0 | 6 | 3 |
| text-[11px] | 10 | 1 | 0 | 2 | 5 |
| one-offs | `text-[28px]` ×3 (KPI numbers), `[150px]` ×2 (success icons), `[0.8rem]` ×2 (ui/form), `[0.65rem]`, `[9px]`, `[6rem]`, `[8rem]`, `6xl`, `7xl`, `8xl` (homeV2 hero) | | | | |

**Weights** (921): semibold 365, medium 280, bold 190, normal 28, **black 27**, **extrabold 26** (22 of them in public/homeV2), thin 4, light 1. Weights 800 and 900 are not loaded.

**Line height** is set only 68 times: tight 23 (17 public), none 15, relaxed 12, snug 4, numeric `leading-6/7/8/9/10` (mostly `atoms/text`) and `[1.05]` (hero). **Tracking**: wide 20 (dash table headers), widest 7, tight 4, wider 2, `[0.18em]` 1. `sectionThemes.css` `.home-section__eyebrow` uses 11px / 600 / `.18em` / uppercase.

**Heading components:**

| Implementation | Path | Files / uses | Variants |
|---|---|---|---|
| V1 `Text` | `components/atoms/text/index.tsx` | 60 / 102 (public 24, student 9, dash 19, shared 7) | `size`: primary `text-4xl md:text-5xl font-bold leading-10` (4); **secondary** `text-3xl font-bold leading-9` (51); tertiary `text-base md:text-xl` (26); quaternary `text-sm md:text-lg` (16); default→primary (5). The base is `text-marine mb-6 text-center` and renders a `<div>`, not `h*`. |
| MUI `Typography` | `@mui/material` | 26 files / 154 | body2 51, caption 26, h6 25, h4 13, h5 9, body1 7, subtitle2 7, subtitle1 5, h3 1. Dash and student only. |
| shadcn `CardTitle` / `DialogTitle` / `SheetTitle` | `components/ui/*` | 22 / 13 / 3 uses | `font-semibold leading-none tracking-tight` |
| Raw `h1`–`h4` | — | h1 50, h2 71, h3 56, h4 9 | Styled ad hoc. |

---

## 4. Spacing, radius, shadows, borders

**Padding** (2,107): `4` 540, `2` 486, `3` 368, `6` 204, `1` 158, `8` 60, `5` 46, `1.5` 39, `0.5` 37, `10` 36, `0` 32, `12` 25, `2.5` 22. One-offs: `7`, `9`, `14`, `16`, `20`, `24`, `28`, `32`, `40`, `3.5`, and `[48px] [52px] [56px] [96px]` (all in `partnerPrepInscription/steps/partnerPrepInscriptionStepForm.tsx`).

**Margin** (994): `2` 184, `1` 170, `4` 164, `auto` 134, `3` 69, `6` 63, `0.5` 47, `0` 45, `10` 44, `8` 27. One-offs: `28`, `32`, `34`, `44`, `[4%]`.

**Gap / space-*** (1,384): `2` 503, `4` 293, `3` 237, `1` 182, `6` 64, `1.5` 40, `8` 20, `0.5` 14, `5` 11. Large gaps (`12–32`) appear only in homeV2.

So in practice the scale is **0.5, 1, 1.5, 2, 3, 4, 6, 8**. Values of 10 and above belong to page and section layout, mostly on public.

**Radius** (957). `--radius: .5rem` drives shadcn `lg/md/sm` (8/6/4 px, so `rounded-sm` is 4px rather than Tailwind's 2px).

| Class | Uses | public | student | dash | shared |
|---|---:|---:|---:|---:|---:|
| rounded-md | 281 | 25 | 10 | 215 | 28 |
| rounded-lg | 264 | 17 | 49 | 191 | 6 |
| rounded-full | 167 | 25 | 30 | 74 | 35 |
| rounded (4px) | 126 | 20 | 15 | 82 | 4 |
| rounded-2xl | 41 | 19 | 9 | 9 | 4 |
| rounded-xl | 30 | 2 | 6 | 18 | 3 |
| rounded-sm | 23 | 1 | 2 | 15 | 5 |
| corner one-offs (`rounded-bl-3xl`, `rounded-tl-3xl`, `rounded-3xl`, `rounded-r-2xl`, …) | 22 | mostly public | | | |

**Shadows** (189): `shadow-lg` 45, `shadow-md` 42, `shadow-sm` 34, `shadow-xl` 30 (26 of them dash modals), `shadow` 23 (22 in shadcn `ui/*`), `shadow-2xl` 4, `shadow-none` 4, `shadow-inner` 1. The arbitrary `shadow-[0_1px_2px_rgba(11,39,71,0.04)]` ×3 is a marine-tinted shadow in the student dashboard (`dashboard/components/{KpiCard,Panel}.tsx`). Two more are in `ui/sidebar.tsx`, plus `shadow-[inset_3px_0_0_theme(colors.marine)]` (`molecules/subDashCard`). dashV2 explicitly prefers 1px borders over shadows.

**Border width** (602): `border` 397, `border-t` 49, `border-2` 42 (V1 buttons), `border-b` 40, `border-0` 18, `border-l-4` 14 (callouts), with `border-8` and others as one-offs. **Ring**: `ring-2` 42, `ring-1` 12. Focus rings are inconsistent: shadcn `ring-ring` (zinc), V1 `outline-orange` or `focus-visible:ring-orange`, `atoms/select` `ring-blue-500/30`, and dashV2 `ring-orange/40`.

**Arbitrary sizes.** There are 124 distinct `w/h/min/max-[…]` values (365 uses), mostly modal and container sizes: `[500px]` 29, `[90vw]` 16, `[calc(100%-2rem)]` 15, `[90vh]` 15, `[600px]` 12, `[calc(100vh-76px)]` 10 (header height 76/88 px). `max-w-*` is spread across `md…6xl`.

**Breakpoints** are custom: `sm 768 / md 1200 / lg 1400 / xl 1565`, replacing Tailwind's defaults. dashV2 has `useAcimaDeSm` (27 importers) for a JS-side `sm`.

---

## 5. Components

### 5.0 Library footprint

These are importing files, excluding tests.

| Library | Files | public | student | dash | shared | Theme |
|---|---:|---:|---:|---:|---:|---|
| shadcn `@/components/ui/*` | 133 | 4 | 9 | 40+ | 14 | zinc CSS vars (unbranded) |
| V1 kit (`atoms/molecules/organisms/templates`) | — | heavy | medium | heavy | — | Brand config names with `tailwind-variants` (`tv`) in `molecules/button`, `atoms/text`, `atoms/input` |
| `@mui/material` | 63 | 2 | 4 | 56 | 1 | **none** (default blue, Roboto stack) |
| `@mui/x-data-grid` / `@mui/x-charts` | 10 / 8 | 0 / 0 | 0 / 2 | 10 / 5 | 0 / 1 | none |
| `primereact` | 13 | 1 | 0 | 8 | 3 | global `primereact/resources/themes/md-light-indigo/theme.css` in `main.tsx` |
| `@headlessui/react` | 1 | — | — | — | 1 (`atoms/dropdownMenu`) | — |
| `react-toastify` | 130 | 19 | 17 | 87 | 4 | `theme="colored"` (library default colors), `App.tsx` |
| dashV2 (`@/components/dashV2`) | 45 (50 with direct imports) | 0 | 7 (`useAcimaDeSm` only) | 45 | — | `dashV2/tokens.ts` |
| react-loading-skeleton / react-spinners | 6 / 1 | 0 / 1 | 0 | 0 | 6 / 0 | hex `#222`/`#646464` |
| Charts: nivo 4, chart.js 1, recharts 5, MUI x-charts 8 | — | | | | | each with its own palette (out of scope except colors) |

Where MUI concentrates (files): `partnerPrepForm` 12, `partnerClass` 8, `analytics` 8, `dashContent` 6, `dashProvas` 5, `partnerClassWithStudents` 5, `partnerPrepInscritionStudentManager` 4. Where shadcn concentrates: `dashQuestionNew` 21, `components/organisms` 12, `dashContent` 10, `components/chat` 7, `analytics` 6.

### 5.1 Inventory by kind

"Files" counts non-test importers and "uses" counts JSX elements. Area split is p/s/d/sh = public/student/dash/shared.

| Kind | Implementation | Path | Files / uses | Area p/s/d/sh | Variants / notes |
|---|---|---|---|---|---|
| **Button** | V1 `Button` | `components/molecules/button/index.tsx` → `atoms/buttonTemplate/index.tsx` | 64 / 122 | 17/7/34/4 | `typeStyle` × `size` (see 5.2). A `<button>` sits inside a `div` that carries `onClick`. `hover` prop is ignored. |
| | shadcn `Button` | `components/ui/button.tsx` (cva) | 61 / 140 | 4/9/40/7 | variant: **outline 56**, default (implicit 42 + explicit 12) = zinc-900 bg, ghost 17, destructive 6, secondary 2, expr 4. size: default 77, **sm 60**, lg 1, icon 1. Frequent overrides: `bg-orange text-white` ×7, `border-gray-300 text-gray-600 hover:bg-gray-100` ×5, dead `text-red-600 hover:bg-red-50` ×3. |
| | MUI `Button` | `@mui/material` (+`/Button`) | 28 / 62 | 0/1/27/0 | variant: outlined 30, contained 19, text 1. color: default 41, primary 11, success 1, error 1. size small 21. All MUI blue. |
| | MUI `IconButton` | `@mui/material` | 24 / 54 | dash | |
| | Google buttons | `atoms/googleAuthButton`, `molecules/entrarComGoogle` | 3 + 4 | public | |
| | dashV2 actions | `DashToolbar` uses `dashV2.action.*` | 9 screens | dash | primary `bg-orange text-marine` (max 1 per screen), secondary, ghost, destructive, menuItem, destructiveGhost |
| | raw `<button>` | — | 143 files / 271 | 23/38/188/13 | Hand-styled. |
| **Text input** | `InputFactory` | `organisms/inputFactory` → `atoms/inputText` (wraps `ui/input`, `h-16 pt-4 focus-visible:ring-orange`) + `templates/baseLayoutInput` (floating label `text-xs text-grey`, error `text-red`) | 22 / 102 | 4/1/15/2 | type: text 44, expr 28, select 15 (PrimeReact Dropdown), textarea 5, number 3, checkbox 3, email 2, password 2 |
| | V1 `Input` | `atoms/input/index.tsx` (tv: `erro` → dead `border-red-500`, size base/small) via `molecules/formField` | 12 files (formField) | 7/0/2/2 | |
| | `atoms/labelInput` | | 1 | | |
| | shadcn `Input` / `Textarea` / `Label` | `ui/input.tsx`, `ui/textarea.tsx`, `ui/label.tsx` | 10/12, 8/8, 8/24 | mostly dash | |
| | MUI `TextField` | | 8 / 32 | dash 7 | |
| | Date: PrimeReact `Calendar` | `primereact/calendar`, `atoms/controlCalendar` | 10 / 12 (+2) | p1/d8/sh1 | indigo theme |
| | Rich text | `molecules/richTextEditor` (tiptap) | 4 | dash | |
| | raw `<input>` / `<textarea>` | — | 72 files / 109; 18 / 20 | mostly dash | |
| **Select** | V1 `Select` | `atoms/select/index.tsx` (native `<select>`, `border-slate-200 text-slate-700 focus:ring-blue-500/30`) | 15 / 7 | dash 13 | dashV2 notes the blue focus as a known leak |
| | V1 `InputSelect` | `atoms/inputSelect` (PrimeReact `Dropdown` + `style.css`) | via InputFactory (15) | | |
| | `selectOption`, `molecules/selector` (+CSS), `molecules/seletorDeCursinho` | | 5 / 3 / 2 | | |
| | shadcn `Select` | `ui/select.tsx` (Radix) | 7 / 27 Select, 31 items | dash | |
| | MUI `Select` + `MenuItem` / `Autocomplete` | | 4 / 7, 2 / 4 | dash | |
| | raw `<select>` | — | 15 / 20 | dash 17 | |
| **Checkbox / radio** | V1 `Checkbox` | `atoms/checkbox` (custom SVG tick) | 2 / 1 | | |
| | V1 `InputCheckBox` | `atoms/inputCheckbox` (via InputFactory) | 1 | | |
| | `atoms/checkMapFilter` | | 2 | public | |
| | shadcn `Checkbox` | `ui/checkbox.tsx` (Radix) | 10 / 15 | 1/1/7/1 | |
| | MUI `Checkbox` / `FormControlLabel` | | 3 / 5; 5 / 11 | | |
| | Radio: V1 `RadioButton` | `atoms/radioButton` | 2 / 6 | p1/s1 | |
| | Radio: MUI `Radio`/`RadioGroup` | | 3 / 8 | dash | |
| | raw checkbox / radio | — | 22 / 11 | dash | |
| **Toggle / switch** | V1 `Toggle` | `atoms/toggle` (peer-checked `bg-green2`, `bg-gray-300`) | 7 / 8 | dash 6 | |
| | `PermissionToggle` | `atoms/permissionToggle` (inline hex: `#3b82f6`, `#f97316`, …) | 3 / 3 | dash | |
| | `TipoDeEnvioToggle` | `molecules/tipoDeEnvio` | 2 / 2 | dash | segmented control |
| | MUI `Switch` / `ToggleButtonGroup` | | 3 / 3; 1 / 2 | | |
| **Modal / dialog** | **V1 `ModalTemplate`** | `templates/modalTemplate/index.tsx` | **73 / 72** | 3/3/66/1 | `fixed inset-0 bg-black/65`. **No `role="dialog"`, no focus trap, no Esc.** Close is an `IoMdClose` icon with `onClick`, not a button. |
| | `ModalConfirmCancel` | `organisms/modalConfirmCancel` | 23 / 23 | dash 21 | built on ModalTemplate + V1 Button |
| | `ModalConfirmCancelMessage`, `ModalMessage` | `organisms/*` | 3, 1 | | |
| | `ModalTabTemplate` | `templates/modalTabTemplate` (own overlay `bg-black/50` + `ui/tabs`) | 2 | dash | |
| | `AlertDialogUI` | `atoms/alertDialogUI` (Radix alert-dialog) | 9 / 10 | dash 8 | |
| | shadcn `Dialog` / `AlertDialog` / `Sheet` | `ui/dialog.tsx`, `ui/alert-dialog.tsx`, `ui/sheet.tsx` | 9 / 14; 4 / 4; 4 / 4 | mixed | |
| | `atoms/modalImage`, `chat/ConfirmOpenDialog` | | 2, 2 | | |
| | hand-rolled overlays (`fixed inset-0`) | — | 20 files / 23 | 2/5/11/5 | |
| **Card** | shadcn `Card` family | `ui/card.tsx` | 17 / 123 (Card 39, Content 37, Header 24, Title 22) | dash 15 | `rounded-xl border bg-card shadow` |
| | MUI `Paper` | | 19 / 19 | dash | |
| | V1 cards | `molecules/{cardDash, dashCard, subDashCard, impactCard, studentCard, cardSimulate, simulationHistoryCard, permissionGroupCard}`, `atoms/{statCard, simpleCardColor(dead), photoStudentCard}` | statCard 4 / 28; cardDash 11; others 1–2 | mixed | |
| | Domain cards | `components/indicadores/CardDeMetrica.tsx`, `pages/dashboard/components/{KpiCard, Panel}.tsx` | | student / dash | marine shadow, `#b35300` / `#0d7a63` |
| **Table** | MUI `Table*` | `@mui/material` (+ default-path imports) | ~15 files (TableCell ×107) | dash | |
| | MUI `DataGrid` | `@mui/x-data-grid` | 8 / 8 | dash | `rowHeight 40` (matched by dashV2) |
| | shadcn `Table` | `ui/table.tsx` | 3 / 29 + via dashV2 | dash | |
| | `ShadcnTable` | `atoms/shadcnTable` | 2 / 3 | dash | |
| | `ExpandableTable` | `organisms/expandableTable` | 3 / 1 | dash | |
| | **dashV2 `DashTable`** | `dashV2/DashTable.tsx` (on `ui/table`) via `DashListTemplate` | **9 screens** | dash | sort, `row h-10`, `header h-9`, `cell px-3 text-sm` |
| | raw `<table>` | — | 20 / 21 | dash 16 | |
| **Tabs** | shadcn `Tabs` | `ui/tabs.tsx` | 9 / 58 | dash | also inside ModalTabTemplate |
| | MUI `ToggleButtonGroup` as tabs | | 1 | student | |
| | custom `role="tab"` | — | 2 | | `account/MenuDoPerfil.tsx` is a hand-rolled section menu |
| **Menu / dropdown** | `DropdownMenu` | `atoms/dropdownMenu` (headlessui `Menu` + `Transition`) | 3 / 3 | shared (header) | the only headlessui use |
| | `MenuItems` | `molecules/menuItems` | 11 | shared | nav |
| | `mainMenu`, `menuMobile`, `sidebarDash`, `subMenuDash`, `ui/sidebar` | `organisms/*`, `ui/sidebar.tsx` | 1 each, 3 | shared | |
| | dashV2 overflow `⋯` | `DashToolbar` on `ui/popover` | 9 screens | dash | deliberately not `role="menu"` |
| **Tooltip** | shadcn `Tooltip` | `ui/tooltip.tsx` (`bg-primary` = zinc-900) | 8 / 6 | 1/0/6/1 | |
| | `ShadcnTooltip` wrapper | `atoms/shadnTooltip` | 3 | dash | |
| | V1 `ToolTip` | `atoms/tooltip` (`bg-gray-500`, CSS triangle) | 1 | student | |
| | MUI `Tooltip` | | 19 / 50 | dash | |
| | native `title=` | — | 102 files / 205 | | |
| **Popover** | shadcn `Popover` | `ui/popover.tsx` | 7 / 7 (+ dashV2 toolbar, `indicadores/InfoDaMetrica` 4 / 5) | mixed | |
| **Loader / spinner / skeleton** | shadcn `Skeleton` | `ui/skeleton.tsx` (`animate-pulse` is **dead**, so it is a static block) | 17 / 38 | 1/4/13/2 | |
| | react-loading-skeleton | `organisms/{aboutUs,actionAreas,features,footer,hero,supporters}Skeleton` | 6 / 24 | shared (home) | |
| | dashV2 `LinhasSkeleton` / `BlocosSkeleton` | `dashV2/DashTableEmpty.tsx` | via template | dash | |
| | MUI `CircularProgress` / `LinearProgress` / `Skeleton` | | 7 / 8; 1; 3 | dash | blue |
| | react-spinners `MoonLoader` | `confirmEnrolled/confirmEnrolledPage.tsx` | 1 | public | |
| | lucide `Loader2` + `animate-spin` | — | 11 files / 18 (and 28 `animate-spin` overall) | dash 17 | **spin is dead**, so the icons are static |
| **Toast** | react-toastify | `App.tsx` `<ToastContainer theme="colored" position="top-right" autoClose 5000>` | 130 files; calls: error 220, success 64, warn 20, info 18, update/loading 45 | 19/17/87/4 | default library palette, not brand |
| **Badge / status** | dashV2 `StatusBadge` | `dashV2/StatusBadge.tsx` | 15 files / 22 (+ derived column on 9 screens) | dash | done / running / missing / info / neutral; chip + dot, text marine |
| | shadcn `Badge` | `ui/badge.tsx` | 11 / 17 | s3/d9 | secondary 8, outline 4, default 4. Overrides use dead `bg-green-600`, `bg-orange-100`. |
| | MUI `Chip` | | 12 / 29 | s2/d10 | outlined 16, color info / success / warning / primary |
| | Domain | `dashQuestionNew/components/statusBadge.tsx`, `atoms/getStatusIcon`, `chat/UnreadBadge` (`#da005a`), `chat/SupportInboxBadge` | 1–4 | | |
| **Pagination** | shadcn `Pagination` | `ui/pagination.tsx` | 3 | | |
| | `PaginationWrapper` | `organisms/paginationWrapper` (on ui/pagination) | 2 / 3 + dashV2 `DashListFooter` | s1/d1 | |
| | MUI DataGrid built-in | | 8 | dash | |
| **Accordion / collapse** | shadcn `Accordion` | `ui/accordion.tsx` | **0** (dead) | | |
| | `CursinhoAccordion` | `atoms/cursinhoAccordin` | 1 | dash | |
| | MUI `Collapse` | | 4 | dash | |
| | `<details>` / `aria-expanded` ad hoc | — | 1 / ~14 files | | |

### 5.2 V1 `molecules/button` `typeStyle`: real colors and usage

Classes are taken from `atoms/buttonTemplate/index.tsx`. The base is `flex … border-2 font-bold text-sm md:text-base rounded-md gap-1`, `size.base = w-full h-12`, `size.small = w-fit h-fit px-2 py-1`, and `disabled = opacity-30 cursor-not-allowed`.

| typeStyle | Classes | Resolved colors | Contrast | Uses | p/s/d/sh |
|---|---|---|---|---:|---|
| **primary** (default) | `text-white border-orange bg-orange hover:bg-orange/80` | `#FFFFFF` on `#FF7600` | **2.68:1 (fails)** | 27 explicit + 50 implicit = **77** | 24/6/41/3 (+3 unreached) |
| secondary | `text-orange border-orange bg-white hover:bg-orange/90 hover:text-white` | `#FF7600` on white | 2.68:1 (fails) | 22 | 2/3/17/0 |
| tertiary | `text-white border-white hover:bg-white hover:text-marine` | white outline on dark bg | — | **0** | — |
| quaternary | `bg-white border-marine border-opacity-50 text-marine hover:bg-marine/90 hover:text-white` | `#0B2747` on white | 15.05:1 | 7 | 0/0/6/1 |
| accepted | `bg-green3 text-white hover:bg-green3/80` | white on `#19982B` | 3.77:1 (fails at small size) | 3 | dash |
| refused | `bg-red text-white hover:bg-red/80` | white on `#F43535` | 3.88:1 (fails at small size) | 10 | dash |
| none | `bg-transparent border-0` | — | — | 1 | student |
| `{expr}` | — | — | — | 2 | |

`size`: default/base 75, **small 46** (44 in dash), expr 1. The `className` overrides on V1 Button are `border-none` ×11, `bg-red` ×3, `bg-green2`/`border-green2` ×2, `bg-lightGreen` ×1 and `border-zinc-200` ×1.

### 5.3 Unused component code (0 non-test importers)

`atoms/{a4Page, barChart, fieldValueSimulationHistoryHeader, imagePreview, lineChart, permissionList, pieChart, simpleCardColor, sunBurstChart}`, `templates/dashCardTemplate` (replaced by dashV2), `ui/accordion.tsx` and `ui/form.tsx`.

---

## 6. Icons

| Set | Files | Distinct icons | JSX uses | public | student | dash | shared |
|---|---:|---:|---:|---:|---:|---:|---:|
| `lucide-react` | 90 | 111 | 254 | 14 | 16 | 51 | 7 (+2 unreached) |
| `react-icons` (all) | 71 | 116 | 169 | 5 | 4 | 49 | 13 |
| ↳ `fi` (Feather) | 26 | 25 | 66 | 1 | 1 | 24 | 0 |
| ↳ `md` | 15 | 14 | 19 | 1 | 0 | 13 | 1 |
| ↳ `fa` / `fa6` | 12 / 6 | 18 / 12 | 21 / 5 | 2 / 1 | 0 | 8 / 5 | 2 / 0 |
| ↳ `io5` / `io` | 12 / 8 | 16 / 5 | 21 / 12 | 1 / 0 | 0 | 8 / 5 | 3 / 3 (`ModalTemplate` close icon is `io`) |
| ↳ `lu` (lucide via react-icons) | 6 | 8 | 8 | 0 | 2 | 3 | 1 |
| ↳ `pi cg bs ri ai ci ti go bi hi` | 1–4 each | | | | | | |
| `@heroicons/react` (24/outline, 20/solid) | 14 | 24 | 25 | 1 | 0 | 13 (10 in `dashProvas`) | 0 |
| `@radix-ui/react-icons` | 6 | 8 | 11 | 0 | 0 | 1 | 4 (inside `ui/*`) |
| Local SVG (`src/assets/icons/*.svg`, svgr `ReactComponent`) | 30 | 53 files referenced, 50 in folder | 50 | 14 | 4 | 3 | 9 |

lucide is the only set present in every area. Feather (`react-icons/fi`) is visually almost the same as lucide and is used in 26 dash files. The `lu` sub-pack is lucide imported a second way. Heroicons are confined to `dashProvas`.

---

## 7. Other cross-cutting facts for later tickets

- **Catalog precedent.** `src/pages/devVitrine` is a dev-only route (`/dev/vitrine/:componente?/:estado?`, removed from the prod build by `import.meta.env.DEV`). It mounts *feature* components (17 vitrines, e.g. `meuPerfil`, `indicadores`, `ultimosProcessos`) with fake fetch and auth, so they can be screenshotted without a backend. It's relevant to ticket 08 (permanent catalog).
- **Guard precedent.** `dashV2/tokens.test.ts` (vitest) checks that dashV2 tokens use only config colors and no `-<family>-\d` classes, that primary text is marine, that yellow is not used for status, and so on. `semComponenteNoRender.test.ts` is a repo-wide source-scanning test. Lint-like rules for the migration ticket can follow this pattern.
- **`custom-gradient` and `right-gradient`** are defined in a non-`extend` `backgroundImage`, so all Tailwind gradient utilities (`bg-gradient-to-*`, 24 uses) are gone. `from-*`/`to-*` classes still emit variables but have no effect.
- **Tailwind plugins:** `tailwind-scrollbar-hide`, `@tailwindcss/typography`, `tailwindcss-animate`. Variant helpers in use: `cva` (shadcn, 5 files) and `tailwind-variants` `tv` (V1, 11 files), plus `cn` (`clsx` + `tailwind-merge`).
- **Inline styling:** 356 MUI `sx={…}` and 83 `style={{…}}`.
- **Header heights** are hard-coded as `calc(100vh-76px)` / `-88px` (17 uses) and `scroll-margin-top: 76px` in `index.css`.

## 8. Caveats

- Counts are lexical. Classes built dynamically (template literals with `${}` fragments, lookup maps) are counted only where the full class name appears literally. Comments are included.
- Area attribution of shared components is by static reachability. A component reached from several areas counts as "shared" even if one area dominates at runtime.
- The dead-class check used the local `node_modules/tailwindcss@3.4.19` (the repo pins `^3.4.0`). This merge behaviour has been stable across Tailwind v3.
