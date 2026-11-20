---
title: Expressive layer for the home page
type: prototype
status: closed
assignee: GessioMori
blocked_by: []
---

## Question

How do the public site and home page sit on the token foundation? The mechanism is decided in [How tokens are structured](04-token-architecture.md): `[data-theme]` re-points semantic tokens.

- Which semantic tokens each section theme (`marine`, `pink`, `green`, `yellow`, `neutral`) overrides. The [Color palette](05-color-palette.md) prototype's marine and pink overrides are the starting point.
- **CTA inside dark sections:** keep white on `#B35300` (poor separation from navy), or switch to bright `#FF7600` with marine text inside dark themes only?
- The rainbow `custom-gradient` (mint → lime → yellow → orange → pink) and `right-gradient`: keep as an expressive token, rework onto the new scales, or retire?
- `sectionThemes.css`'s `#f7b733` yellow, `#fff5f8` and `#edfef8` tints, and the homeV2 arbitrary hexes (`#2bbfa1`, `#001b3a`, …): which primitive step each maps to.
- Display typography (`text-display` 36 → 60px, weight 800), eyebrows (`overline`), and larger radii (`2xl`/`3xl`) on the home.

The answer lands as commit 9 of the single migration PR ([Migration plan](12-migration-plan.md)). Link a prototype in `prototypes/`, ideally rendering the real home sections' structure.

## Assets

- Prototype: [prototypes/home-expressive.html](../prototipos/home-expressive.html). It mirrors homeV2's real section order and themes, plus quemSomos' yellow sponsors section. Switch with `?variant=A|B|C` or ← →, width with the bar (`?w=mobile`), and the hero headline size with `?hero=60|96`:
  - **A, Faithful:** CTA flips to bright `#FF7600` with marine text on dark; rainbow kept as a thin stripe.
  - **B, Rhythm:** alternating mint and pink tinted sections; CTA `#B35300` with white everywhere.
  - **C, Inverted:** white main action on dark; orange only on light; accent hue per section.

  Facts: only `marine` (hero, about, map), `neutral` (impact, prep courses, news, features) and `yellow` (quemSomos sponsors) are used. `pink`/`green` are defined but unused. `custom-gradient` has 1 use (the SupportInbox top bar), and `right-gradient` 1 (a simulationHistory legend). The hero `h1` goes up to `text-8xl` (96px) on xl screens.

## Resolution

Decided in a prototype session on 2026-10-28 by reacting to [prototypes/home-expressive.html](../prototipos/home-expressive.html). **Variant A ("Faithful")** won. Rejected: B "Rhythm" (alternating mint and pink tinted sections, `#B35300` CTA everywhere) and C "Inverted" (white CTA on dark, orange only on light). This lands as commit 9 of the migration PR ([Migration plan](12-migration-plan.md)).

- **Themes:**
  - **Keep** `marine` (hero, about, map), `neutral` (impact, prep courses, news, features) and `yellow` (quemSomos sponsors). The section rhythm is unchanged.
  - **Retire `pink` and `green`**: they are defined in `sectionThemes.css` but no page uses them.
  - The `--section-bg/fg/accent/accent-soft` variables and `.home-section__eyebrow` are replaced by semantic-token overrides ([How tokens are structured](04-token-architecture.md)) in `src/styles/tokens.css`.
- **New semantic token `highlight`** (+ Tailwind `text-highlight`): the color for section eyebrows (`overline` step) and highlighted words in headlines. It replaces `--section-accent` and is re-pointed per theme.
- **Theme overrides:**

  | Token | `marine` | `neutral` | `yellow` |
  |---|---|---|---|
  | `background` | marine-900 | (global: white) | yellow-50 |
  | `foreground` | white | (global) | (global) |
  | `card` / `muted` | marine-800 | (global) | (global) |
  | `card-foreground` | white | (global) | (global) |
  | `muted-foreground` | marine-200 | (global) | (global) |
  | `border` | marine-700 | (global) | yellow-100 |
  | `primary` / `primary-foreground` | white / marine-900 | (global) | (global) |
  | **`cta` / `cta-foreground`** | **`#FF7600` (orange-500) / marine-900**, 5.62:1 | (global: `#B35300` / white) | (global) |
  | `highlight` | mint-400 | `#B35300` (orange-700) | yellow-700 |
  | `ring` | orange-500 | (global: orange-600) | (global) |

  Bright orange with marine text on navy is the page's strongest brand moment and still passes AA. The muted `#B35300` on navy was rejected.
- **Gradient:**
  - The rainbow (`custom-gradient`: mint → lime → yellow → orange → pink) becomes **`bg-brand-stripe`**, a Tailwind `backgroundImage` entry built from the palette's mint-400 / lime / yellow-300 / orange-500 / pink-600.
  - It is used **only** as a 4px stripe under the header and above the footer, and as the SupportInbox top bar (its one existing use).
  - **`right-gradient` is retired.** Its one use (a simulationHistory legend swatch) becomes a plain `success` swatch.
- **Hero headline: new exception step `text-hero`.** It keeps today's sizes: **48px → 72px from 1200 → 96px from 1565**, line height 1.05, weight 800, −0.01em tracking, `text-wrap: balance`.
  - It is the only step with three sizes, so the type plugin supports it explicitly.
  - **Only the home hero may use it**, enforced by the guard test.
  - It preserves parity with the designed hero. Shrinking to `display` was rejected.
- **Section titles use `display`, retuned to 30px → 48px** (weight 800, line height 1.1, −0.01em). That matches today's `Section.tsx` `text-3xl md:text-5xl font-extrabold`. **This amends [Type scale](06-type-scale.md)** (`display` was 36 → 60px). `display` is for home and marketing section titles, and `text-hero` only for the hero.
- **Hard-coded home colors → nearest palette step, with one rule: text on light backgrounds must pass AA (4.5:1)**, so use the hue's 600/700 step. Decoration (blobs, shapes, stripe, illustrations) and highlights on navy keep the bright steps. These rows go into the spec's mapping table:

  | Today | → |
  |---|---|
  | `#37d6b5` | mint-400 (decoration / highlight on navy); as text on light → mint-700 |
  | `#0b2747` | `foreground` / `background` in marine theme (marine-900) |
  | `#da005a`, `#da005a22` | pink-600; the 22-alpha tint → pink-50 |
  | `#2bbfa1` | mint-500 |
  | `#001b3a` | marine-950 |
  | `#f7b733` (yellow accent) | decoration → yellow-400; eyebrow text → yellow-700 (via `highlight`) |
  | `#fff5f8`, `#edfef8` | pink-50, mint-50 (their themes are retired) |
  | `rose-*`, `fuchsia-*` on home | pink scale, nearest step (AA rule for text) |

- **Motion** (HeroBlobs, ConstellationCanvas, GSAP/Motion section entrances) keeps working, and is skipped under `prefers-reduced-motion` ([Written guidelines](13-written-guidelines.md)).

