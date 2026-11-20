# Spec: Você na Facul design system (`client-vcnafacul`)

> **Migrado do wayfinder** (`343-design-system`, 2026-10-28). Conteúdo mantido em inglês. Na migração
> entraram só os números `D1…D16` (§1) e os caminhos dos links; o resto do texto é o original. Numeração nunca
> reaproveitada; decisão mudada: `~~Dn~~ substituída por Dm`. Cite como `tickets/059 D8`.

Source: [mapa.md](planejamento/mapa.md), issue [Montar Design System no Figma](https://github.com/vcnafacul/client-vcnafacul/issues/343). Written 2026-10-28 from the resolutions of tickets 01–14. Code facts refer to `origin/develop` @ `bdb34525`.

## Outcome

`client-vcnafacul` gets a **code-first design system**:

- **brand tokens** as CSS variables, wired into Tailwind;
- **one component library**: shadcn/Radix + cva, living in `src/components/ui`;
- **Storybook** as the living catalog;
- **guard tests** that keep the codebase on the system.

All of it ships as **one migration PR** made of ordered, independently green commits. The PR moves every screen onto the system and removes the libraries it replaces (§7).

Nothing in this spec is open. Each section names the ticket that holds the rationale. Where a value here differs from an earlier ticket, the later amendment wins, and it is noted.

**How to read the visual references.** Open the prototypes in `prototipos/` in a browser. They are throwaway, but they show the decided look:
- [color-palette.html](prototipos/color-palette.html) `?variant=A`
- [type-scale.html](prototipos/type-scale.html) `?variant=C`
- [components.html](prototipos/components.html) `?variant=C`
- [home-expressive.html](prototipos/home-expressive.html) `?variant=A&hero=96`

---

## 1. Decision index

Each decision's rationale and rejected options live in the planning ticket it links to.

| D | Decision | In this spec | Rationale |
|---|---|---|---|
| D1 | **Code is the source of truth.** The spec defines tokens and components; a Figma library may mirror it later | §8 | [map](planejamento/mapa.md) (settled while charting) |
| D2 | **dashV2 is the seed**: the roles in `dashV2/tokens.ts` stay unless a decision overturns one (the CTA colors were, by D8) | §3, §7.2 | [map](planejamento/mapa.md) (settled while charting) |
| D3 | **One token foundation for all three surfaces** (public site/home, student area, admin dashboards); coverage is separate from rollout order | §2, §7 | [map](planejamento/mapa.md) (settled while charting) |
| D4 | **The code on `develop` is the only input**: no Figma or mockups | — | [map](planejamento/mapa.md) (settled while charting) |
| D5 | **Dark-mode-ready structure**: semantic tokens a theme can remap; dark values are out of scope | §2.2, §8 | [map](planejamento/mapa.md) (settled while charting) |
| D6 | Libraries kept / retired | §4 | [Which UI libraries to keep](planejamento/03-library-strategy.md) |
| D7 | Token structure | §2.1–2.3 | [How tokens are structured](planejamento/04-token-architecture.md) |
| D8 | Colors | §2.2, §2.7, §5.3 | [Color palette](planejamento/05-color-palette.md) |
| D9 | Typography (amended by D16) | §2.4 | [Type scale](planejamento/06-type-scale.md) |
| D10 | Spacing, radius, shadows, breakpoints, layout, z-index | §2.5–2.6 | [Spacing, radius, shadows and breakpoints](planejamento/07-spacing-radius-elevation.md) |
| D11 | Storybook as the catalog; the vitrine stays for feature screens | §5.1 | [Permanent component catalog](planejamento/08-permanent-catalog.md) |
| D12 | Components | §3 | [Core components visual prototype](planejamento/10-core-components-prototype.md) |
| D13 | Folders & naming | §2.1, §3 | [Where the design system lives and what it's called](planejamento/11-location-and-naming.md) |
| D14 | Migration in one PR | §5.2, §7 | [Migration plan](planejamento/12-migration-plan.md) |
| D15 | Writing, a11y, mobile guidelines | §5.4, §6 | [Written guidelines](planejamento/13-written-guidelines.md) |
| D16 | Home / public expressive layer | §2.2, §2.4, §7.3 | [Expressive layer for the home page](planejamento/14-home-expressive-layer.md) |

Facts, not decisions: [Current UI inventory](planejamento/01-ui-inventory.md) · [research](pesquisa/01-ui-inventory.md), and [Options for a permanent component catalog](planejamento/02-catalog-options.md) · [research](pesquisa/02-catalog-options.md).

---|---|
| UI inventory (facts) | [Current UI inventory](planejamento/01-ui-inventory.md) · [research](pesquisa/01-ui-inventory.md) |
| Catalog options (facts) | [Options for a permanent component catalog](planejamento/02-catalog-options.md) · [research](pesquisa/02-catalog-options.md) |
| Libraries kept / retired | [Which UI libraries to keep](planejamento/03-library-strategy.md) |
| Token structure | [How tokens are structured](planejamento/04-token-architecture.md) |
| Colors | [Color palette](planejamento/05-color-palette.md) |
| Typography | [Type scale](planejamento/06-type-scale.md) (amended by ticket 14) |
| Spacing, radius, shadows, breakpoints, layout, z-index | [Spacing, radius, shadows and breakpoints](planejamento/07-spacing-radius-elevation.md) |
| Storybook | [Permanent component catalog](planejamento/08-permanent-catalog.md) |
| Components | [Core components visual prototype](planejamento/10-core-components-prototype.md) |
| Folders & naming | [Where the design system lives and what it's called](planejamento/11-location-and-naming.md) |
| Migration | [Migration plan](planejamento/12-migration-plan.md) |
| Writing, a11y, mobile | [Written guidelines](planejamento/13-written-guidelines.md) |
| Home / public | [Expressive layer for the home page](planejamento/14-home-expressive-layer.md) |

---

## 2. Foundations

### 2.1 Where things live

| Piece | Path |
|---|---|
| Design-system components (+ colocated `*.stories.tsx`) | `src/components/ui/` (kebab-case files, English names) |
| Token CSS variables | `src/styles/tokens.css`, `@import`ed at the top of `src/index.css` |
| Tailwind wiring | `tailwind.config.js` |
| Type-step plugin | `tailwind/type-scale.js` |
| `palette` TS export | `src/lib/palette.ts` |
| Toast defaults wrapper | `src/lib/toast.ts` |
| Guard test / contrast test | `src/design-system/guard.test.ts`, `src/design-system/contrast.test.ts` |
| MDX docs (foundations, usage, guidelines) | `src/design-system/docs/` |
| Storybook config | `.storybook/` (repo root) |
| Codemods (deleted in the cleanup commit) | `scripts/ds-codemods/` |

The two layers are:
- **Primitives:** `--<hue>-<step>`, HSL channels, never exposed as Tailwind utilities.
- **Semantic tokens:** shadcn's vocabulary, extended. Components and screens use **only** these.

Themes (`.dark` later, and the home `[data-theme]`s) re-point semantic variables. All names are English, and semantic names never mention a hue.

### 2.2 `src/styles/tokens.css`

Every primitive carries its hex in a comment. The values were generated in OKLCH, with each brand hex pinned on its step (generator: `scale()` in the palette prototype).

```css
:root {
  /* ---------- primitives (never used directly by components) ---------- */
  --marine-50: 218 100% 98%;        /* #F7FAFF */
  --marine-100: 213 92% 95%;        /* #E8F2FE */
  --marine-200: 214 56% 89%;        /* #D5E2F3 */
  --marine-300: 214 32% 77%;        /* #B2C2D7 */
  --marine-400: 213 21% 61%;        /* #8699B0 */
  --marine-500: 213 19% 50%;        /* #677C96 */
  --marine-600: 213 25% 40%;        /* #4D6480 */
  --marine-700: 213 33% 32%;        /* #364E6C */
  --marine-800: 213 47% 24%;        /* #203A59 */
  --marine-900: 212 73% 16%;        /* #0B2747 */
  --marine-950: 213 77% 7%;         /* #04101F */

  --orange-50: 24 100% 98%;         /* #FFF9F5 */
  --orange-100: 22 100% 96%;        /* #FFF1E9 */
  --orange-200: 21 100% 92%;        /* #FFE3D4 */
  --orange-300: 20 100% 83%;        /* #FFC5A7 */
  --orange-400: 21 100% 69%;        /* #FF9A62 */
  --orange-500: 28 100% 50%;        /* #FF7600 */
  --orange-600: 27 100% 39%;        /* #C55A00 */
  --orange-700: 28 100% 35%;        /* #B35300 */
  --orange-800: 25 100% 20%;        /* #662B00 */
  --orange-900: 22 100% 12%;        /* #3E1700 */
  --orange-950: 15 100% 6%;         /* #1F0800 */

  --pink-50: 351 100% 99%;          /* #FFF8F9 */
  --pink-100: 353 100% 96%;         /* #FFEDEF */
  --pink-200: 352 100% 93%;         /* #FFDADF */
  --pink-300: 351 100% 85%;         /* #FFB0BC */
  --pink-400: 347 99% 71%;          /* #FE6E8E */
  --pink-500: 344 82% 60%;          /* #ED4472 */
  --pink-600: 335 100% 43%;         /* #DA005A */
  --pink-700: 336 100% 32%;         /* #A50042 */
  --pink-800: 337 100% 23%;         /* #73002C */
  --pink-900: 340 100% 14%;         /* #480018 */
  --pink-950: 346 100% 7%;          /* #260009 */

  --mint-50: 160 100% 96%;          /* #EDFFF9 */
  --mint-100: 161 100% 92%;         /* #D5FFF2 */
  --mint-200: 164 98% 83%;          /* #AAFEE7 */
  --mint-300: 165 77% 70%;          /* #79EED1 */
  --mint-400: 168 66% 53%;          /* #37D6B5 */
  --mint-500: 170 100% 34%;         /* #00AB8E */
  --mint-600: 170 100% 26%;         /* #00846E */
  --mint-700: 170 100% 19%;         /* #006352 */
  --mint-800: 169 100% 13%;         /* #004438 */
  --mint-900: 168 100% 8%;          /* #002921 */
  --mint-950: 165 100% 4%;          /* #00140F */

  --yellow-50: 51 100% 95%;         /* #FFFBE3 */
  --yellow-100: 52 100% 90%;        /* #FFF8CC */
  --yellow-200: 51 100% 83%;        /* #FFF2A6 */
  --yellow-300: 52 100% 62%;        /* #FFE53C */
  --yellow-400: 51 100% 40%;        /* #CCAC00 */
  --yellow-500: 48 100% 33%;        /* #A78600 */
  --yellow-600: 46 100% 26%;        /* #856500 */
  --yellow-700: 43 100% 20%;        /* #674A00 */
  --yellow-800: 41 100% 15%;        /* #4A3200 */
  --yellow-900: 35 100% 9%;         /* #301C00 */
  --yellow-950: 28 100% 5%;         /* #1A0C00 */

  --red-50: 7 100% 98%;             /* #FFF8F7 */
  --red-100: 6 100% 96%;            /* #FFEDEB */
  --red-200: 7 100% 92%;            /* #FFDAD5 */
  --red-300: 6 100% 83%;            /* #FFB0A7 */
  --red-400: 4 100% 70%;            /* #FF6E64 */
  --red-500: 0 90% 58%;             /* #F43535 */
  --red-600: 357 82% 42%;           /* #C5131D */
  --red-700: 354 100% 30%;          /* #99000F */
  --red-800: 356 100% 21%;          /* #6D0007 */
  --red-900: 357 100% 14%;          /* #460003 */
  --red-950: 358 100% 8%;           /* #270001 */

  --blue-50: 207 100% 98%;          /* #F6FBFF */
  --blue-100: 211 100% 95%;         /* #E8F3FF */
  --blue-200: 211 100% 91%;         /* #D0E7FF */
  --blue-300: 210 94% 80%;          /* #9DCCFC */
  --blue-400: 211 64% 65%;          /* #6FA6DF */
  --blue-500: 210 55% 55%;          /* #4D8CCB */
  --blue-600: 210 52% 42%;          /* #346CA3 */
  --blue-700: 210 60% 32%;          /* #205181 */
  --blue-800: 208 79% 21%;          /* #0B3860 */
  --blue-900: 210 100% 13%;         /* #002141 */
  --blue-950: 213 100% 7%;          /* #001024 */

  --neutral-50: 218 100% 98%;       /* #F7FAFF */
  --neutral-100: 212 48% 95%;       /* #EBF1F8 */
  --neutral-200: 214 23% 88%;       /* #DAE0E8 */
  --neutral-300: 214 12% 75%;       /* #B7BEC7 */
  --neutral-400: 213 8% 58%;        /* #8B939D */
  --neutral-500: 213 8% 46%;        /* #6D757F */
  --neutral-600: 216 8% 36%;        /* #555B64 */
  --neutral-700: 212 9% 28%;        /* #40464D */
  --neutral-800: 213 11% 19%;       /* #2C3137 */
  --neutral-900: 216 16% 12%;       /* #1A1E24 */
  --neutral-950: 210 25% 6%;        /* #0C1014 */

  /* ---------- semantic (light) ---------- */
  --background: 0 0% 100%;            /* white */
  --foreground: var(--marine-900);
  --card: 0 0% 100%;
  --card-foreground: var(--marine-900);
  --popover: 0 0% 100%;
  --popover-foreground: var(--marine-900);
  --page: var(--neutral-50);          /* app background behind surfaces */

  --primary: var(--marine-900);
  --primary-foreground: 0 0% 100%;
  --secondary: var(--neutral-100);
  --secondary-foreground: var(--marine-900);
  --muted: var(--neutral-100);
  --muted-foreground: var(--neutral-600);   /* the ONLY secondary text color */
  --accent: var(--marine-100);              /* hover/highlight background in menus, rows */
  --accent-foreground: var(--marine-900);

  --cta: var(--orange-700);                 /* #B35300 — at most one per screen */
  --cta-foreground: 0 0% 100%;
  --highlight: var(--orange-700);           /* eyebrows + highlighted words (home) */

  --destructive: var(--red-600);
  --destructive-foreground: 0 0% 100%;
  --destructive-muted: var(--red-50);
  --success: var(--mint-700);
  --success-foreground: 0 0% 100%;
  --success-muted: var(--mint-50);
  --warning: var(--yellow-600);
  --warning-foreground: 0 0% 100%;
  --warning-muted: var(--yellow-100);
  --info: var(--blue-600);
  --info-foreground: 0 0% 100%;
  --info-muted: var(--blue-50);

  --border: var(--neutral-200);             /* decorative: cards, dividers, rows */
  --input: var(--neutral-400);              /* field boundaries, 3.1:1 */
  --ring: var(--orange-600);                /* solid 2px focus ring + 2px white offset */

  --chart-1: var(--marine-700);
  --chart-2: var(--orange-600);
  --chart-3: var(--mint-600);
  --chart-4: var(--pink-600);
  --chart-5: var(--yellow-500);
  --chart-6: var(--blue-500);

  --sidebar-background: 0 0% 100%;
  --sidebar-foreground: var(--marine-900);
  --sidebar-primary: var(--marine-900);
  --sidebar-primary-foreground: 0 0% 100%;
  --sidebar-accent: var(--marine-100);
  --sidebar-accent-foreground: var(--marine-900);
  --sidebar-border: var(--neutral-200);
  --sidebar-ring: var(--orange-600);

  /* ---------- non-color variables ---------- */
  --radius: 0.5rem;
  --header-h: 76px;
}
@media (min-width: 768px) { :root { --header-h: 88px; } }

/* ---------- home / public section themes (re-point semantic tokens only) ---------- */
[data-theme="marine"] {
  --background: var(--marine-900);
  --foreground: 0 0% 100%;
  --card: var(--marine-800);
  --card-foreground: 0 0% 100%;
  --muted: var(--marine-800);
  --muted-foreground: var(--marine-200);
  --border: var(--marine-700);
  --primary: 0 0% 100%;
  --primary-foreground: var(--marine-900);
  --cta: var(--orange-500);                 /* bright #FF7600 on navy */
  --cta-foreground: var(--marine-900);      /* 5.62:1 */
  --highlight: var(--mint-400);
  --ring: var(--orange-500);
}
[data-theme="neutral"] { /* global tokens; --highlight stays orange-700 */ }
[data-theme="yellow"] {
  --background: var(--yellow-50);
  --border: var(--yellow-100);
  --highlight: var(--yellow-700);
}
```

The old `.dark` block in `index.css` is removed. Dark values are out of scope, but the structure allows a `.dark { … }` later. Also removed: the shadcn zinc `:root` block and `src/styles/sectionThemes.css` (its `--section-*` variables and `.home-section__eyebrow`). Section components read semantic tokens instead.

Contrast of every semantic pair (all pass): see the palette prototype §3. The contrast test (§5.3) re-checks them on every CI run.

### 2.3 `tailwind.config.js`

```js
import typeScale from "./tailwind/type-scale.js";
const c = (v) => `hsl(var(--${v}) / <alpha-value>)`;
const pair = (n) => ({ DEFAULT: c(n), foreground: c(`${n}-foreground`) });

export default {
  darkMode: ["class"],
  content: ["./src/**/*.{js,jsx,ts,tsx,mdx}", "./.storybook/**/*.{ts,tsx}"],
  theme: {
    screens: { sm: "768px", md: "1200px", lg: "1400px", xl: "1565px" },   // unchanged (§2.6)
    extend: {
      fontFamily: { raleway: ["Raleway", "sans-serif"], sans: ["Raleway", "sans-serif"] },
      colors: {
        // ---- semantic (the design system) ----
        background: c("background"), foreground: c("foreground"), page: c("page"),
        card: pair("card"), popover: pair("popover"), primary: pair("primary"),
        secondary: pair("secondary"), muted: pair("muted"), accent: pair("accent"),
        cta: pair("cta"), highlight: c("highlight"),
        destructive: { ...pair("destructive"), muted: c("destructive-muted") },
        success: { ...pair("success"), muted: c("success-muted") },
        warning: { ...pair("warning"), muted: c("warning-muted") },
        info: { ...pair("info"), muted: c("info-muted") },
        border: c("border"), input: c("input"), ring: c("ring"),
        chart: Object.fromEntries([1, 2, 3, 4, 5, 6].map((i) => [i, c(`chart-${i}`)])),
        sidebar: { DEFAULT: c("sidebar-background"), foreground: c("sidebar-foreground"),
          primary: c("sidebar-primary"), "primary-foreground": c("sidebar-primary-foreground"),
          accent: c("sidebar-accent"), "accent-foreground": c("sidebar-accent-foreground"),
          border: c("sidebar-border"), ring: c("sidebar-ring") },
        // ---- legacy: kept ONLY until the cleanup commit, then deleted (guard is strict) ----
        // phase 0 shape: { ...colors.red, DEFAULT: "#F43535" } etc. for red/orange/yellow/green/pink/purple,
        // plus the flat names (marine, grey, green2, …). Removed in commit 10.
      },
      borderRadius: { lg: "var(--radius)", md: "calc(var(--radius) - 2px)", sm: "calc(var(--radius) - 4px)", xl: "calc(var(--radius) + 4px)" },
      boxShadow: {
        sm: "0 1px 2px rgba(11,39,71,.08)",
        md: "0 4px 12px rgba(11,39,71,.10), 0 1px 3px rgba(11,39,71,.06)",
        lg: "0 16px 40px rgba(11,39,71,.18), 0 2px 8px rgba(11,39,71,.08)",
        DEFAULT: "0 1px 2px rgba(11,39,71,.08)",
      },
      zIndex: { base: "0", raised: "10", sticky: "20", header: "30", overlay: "40", popover: "50", toast: "60" },
      maxWidth: { "prose-content": "720px", form: "560px", page: "1200px" },
      height: { header: "var(--header-h)" },
      spacing: { header: "var(--header-h)" },
      container: { center: true, padding: { DEFAULT: "16px", sm: "24px", md: "32px" } },
      backgroundImage: {
        "brand-stripe": "linear-gradient(to right, hsl(var(--mint-400)), #8CC408, hsl(var(--yellow-300)), hsl(var(--orange-500)), hsl(var(--pink-600)))",
      },
      keyframes: { /* shadcn accordion-down/up + attention-ring (moved here from top level in phase 0) */ },
      animation: { /* idem, plus rotate/rotate30/rotate15/rotate5 moved into extend */ },
    },
  },
  plugins: [require("tailwind-scrollbar-hide"), require("@tailwindcss/typography"), require("tailwindcss-animate"), typeScale],
};
```

- **Phase 0 (commit 1)** only does two things: wrap the colliding flat colors as `{ ...defaultScale, DEFAULT: brandHex }`, and move `animation`/`keyframes`/`backgroundImage` into `extend`. Everything else above lands in commit 2.
- **`@tailwindcss/typography`:** configure `prose` (`theme.extend.typography`) so that body text = the `prose` step (16→17px / 1.7), headings = `h2`–`h4` steps, links = `primary` with underline, and colors = `foreground`/`muted-foreground`/`border`. Rich text (tiptap, markdown, question statements, materials) renders inside `className="prose max-w-prose-content"`.
- **Default `fontSize` scale:** kept in the config during the branch (deprecated), and **removed from the theme in the cleanup commit**, so `text-sm` and the like stop compiling.

### 2.4 Type scale: `tailwind/type-scale.js`

One class per step. Mobile values apply by default, and desktop values apply at `@media (min-width: 768px)`. `text-hero` has three sizes.

**Weight is emitted under `:where(.text-<step>)`** (zero specificity), so `font-semibold`/`font-bold`/… still override it regardless of utility order. Size, line height and tracking use the normal class.

| Step | < 768 | ≥ 768 | ≥ 1200 | ≥ 1565 | Line height | Weight | Extra |
|---|---|---|---|---|---|---|---|
| `text-hero` | 48 | 48 | 72 | 96 | 1.05 | 800 | `letter-spacing:-.01em; text-wrap:balance` — **home hero only** (guard) |
| `text-display` | 30 | 48 | | | 1.1 | 800 | `letter-spacing:-.01em` — home/marketing section titles *(amended from 36→60 by ticket 14)* |
| `text-h1` | 24 | 30 | | | 1.2 | 700 | |
| `text-h2` | 20 | 24 | | | 1.25 | 700 | |
| `text-h3` | 16 | 18 | | | 1.3 | 600 | |
| `text-h4` | 14 | 16 | | | 1.4 | 600 | |
| `text-prose` | 16 | 17 | | | 1.7 | 400 | long-form reading |
| `text-body` | 14 | 14 | | | 1.5 | 400 | default UI text |
| `text-body-sm` | 13 | 13 | | | 1.45 | 400 | metadata |
| `text-caption` | 12 | 12 | | | 1.4 | 500 | **minimum size** |
| `text-label` | 13 | 13 | | | 1.3 | 600 | form labels |
| `text-button` | 14 | 14 | | | 1 | 600 | |
| `text-overline` | 12 | 12 | | | 1.3 | 700 | `text-transform:uppercase; letter-spacing:.16em` |
| `text-numeric` | 24 | 28 | | | 1.1 | 700 | `font-variant-numeric:tabular-nums` |

```js
// tailwind/type-scale.js (sketch)
import plugin from "tailwindcss/plugin";
const S = { hero: [[48, 48, 72, 96], 1.05, 800, { letterSpacing: "-0.01em", textWrap: "balance" }], display: [[30, 48], 1.1, 800, { letterSpacing: "-0.01em" }], /* … table above … */ };
const BP = ["768px", "1200px", "1565px"];
export default plugin(({ addUtilities }) => {
  for (const [name, [sizes, lh, weight, extra = {}]] of Object.entries(S)) {
    const cls = `.text-${name}`;
    addUtilities({
      [cls]: { fontSize: `${sizes[0]}px`, lineHeight: String(lh), ...extra },
      [`:where(${cls})`]: { fontWeight: String(weight) },
      ...Object.fromEntries(sizes.slice(1).map((px, i) => [`@media (min-width: ${BP[i]})`, { [cls]: { fontSize: `${px}px` } }])),
    });
  }
});
```

- **Fonts:** `index.html` loads `Raleway:ital,wght@0,400;0,500;0,600;0,700;0,800;1,400` (6 files). Weight 300 and the other italics are dropped. `font-light`/`font-thin` become `font-normal`, and `font-black` becomes `font-extrabold`.
- **Monospace** uses the system stack (`font-mono`).
- **Application:** classes go on semantic elements (`<h2 className="text-h2">`). There is no `Text`/`Heading` component. shadcn `CardTitle` = `text-h4`, `DialogTitle`/`SheetTitle`/`AlertDialogTitle` = `text-h3`.

### 2.5 Spacing, radius, shadows, z-index, layout

- **Spacing:** Tailwind's 4px scale. Component spacing is `0.5 1 1.5 2 3 4 6 8`, layout spacing `10 12 16 20 24`. **Arbitrary `p/m/gap/space-[…]` is banned** (guard).
- **Radius:**

  | Class | Size | Used for |
  |---|---|---|
  | `rounded-sm` | 4px | checkbox, small chips, inner elements |
  | `rounded-md` | 6px | buttons, inputs, selects, menu items |
  | `rounded-lg` | 8px | cards, popovers, menus, toasts, alerts |
  | `rounded-xl` | 12px | dialogs, sheets |
  | `rounded-full` | — | pills, badges, avatars, dots |

  `rounded-2xl`/`3xl` and one-sided corners are allowed **only under `src/pages/homeV2` and `src/pages/quemSomos`** (guard).
- **Shadows:** in-page surfaces (cards, tables, panels) get `border` and **no shadow**. Floating elements: `shadow-sm` for sticky bars, `shadow-md` for popovers, menus, toasts and tooltips, `shadow-lg` for dialogs and sheets. Values are in §2.3. `shadow-xl`/`2xl`/`inner` are flagged.
- **Border width:** 1px. 2px only for the focus ring and selected states.
- **z-index:** `z-base 0 · z-raised 10 · z-sticky 20 · z-header 30 · z-overlay 40 · z-popover 50` (above dialogs, so selects and menus work inside them) `· z-toast 60`. **Arbitrary `z-[…]` is banned.**
- **Layout:** `container` padding 16/24/32. `max-w-prose-content` 720, `max-w-form` 560, `max-w-page` 1200. Admin screens are full width in the dash shell. The header height is `--header-h`, with `h-header`, `min-h-[calc(100vh-theme(spacing.header))]` replacing the 17 hard-coded `calc(100vh-76px|88px)`, and `scroll-margin-top: var(--header-h)`.

### 2.6 Breakpoints

These stay as they are: `sm` 768 (the mobile/desktop split; the type steps switch here), `md` 1200 (full desktop), `lg` 1400 and `xl` 1565 (wide only). The MDX "Foundations / Breakpoints" page must say: **"our `sm` = Tailwind's default `md`: translate shadcn examples."**

### 2.7 `src/lib/palette.ts`

This is a TypeScript mirror of the primitive hexes, plus the `chart` sequence, for code that can't use classes: chart libraries (nivo, recharts, chart.js, x-charts) and Leaflet pins.

```ts
export const palette = { marine: { 50: "#F7FAFF", /* … all §2.2 primitives … */ }, /* … */ } as const;
export const chartSeries = [palette.marine[700], palette.orange[600], palette.mint[600], palette.pink[600], palette.yellow[500], palette.blue[500]] as const;
```

The contrast test asserts that `palette.ts` and `tokens.css` agree.

---

## 3. Components (`src/components/ui`)

Every component is shadcn/Radix + **cva** + `cn`, restyled to tokens, with a colocated `*.stories.tsx`: **one story per variant and one per state that changes its look**, with autodocs and controls (§5). Visual reference: [components.html](prototipos/components.html) `?variant=C`, at both widths.

**Density (adaptive):**
- Desktop: controls 36px (`h-9`), table rows 40px.
- Under 768px: **controls, option rows and menu items are 44px**, **tables render as cards**, and **dialogs are full-screen** with stacked full-width buttons (main action on top).

| Component | File | Spec |
|---|---|---|
| **Button** | `button.tsx` | **Variants:** `cta`, `primary` (default), `secondary`, `outline` (border `input`), `ghost`, `destructive`, `link`. **Sizes:** `sm` (h-8), `md` (h-9; h-11 < 768), `lg` (h-11), `icon` (square; **`aria-label` required by the TS type**). Props: `loading` (spinner + label, disabled), `asChild`. **States:** hover (cta/primary/destructive darken 12%, `primary` lightens; outline/ghost/secondary → `bg-accent`), focus-visible `ring-2 ring-ring ring-offset-2`, active `translate-y-px`, disabled `opacity-50 cursor-not-allowed`. **At most one `cta` per screen.** |
| **Field** | `field.tsx` (new) | Wraps every control: `label` (text-label), the control, then `hint` (caption, muted) **or** `error` (caption, muted text + `destructive` x-circle icon; control gets `aria-invalid` and a `destructive` border; linked via `aria-describedby`). **`required` → red `*` after the label (`aria-hidden`) + `required`/`aria-required` on the control.** `FormLegend` renders "* obrigatório" once per form. |
| Input / Textarea | `input.tsx`, `textarea.tsx` | Border `input`, `rounded-md`, placeholder `muted-foreground`, disabled `bg-muted opacity-60`, optional leading/trailing icon slots. Correct `type`/`inputMode`/`autoComplete` (CPF/CEP numeric, tel, email, `one-time-code`). |
| Select | `select.tsx` | Radix Select. The open list is a `menu` (`shadow-md`, `z-popover`, `accent` highlight, check on the selected item). |
| **Combobox** | `combobox.tsx` (new) | Popover + `cmdk`. **Needed:** it replaces MUI `Autocomplete` (2 files), so the "only if needed" condition from ticket 03 is met. Adds the `cmdk` dependency. |
| Checkbox / RadioGroup / Switch | `checkbox.tsx`, `radio-group.tsx` (new), `switch.tsx` (new) | On = `primary`, off border `input`. Checkbox has an indeterminate state. Labels are clickable, and option rows are 44px on mobile. |
| **DatePicker / DateRangePicker** | `calendar.tsx`, `date-picker.tsx`, `date-range-picker.tsx` (from dashV2 `DashDateRangeFilter`) | react-day-picker v9 in a Popover with pt-BR labels. Selected = `primary`, range = `accent`, today = 1px `input` ring. Field trigger with a calendar icon. Dates are formatted with `date-fns-tz` in `America/Sao_Paulo`. |
| Card | `card.tsx` | `rounded-lg border bg-card`, **no shadow**. Parts: Header/Title (`text-h4`)/Description/Content/Footer. |
| **Dialog** | `dialog.tsx` | `size`: `sm` 400 / `md` 560 (default) / `lg` 800 / `full`. `rounded-xl shadow-lg`, scrim `foreground/55`, close icon button, Title `text-h3`, Description `body-sm muted`, footer with secondary `outline` + main `primary`/`cta`. **Full-screen under 768.** Radix focus trap + Esc. |
| AlertDialog | `alert-dialog.tsx` | `size="sm"`. **Title and action button name the action** ("Excluir prova"), and destructive actions use the `destructive` variant. |
| Sheet | `sheet.tsx` | Right side for filters and details. **Left side is the mobile nav** (§6). |
| **DataTable** | `data-table.tsx` (from dashV2 `DashTable`) | Columns: `{ id, header, cell, align, sortable, width, mobile?: "title" \| "meta" \| "status" \| "hidden" }`. Props: `rows`, `getRowId`, `sort` + `onSortChange` (server or client), `selection` + `onSelectionChange`, `pagination` (`page`, `pageSize`, `total`, `onPageChange`, `pageSizeOptions`; server-side capable), `state: "loading" \| "empty" \| "ready"`, `toolbar`, `bulkActions`, `rowActions`, `renderMobileCard?`. **Look:** header `h-9 text-caption muted-foreground`, sorted header in `foreground` with an arrow, rows `h-10`, hover `bg-page`, selected `bg-accent`, numbers right-aligned and tabular, status column = `StatusBadge look="dot"`, `⋯` row menu (DropdownMenu), selection bar (count + bulk actions) when rows are selected, footer "Mostrando X–Y de N" + Pagination, empty state (icon + `h4` + hint + "Limpar filtros"), loading = skeleton rows. **Mobile card:** derived from the `mobile` roles (defaults: first column = title, `StatusBadge` column = status, next 2 columns = meta joined by " · ", rest hidden). Selection and row actions always show. `renderMobileCard` is the escape hatch. dashV2 `hideBelow` → `mobile: "hidden"`. |
| Table | `table.tsx` | Low-level parts used by DataTable and simple static tables. |
| Tabs | `tabs.tsx` | **Underline only:** baseline 1px `border`, active 2px `primary` underline + `foreground`, inactive `muted-foreground`, height = control height. |
| DropdownMenu | `dropdown-menu.tsx` (new, `@radix-ui/react-dropdown-menu`) | `shadow-md z-popover rounded-lg`. Items are 32px (44 on mobile), with optional label, leading icons, separators, shortcut hint, and a destructive item in `text-destructive`. It replaces the headlessui header menu. |
| Popover / Tooltip | `popover.tsx`, `tooltip.tsx` | Popover = card + `shadow-md`. Tooltip = `bg-primary text-primary-foreground text-caption rounded-md`, opens on hover, focus **and tap**. |
| **StatusBadge** | `status-badge.tsx` (from dashV2) | `variant`: `success \| warning \| destructive \| info \| neutral`. `look`: **`dot`** (neutral `muted` pill + colored dot + `foreground` text; required inside DataTable and lists) or **`tint`** (`*-muted` background, colored dot + text; standalone and detail pages). dashV2 `done/running/missing/info/neutral` → `success/warning/destructive/info/neutral`. |
| Badge | `badge.tsx` | `default` (`primary`), `secondary`, `outline`. |
| Alert | `alert.tsx` (new) | Tinted: `*-muted` background, status icon + title in the status color, message in `foreground`, optional action (for example "Tentar de novo"). |
| Toast | `toast.tsx` (react-toastify setup + CSS) | `<ToastContainer position="top-right" limit={3} pauseOnHover closeButton newestOnTop />`, offset below `--header-h`, `z-toast`. **On mobile:** top, full width. **Defaults by type: success/info `autoClose: 5000`; warning/error `autoClose: false`.** The defaults live in **`src/lib/toast.ts`**, which re-exports react-toastify's `toast` with the same API and applies the per-type `autoClose` (explicit per-call options still win). The toast codemod rewrites `from "react-toastify"` → `from "@/lib/toast"` in the ~130 importing files. **No call changes, only the import path.** Look: white card, `border`, `shadow-md`, status icon, title + optional message, close button. `--toastify-*` variables point at tokens and `theme="colored"` is removed. |
| Skeleton | `skeleton.tsx` | `bg-primary/10 animate-pulse rounded-md`. dashV2 `LinhasSkeleton`/`BlocosSkeleton` move here as `TableSkeleton`. |
| Spinner | `spinner.tsx` (new) | lucide `Loader2` + `animate-spin`. Sizes inline (16), button (16), page (32). `aria-label="Carregando"`. |
| Pagination | `pagination.tsx` | Fixes the existing keyboard bug (`<a>` without `href`): real `<button>`s, ghost pages, current page `primary`, pt-BR labels ("Anterior"/"Próxima"). |
| **Progress** | `progress.tsx` (new) | Track `muted`, fill `success` (or `primary`), `rounded-full h-2`. **Added for parity:** it replaces MUI `LinearProgress` and the dashV2 `progress` tokens and covers the KPI bars. |
| Accordion | `accordion.tsx` (adopt the unused one) | Replaces MUI `Collapse` (4) and `atoms/cursinhoAccordin`. |
| Sidebar | `sidebar.tsx` | The dash shell. **Under 768 it's a left Sheet** opened from the header hamburger. |
| Separator, ScrollArea, Label | existing | Restyled to tokens only. |

Removed from `ui`: `form.tsx` (unused, superseded by `Field`).

**The admin-list pattern stays in `src/components/dashV2`** as a consumer: `DashListTemplate`, `DashToolbar`, `DashFilterBar`, `DashListFooter`, `derive*`, `useAcimaDeSm`, `paginacao`, `sortRows`, `intervaloDeDatas`. They're rebuilt on `ui`, and `dashV2/tokens.ts` is deleted. Promoting `DashListTemplate` to a documented design-system pattern is revisited after it stops importing V1/domain code. That's out of this PR.

---

## 4. Libraries

| | Keep | Retire (removed from `package.json` in the cleanup commit) |
|---|---|---|
| Foundation | shadcn/Radix (`@radix-ui/*`), Tailwind 3.4, `class-variance-authority`, `clsx`, `tailwind-merge`, `tailwindcss-animate`, `@tailwindcss/typography`, `tailwind-scrollbar-hide` | `tailwind-variants` |
| Components | **add** `@radix-ui/react-dropdown-menu`, `@radix-ui/react-radio-group`, `@radix-ui/react-switch`, `@radix-ui/react-progress`, `cmdk` | `@mui/material` components (the package itself stays installed **only** because `@mui/x-charts` depends on it, as do `@emotion/*`; no `ui` file and no non-chart file may import it), `@mui/x-data-grid`, `primereact`, `@headlessui/react` |
| Dates | `react-day-picker` (already a dependency), `date-fns`, `date-fns-tz` | — |
| Icons | `lucide-react`, local SVGs in `src/assets/icons` (brand marks and illustrations; a missing brand logo becomes a local SVG) | `react-icons`, `@heroicons/react`, `@radix-ui/react-icons` |
| Feedback | `react-toastify` (restyled) | `react-loading-skeleton`, `react-spinners` |
| Charts | unchanged (out of scope); use `chartSeries` from `palette.ts` | — |
| Catalog / lint | **add** `storybook@10.6.x` (exact pin) + `@storybook/react-vite`, `@storybook/addon-a11y`, `@storybook/addon-docs`; **add** `eslint-plugin-jsx-a11y` | — (no `@storybook/addon-vitest`) |

---

## 5. Catalog, guards, lint

### 5.1 Storybook

- `.storybook/main.ts`: framework `@storybook/react-vite`, stories `src/components/ui/**/*.stories.tsx` + `src/design-system/docs/**/*.mdx`, addons `a11y` and `docs`. `viteFinal` **filters out `VitePWA`**.
- `.storybook/preview.tsx` imports `src/index.css`, loads Raleway as `index.html` does, and has decorators for `MemoryRouter` and the toast container. **Toolbars:** viewports 390 / 768 / 1200, and a `[data-theme]` switcher (`neutral`, `marine`, `yellow`; `.dark` later).
- **Coverage rule:** every component file in `src/components/ui` has a colocated `*.stories.tsx` with one story per variant and per look-changing state. Autodocs and controls are on.
- **CI:** `build-storybook` runs on PRs that touch `src/components/ui/**`, `src/design-system/**`, `src/styles/tokens.css`, `tailwind*` or `.storybook/**`.
- **Smoke tests:** `src/components/ui/stories.test.tsx` iterates over all stories with `composeStories` (`@storybook/react`) and renders each one in Vitest 3/jsdom.
- **Not published.** Publishing is decided when a designer or reviewer needs it. The vitrine (`/dev/vitrine`) stays for feature screens that need fake API/auth data.

### 5.2 `src/design-system/guard.test.ts`

Source scanning, in the style of `semComponenteNoRender.test.ts`. It runs in **ratchet mode inside the migration branch** (counts may only go down, with today's counts as the baseline) and is **strict (zero) from the cleanup commit on**. It fails on:

1. **Legacy color utilities:**
   - flat brand names (`marine`, `grey`, `darkGrey`, `lightGray`, `gray2`, `backgroundGrey`, `backgroundMarine`, `orange`, `darkOrange`, `yellow`, `lightYellow`, `pink`, `green`, `lightGreen`, `green2`, `green3`, `darkGreen`, `red`, `redError`, `purple`, `blueGeo`, `logo*`);
   - any Tailwind default color family with a shade (`gray-500`, `blue-600`, …);
   - arbitrary colors (`[#…]`, `[rgb(…)]`).

   `white`, `black`, `transparent`, `current` and `inherit` are allowed.
2. **Legacy sizes:** `text-xs…text-9xl` (after cleanup they don't compile anyway), `text-[…]`, `font-thin`, `font-light`, `font-black`.
3. **Arbitrary spacing and z-index:** `p|px|py|pt|pr|pb|pl|m|mx|my|mt|mr|mb|ml|gap|gap-x|gap-y|space-x|space-y-[…]`, `z-[…]`.
4. **Flagged elevation and radius:** `shadow-xl|2xl|inner`, and `rounded-2xl|3xl` outside `src/pages/homeV2` and `src/pages/quemSomos`.
5. **`text-hero` outside the home hero.**
6. **Banned imports:** `@mui/material` and `@mui/x-data-grid` outside chart files, `primereact`, `@headlessui/react`, `tailwind-variants`, `react-icons`, `@heroicons/react`, `@radix-ui/react-icons`, `react-loading-skeleton`, `react-spinners`, and any import from the deleted V1 kit paths.
7. **Frozen folders:** any new file under `src/components/{atoms,molecules,organisms,templates}`. The allowed list is today's file list, shrinking as files move or are deleted.
8. **Missing stories** for a component file in `src/components/ui`.
9. **`/* ds-review */` markers** anywhere (codemod leftovers, §7.3).
10. **Absorbed from `dashV2/tokens.test.ts`:** `cta-foreground` is white, and `ui` uses only semantic tokens.

### 5.3 `src/design-system/contrast.test.ts`

This test parses `src/styles/tokens.css` (`:root` plus each `[data-theme]`), resolves the `var()` chains to hex, and asserts WCAG 2.x contrast:
- **≥ 4.5:1** for every text pair (`X-foreground` on `X`; `foreground`, `muted-foreground`, `destructive`, `success`, `warning`, `info` and `highlight` on `background`/`page`/`card`/`muted` and on their own `*-muted`);
- **≥ 3:1** for `input`/`ring` on `background` and for each `chart-*` on `background`.

It also checks that `palette.ts` equals the CSS primitives.

### 5.4 ESLint

`yarn lint` is broken on `develop` (ESLint 9 with the legacy `.eslintrc.cjs`). The PR migrates it to **`eslint.config.js`** (flat config: typescript-eslint, react-hooks, react-refresh as before) and adds **`eslint-plugin-jsx-a11y` (recommended)**. It runs at `warn` inside the branch and switches to **`error` in the cleanup commit**. Violations are fixed in the component-family commits.

---

## 6. Guidelines (MDX in `src/design-system/docs/`)

| Page | Content |
|---|---|
| Foundations / Colors | `ColorPalette` of primitives and semantic tokens, a contrast table, `[data-theme]` overrides |
| Foundations / Typography | `Typeset` of every step at both widths, `prose` vs `body`, the 12px minimum, the weights loaded |
| Foundations / Spacing, Radius, Shadows, z-index, Layout, Breakpoints | the §2.5–2.6 tables, plus "our `sm` = Tailwind `md`" |
| **Voice and writing** | Friendly and direct, with **"você"**. **Sentence case** everywhere. **Buttons start with a verb and name the object** ("Excluir prova"; never "OK"/"Sim"/"Confirmar" alone). "!" only for real celebrations. No codes or jargon. UPPERCASE only via `text-overline`. **pt-BR formats** via `Intl`/`date-fns-tz` (`America/Sao_Paulo`): `12/11/2026` in tables and forms, `12 de novembro de 2026` in prose, "há 3 dias", `1.284`, `7,5`, no "1.2k" in admin. **Empty state** = what's missing + why (filters?) + an action. |
| **Errors** | **What happened + what to do** ("Não foi possível salvar a prova. Verifique sua conexão e tente de novo."), with no blame and no "Erro ao". **Field errors under the field**, never in a toast, stating the rule ("Ano deve ter 4 dígitos."). Toasts only for things with no place on screen. Screen-blocking errors = inline `Alert` + "Tentar de novo". It applies to new code and touched screens. The migration PR keeps existing wording. |
| **Accessibility** | The decided rules (AA contrast, 12px minimum, solid ring, 3:1 inputs, 44px mobile targets, Radix focus management, required markup), plus: one `h1` per page with no skipped levels; every control in a `Field`; icon-only buttons need `aria-label` (TS-required); color is never the only signal; meaningful `alt` or `alt=""`; no clickable `div`/`span`; visible focus; `prefers-reduced-motion` skips GSAP/Motion page and section animations (spinners and skeleton pulse stay); `lang="pt-BR"`. Enforced by the axe panel + jsx-a11y. |
| **Responsiveness** | Tables → cards, full-screen dialogs, 44px targets. **Nav:** under 768, the public menu and the dash sidebar open as a **left Sheet** from a header hamburger (replaces `organisms/menuMobile`), closing on Esc, outside tap and navigation. **Forms:** single column, labels above, actions full width at the bottom with the main action on top, a sticky action bar on long forms (inscription steps). Correct `type`/`inputMode`/`autoComplete`. **Nothing hover-only.** |
| **Usage rules** | At most one `cta` per screen · borders for in-page surfaces, shadows only for floating elements · `StatusBadge` dot in tables and lists, tint elsewhere · `prose` for reading, `body` for UI · `muted-foreground` is the only secondary text color · red asterisk for required fields · error/warning toasts persist, success/info close after 5s · underline tabs only · 12px minimum · `text-hero` home-only, `text-display` for home/marketing section titles. |
| Usage pages | DataTable, DatePicker, Dialog: when to use, when not to, and mobile behavior. |

---

## 7. Migration: one PR

### 7.1 Ground rules

- **One PR into `develop`** covering everything: about 519 of 1,327 non-test source files.
- **No bridges:** every V1 use is replaced directly. All retired dependencies are removed. **The guard is strict from the merge.**
- **Ordered commits, one per step, each green on its own** (`tsc`, lint, vitest, `vite build`; plus `build-storybook` once commit 4 lands). The PR is **merged with a merge commit (no squash)**.
- **Branch from a fresh `develop`, rebase daily, and re-run the codemods after each rebase.** The two authors agree on a **2–3 day UI freeze** for final QA and merge.
- **Scope rule: parity plus the decided improvements only.** The improvements are the a11y fixes, toast timing, mobile cards and full-screen dialogs, the 44px targets and the guideline-driven markup. **Bugs found along the way are logged as issues, not fixed**, unless the swap itself fixes them. **Tests are adapted, never deleted** (including `chamada.test.tsx`, `permissoesDaTurma.test.tsx` and the other DataGrid-screen tests, with their behavior assertions intact).
- **Rollback:** `git revert -m 1 <merge>`, or revert a single step commit. **Release:** the normal flow after homologation sign-off, with a short "what changed" note for cursinho coordinators.

### 7.2 Commit order

1. **Phase 0:** Tailwind config fix. Colliding flat colors become `{ ...defaultScale, DEFAULT }`, and `animation`/`keyframes`/`backgroundImage` move into `extend`. The 302 dead classes, `animate-spin`/`pulse` and gradients come back.
2. **Tokens:** `src/styles/tokens.css` (§2.2), semantic Tailwind map, `tailwind/type-scale.js`, radius/shadows/z-index/widths/container/`--header-h`, `brand-stripe`, `prose` config, Raleway weights in `index.html`, zinc `:root`/`.dark` removed from `index.css`, `src/lib/palette.ts`.
3. **Lint and guards:** ESLint flat config + jsx-a11y (`warn`); `guard.test.ts` (ratchet, baseline = current counts); `contrast.test.ts`.
4. **Storybook:** `.storybook/`, MDX foundation and guideline pages (§6).
5. **`ui` components** (§3), each with stories, plus the stories smoke test. `DataTable`, `StatusBadge`, `DateRangePicker` and `TableSkeleton` move in from dashV2.
6. **Codemod sweeps**, one commit each (§7.3): colors → semantic; sizes → steps; weights; radius/shadow/z-index; arbitrary values; icons → lucide.
7. **Component families**, one commit each (§7.4): V1 `Button`; `ModalTemplate`/`ModalConfirmCancel`/`ModalTabTemplate`/`AlertDialogUI`/hand-rolled overlays → Dialog/AlertDialog/Sheet; V1 `Text` → step classes; V1 inputs (`InputFactory` family, `atoms/select`, checkbox/radio/toggle) → `Field` + controls; MUI by family; **one commit per DataGrid screen → `DataTable`**; PrimeReact → DatePicker/Select; headlessui → DropdownMenu; loaders → Skeleton/Spinner; toast setup; mobile nav (left Sheet); jsx-a11y violations fixed alongside.
8. **dashV2 split:** the template, toolbar, filter bar and footer use `ui`. `dashV2/tokens.ts` and `tokens.test.ts` are deleted. The `dashV2/README.md` rule "`components/ui/*` não são editados" is **replaced** by a pointer to this design system.
9. **Home expressive layer:** `[data-theme]` overrides, `highlight`, `text-hero`/`text-display`, `brand-stripe` (header and footer stripe, SupportInbox bar), `sectionThemes.css` removed, `pink`/`green` themes removed from `SectionTheme`, home hex mapping (§7.3).
10. **Cleanup:**
    - delete the V1 kit files and `scripts/ds-codemods/`;
    - remove the legacy color names and the default `fontSize` from the Tailwind theme;
    - remove the retired dependencies;
    - set the **guard to strict (zero)** and **jsx-a11y to `error`**;
    - the atomic folders stay frozen.

### 7.3 Codemod mapping (`scripts/ds-codemods/`)

The rules apply to `className` strings, `cn()`/`clsx()` arguments, cva definitions and `tv()` definitions. **Rows marked `review` are not rewritten.** The codemod appends `/* ds-review: <reason> */` next to them, and they are resolved by hand in the same sweep commit (the guard fails while any marker remains). Variants (`hover:`, `md:`, `/opacity`) are preserved; for example, `hover:bg-gray-100` becomes `hover:bg-muted`.

**Responsive size pairs collapse.** Patterns like `text-lg md:text-xl` map the *base* class to its step and drop the prefixed size, because steps are responsive themselves.

#### Text color

| Legacy | → |
|---|---|
| `text-marine`, `text-[#0b2747]`, `text-gray-900/800/700`, `text-slate-900/800/700`, `text-zinc-900/800`, `text-black` (on light) | `text-foreground` |
| `text-grey`, `text-darkGrey`, `text-gray-600/500`, `text-slate-600/500`, `text-zinc-500/600` | `text-muted-foreground` |
| `text-gray-400`, `text-slate-400`, `text-gray2` | **review** (placeholder → `muted-foreground`; disabled → parent `opacity-50`) |
| `text-red`, `text-redError`, `text-red-500/600/700`, `text-rose-600/700` | `text-destructive` |
| `text-green2`, `text-green3`, `text-darkGreen`, `text-green-600/700`, `text-emerald-600/700`, `text-[#0d7a63]` | `text-success` |
| `text-amber-600/700`, `text-yellow-600/700` | `text-warning` |
| `text-[#b35300]` | **review** (KPI "attention" → `text-warning`; link-like → `text-primary`) |
| `text-blue-*`, `text-sky-*`, `text-indigo-*` | **review** (link → `text-primary underline`; info → `text-info`; decoration → `palette`) |
| `text-orange`, `text-darkOrange`, `text-orange-*` | **review** (eyebrow → `text-highlight`; emphasis → `text-foreground font-semibold`; never orange text on white below AA) |
| `text-green` (mint), `text-[#37d6b5]`, `text-pink`, `text-[#da005a]`, `text-rose-*` (other), `text-fuchsia-*`, `text-purple*`, `text-lightGreen` | **review** (home highlight → `text-highlight`; otherwise the nearest AA step via `palette`) |
| `text-white` | unchanged (allowed); inside `bg-primary`/`bg-cta`/status solids, prefer `text-*-foreground` (manual) |

#### Background

| Legacy | → |
|---|---|
| `bg-backgroundGrey`, `bg-gray-50`, `bg-slate-50`, `bg-zinc-50` | `bg-page` |
| `bg-gray-100/200`, `bg-slate-100/200`, `bg-lightGray`, `bg-zinc-100` | `bg-muted` |
| `bg-marine`, `bg-[#0b2747]` | `bg-primary` (on the home page: the section's `data-theme="marine"` instead → review) |
| `bg-backgroundMarine`, `bg-[#001b3a]` | **review** → `data-theme="marine"` section |
| `bg-orange`, `bg-darkOrange` (buttons) | `bg-cta` (+ `text-cta-foreground`) |
| `bg-red`, `bg-red-500/600`, `bg-redError` | `bg-destructive` |
| `bg-red-50/100`, `bg-rose-50/100` | `bg-destructive-muted` |
| `bg-green2`, `bg-green3`, `bg-darkGreen`, `bg-green-500/600`, `bg-emerald-500/600` | `bg-success` |
| `bg-green-50/100`, `bg-emerald-50/100`, `bg-[#edfef8]` | `bg-success-muted` |
| `bg-yellow-50/100`, `bg-amber-50/100`, `bg-lightYellow` | `bg-warning-muted` |
| `bg-blue-50/100`, `bg-sky-50` | `bg-info-muted` |
| `bg-black/50`, `bg-black/65` (overlays) | removed with the overlay → Dialog scrim |
| `bg-blue-500/600`, `bg-amber-400/500`, `bg-yellow`, `bg-green` (mint), `bg-[#37d6b5]`, `bg-[#2bbfa1]`, `bg-pink`, `bg-[#da005a]`, `bg-purple`, `bg-lightGreen`, `bg-gray-300+`, other solids | **review** (status solid → `bg-<status>`; decoration → `palette` or home theme) |
| `bg-white` | unchanged (allowed); surfaces in `ui` use `bg-card`/`bg-background` |
| `bg-custom-gradient` | `bg-brand-stripe` |
| `bg-right-gradient` | **review** → `bg-success` swatch |

#### Border, ring, outline, divide

| Legacy | → |
|---|---|
| `border-lightGray`, `border-gray-100/200/300`, `border-slate-200/300`, `border-zinc-200`, `divide-gray-*` | `border-border` / `divide-border` |
| `border-gray-400+`, `border-grey` (on fields) | `border-input` |
| `border-marine` | `border-primary` |
| `border-orange` | `border-cta` |
| `border-red*`, `border-redError` | `border-destructive` |
| `border-green2`, `border-green-*` | `border-success` |
| `ring-orange*`, `ring-blue-500/30`, `outline-orange`, `focus:ring-*`, `focus-visible:ring-*` | `focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2` |
| `border-2` (V1 buttons) | removed with V1 Button |

#### Type

| Legacy | → |
|---|---|
| `text-xs`, `text-[10px]`, `text-[11px]`, `text-[9px]`, `text-[0.65rem]`, `text-[0.8rem]` | `text-caption` |
| `text-sm` | `text-body` |
| `text-base` | **review** (long reading → `text-prose`; UI → `text-body`) |
| `text-lg` | `text-h3` |
| `text-xl` | `text-h2` |
| `text-2xl` | `text-h1` |
| `text-3xl` | `text-h1` (home section titles → `text-display`) |
| `text-4xl`, `text-5xl` | **review** (home → `text-display`; other → `text-h1`) |
| `text-6xl…8xl` (hero) | `text-hero` |
| `text-[28px]` (KPI numbers) | `text-numeric` |
| `text-[150px]`, `text-[6rem]`, `text-[8rem]` (icons, illustrations) | **review** (icon `size` prop / `w-*`) |
| `font-thin`, `font-light` | `font-normal` |
| `font-black` | `font-extrabold` |
| `leading-*`, `tracking-*` next to a mapped size | removed (the step defines them); keep `tracking-wide` on table headers → `text-caption` |

#### Radius, shadow, z-index, sizes

| Legacy | → |
|---|---|
| `rounded` | `rounded-sm` |
| `rounded-2xl`, `rounded-3xl` outside home/quemSomos | `rounded-xl` |
| `shadow` | `shadow-sm` (on cards and in-page surfaces: removed → **review**) |
| `shadow-xl`, `shadow-2xl` | `shadow-lg` |
| `shadow-inner`, `shadow-[…]` | **review** |
| `z-10` / `z-20` / `z-30` / `z-40` / `z-50` | `z-raised` / `z-sticky` / `z-header` / `z-overlay` / `z-popover` |
| `z-[N]` | **review** → nearest layer |
| `p/m/gap-[Npx]` | the matching scale step (`[48px]` → `12`, `[56px]` → `14`, `[96px]` → `24`); values with no step (`[52px]`, …) → **review** |
| `max-w-[500px]`, `[600px]`, `[90vw]` on modals | removed → Dialog `size` |
| `calc(100vh-76px)`, `calc(100vh-88px)` | `calc(100vh-theme(spacing.header))` |
| other `w/h/min/max-[…]` | unchanged unless a layout token fits (`max-w-prose-content`, `max-w-form`, `max-w-page`) → review list in the PR |

#### Icons

- `react-icons/fi` (Feather) and `react-icons/lu` map to the **same-named lucide icon** (`FiX` → `X`, `FiTrash2` → `Trash2`, `LuPlus` → `Plus`).
- Heroicons and Radix icons map to the lucide equivalent by name (`XMarkIcon` → `X`, `ChevronDownIcon` → `ChevronDown`).
- Other react-icons packs (`md`, `fa`, `io`, `bs`, `ai`, `bi`, …) are **review**: pick the lucide equivalent, or a local SVG for brand logos (WhatsApp, Instagram, …). The PR lists the chosen pairs.
- `size`/`className` props are kept, and size is expressed as `h-4 w-4` (16) / `h-5 w-5` (20).

#### Home hard-coded colors (ticket 14)

| Today | → |
|---|---|
| `#37d6b5` | mint-400 for decoration and highlights on navy (`text-highlight` in marine); as text on light → mint-700 |
| `#0b2747` | marine theme tokens |
| `#da005a`, `#da005a22` | pink-600 (`palette`); tint → pink-50 |
| `#2bbfa1` | mint-500 |
| `#001b3a` | marine-950 |
| `#f7b733` | decoration → yellow-400; eyebrow → `text-highlight` (yellow-700 in the yellow theme) |
| `#fff5f8`, `#edfef8` | pink-50, mint-50 (pink/green themes retired) |
| raw hex in charts and inline styles (~288) | `palette.*` / `chartSeries` (nearest step; text on light must pass AA) |

### 7.4 Component mapping

| Legacy | → design system |
|---|---|
| V1 `Button` `typeStyle="primary"` (and the default) | `Button variant="primary"`. **The single most important action of the screen** (create/publish/submit) → `variant="cta"`, chosen by hand per screen |
| `typeStyle="secondary"` / `quaternary` | `variant="outline"` |
| `typeStyle="accepted"` | `variant="primary"` |
| `typeStyle="refused"` | `variant="destructive"` |
| `typeStyle="none"` | `variant="ghost"` |
| `size="base"` (`w-full h-12`) / `size="small"` | `size="lg"` + `className="w-full"` / `size="sm"` |
| shadcn `Button` default (zinc) | unchanged API; now renders `primary` (marine) |
| `templates/modalTemplate` | `Dialog` (`size` from today's width: ≤ 420 `sm`, ≤ 600 `md`, ≤ 840 `lg`, otherwise `full`) |
| `organisms/modalConfirmCancel`, `modalConfirmCancelMessage`, `atoms/alertDialogUI` | `AlertDialog` (button names the action) |
| `organisms/modalMessage` | `Dialog size="sm"` |
| `templates/modalTabTemplate` | `Dialog` + `Tabs` |
| hand-rolled `fixed inset-0` overlays (20 files) | `Dialog` or `Sheet` (review each) |
| V1 `Text` `size` primary / secondary / tertiary / quaternary | `text-display` (home) or `text-h1` / `text-h1` / `text-h3` / `text-h4`, on a real `h1`–`h4` chosen per page (one `h1`) |
| `organisms/inputFactory` + `atoms/inputText` + `templates/baseLayoutInput` (floating label) | `Field` + `Input`/`Textarea`/`Select`/`Checkbox` (label above; the floating label retires) |
| `atoms/input` + `molecules/formField` | `Field` + `Input` |
| `atoms/select` (native), `atoms/selectOption`, `molecules/selector`, `molecules/seletorDeCursinho`, `atoms/inputSelect` (PrimeReact) | `Select` (searchable → `Combobox`) |
| `atoms/checkbox`, `atoms/inputCheckbox`, `atoms/checkMapFilter` | `Checkbox` |
| `atoms/radioButton` | `RadioGroup` |
| `atoms/toggle`, `atoms/permissionToggle` | `Switch` |
| `molecules/tipoDeEnvio` (segmented) | **review**: `RadioGroup` (cards) or `Tabs` |
| `atoms/tooltip` | `Tooltip` |
| `atoms/dropdownMenu` (headlessui) | `DropdownMenu` |
| `atoms/cursinhoAccordin`, MUI `Collapse` | `Accordion` |
| `organisms/paginationWrapper` | `Pagination` |
| `organisms/*Skeleton` (react-loading-skeleton), MUI `Skeleton` | `Skeleton` compositions |
| react-spinners `MoonLoader`, MUI `CircularProgress`, `Loader2 animate-spin` ad hoc | `Spinner` |
| MUI `LinearProgress` | `Progress` |
| MUI `Button` contained / outlined / text, `color="error"` | `Button` primary / outline / ghost, destructive |
| MUI `IconButton` | `Button size="icon" variant="ghost"` + `aria-label` |
| MUI `TextField` | `Field` + `Input` |
| MUI `Select` + `MenuItem` | `Select` |
| MUI `Autocomplete` | `Combobox` |
| MUI `Checkbox`/`Radio`/`RadioGroup`/`Switch`/`FormControlLabel` | `Checkbox`/`RadioGroup`/`Switch` inside `Field` |
| MUI `Typography` h3 / h4 / h5 / h6 / subtitle1 / subtitle2 / body1 / body2 / caption | `text-h1` / `text-h2` / `text-h3` / `text-h4` / `text-h4` / `text-label` / `text-body` / `text-body` / `text-caption` on semantic elements |
| MUI `Tooltip` | `Tooltip` |
| MUI `Chip` | `StatusBadge` (status) or `Badge` |
| MUI `Paper` | `Card` |
| MUI `Table*` | `Table` (or `DataTable` when sorting/paging) |
| MUI `DataGrid` (8 screens) | `DataTable`: `checkboxSelection` → `selection`; `paginationMode="server"` + `onPaginationModelChange` → `pagination` (server); `onSortModelChange` → `onSortChange`; `renderCell` → column `cell`; `disableRowSelectionOnClick` → default; `pageSizeOptions` → `pagination.pageSizeOptions` |
| MUI `ToggleButtonGroup` (as tabs) | `Tabs` |
| PrimeReact `Calendar`, `atoms/controlCalendar` | `DatePicker` (ranges → `DateRangePicker`) |
| PrimeReact `Dropdown` | `Select` |
| dashV2 `DashTable` / `StatusBadge` / `DashDateRangeFilter` / `DashTableEmpty` skeletons | `ui/data-table`, `ui/status-badge`, `ui/date-range-picker`, `ui/skeleton` (`TableSkeleton`) |
| `organisms/menuMobile`, dash sidebar on mobile | left `Sheet` from the header hamburger |
| `components/ui/accordion.tsx` (unused) | adopted; `ui/form.tsx` deleted |
| V1 kit dead code (`atoms/{a4Page, barChart, …}`, `templates/dashCardTemplate`) | deleted in cleanup |

### 7.5 Verification

1. **CI:** `tsc`, `eslint` (flat config + jsx-a11y), `vitest` (existing suites + guard + contrast + story smoke tests), `build-storybook`, `vite build`.
2. **Visual before/after:** a script screenshots **every `/dev/vitrine/:componente/:estado`** at **390 and 1280** on `develop` and on the branch (headless Chrome via the repo's `puppeteer`), and writes a side-by-side HTML report. Each pair is reviewed. Storybook covers `ui` itself.
3. **Homologation checklist** (written once, kept in `src/design-system/docs/qa-checklist.mdx`), walked during the freeze at desktop and 390 width, keyboard-only for the starred items:
   - **Public:** home (all sections, hero, marine CTA, stripe) · quem somos · cursinho map and public cursinho page · cursinho registration (`Geo`) · login/register/forgot ★ · confirm-enrollment page.
   - **Student:** inscription steps 1–3 ★ (asterisks, sticky bar, mobile keyboards) · taking a simulado ★ · simulation history and report · account/profile · chat widget.
   - **Admin:** provas list (DataTable, dot badges, row menu, mobile cards) ★ · question editor (`dashQuestionNew` tabs, rich text) · content/frentes · class with students and attendance modals (ex-DataGrid: selection, server pagination) ★ · students enrolled (server sort/pagination, export) · inscription student manager · analytics (charts with `chartSeries`) · news, push, roles, collaborators · every confirm dialog (AlertDialog naming the action) ★.
   - **Cross-cutting:** toasts (error persists, success closes after 5s, max 3) · focus ring visible everywhere ★ · mobile nav Sheet ★ · reduced-motion on the home page.

---

## 8. Out of scope

- The **Figma** library from #343. Code is the source of truth, and Figma may mirror this spec later.
- **Dark-mode** token values. The structure allows them.
- Chart-library consolidation (only `chartSeries` colors are in scope).
- Promoting `DashListTemplate` to a design-system pattern (after V1 is gone).
- Publishing Storybook.
- Rewriting existing toast and error wording (new and touched code only).
- Bugs found during the migration: logged, not fixed in the PR.
