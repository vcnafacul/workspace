---
title: Color palette
type: prototype
status: closed
assignee: GessioMori
blocked_by: [01]
---

## Question

What is the consolidated color palette?

- The brand primaries and how each one is used (marine, orange, pink, green, yellow).
- Merge the duplicates: `green`/`green2`/`green3`/`darkGreen`/`lightGreen`, `red`/`redError`, `grey`/`gray2`/`darkGrey`.
- Status colors (success, error, warning, info) that pass contrast for text and UI components, building on the dashV2 measurements.
- A neutral gray ramp for surfaces, borders and text.
- A chart color sequence (colors only, not the libraries).
- Contrast table (WCAG 2.x) for the text/background pairs.

Structure is fixed by [How tokens are structured](04-token-architecture.md). The output is:
- **primitive scales** `--<hue>-<step>` (50–950), with the exact brand hex placed on a step;
- a value for **every semantic token**: shadcn's set plus `page`, `cta`/`cta-foreground` (orange/marine), `success`, `warning`, `info` and any extra text level;
- `primary` = marine and `primary-foreground` = white are already decided;
- the `chart-*` sequence;
- the overrides each home `[data-theme]` section needs, or a decision to leave that to the expressive layer.

Link a rough swatch prototype in `prototypes/`.

## Assets

- Prototype: [prototypes/color-palette.html](../prototipos/color-palette.html). Open it in a browser and switch variants with `?variant=A|B|C` or the ← → keys:
  - **A, Brand-led:** status colors come from brand hues; neutrals are tinted marine.
  - **B, Conventional:** green/amber/blue/red for status; pure-gray neutrals.
  - **C, Restrained:** marine + neutrals with orange only for the CTA; status shows as dots and icons.

  Each variant renders the same sample screens through semantic CSS variables only. It also shows the home `[data-theme]` sections, the semantic token table with live WCAG contrast, the generated OKLCH primitive scales (the brand hex sits unchanged on its step), and the nearest primitive for each legacy color.

## Resolution

Decided in a prototype session on 2026-10-28 by reacting to [prototypes/color-palette.html](../prototipos/color-palette.html). Variant **A** reflects every decision below, and B and C are kept as the alternatives that were rejected.

- **Direction: brand-led.** Status hues come from brand colors, and the neutrals are tinted toward marine (OKLCH chroma ≈ 0.018 at marine's hue). "Conventional" (green/amber/blue/red, pure gray) was rejected because it adds non-brand hues. "Restrained" (status shown only as dots) was rejected as the base, but its dot style is kept for dense lists (below).
- **CTA: white text on `#B35300`** (5.06:1), pinned as `orange-700` on the orange scale. **This overturns dashV2's `bg-orange text-marine`** and amends [How tokens are structured](04-token-architecture.md). White on `#FF7600` is only 2.68:1, so light text requires a darker orange. The brand `#FF7600` stays on `orange-500` for charts, illustrations and the home.
- **Status tokens.** Each has a solid color that also works as text and icon color on white and on its own tint (≥ 4.5:1), white `-foreground` for text on that solid, and a `-muted` tint:
  - `success` = mint-700, `success-muted` = mint-50. Mint (the brand "green" `#37D6B5`) now carries meaning.
  - `warning` = yellow-600 (golden brown, 5.4:1; olive yellow-700/800 and an amber shade close to the CTA were rejected), `warning-muted` = yellow-100.
  - `info` = blue-600 (scale anchored on `blueGeo` `#4D8CCB`), `info-muted` = blue-50.
  - `destructive` = red-600 (scale anchored on brand red `#F43535`), `destructive-muted` = red-50.
- **How status is displayed depends on density.** In **tables and lists**, a badge is a neutral pill with a **colored dot** and `foreground` text. In **alerts, banners and standalone badges** (detail pages), it is **tinted** (`*-muted` background, solid-colored title and icon). So `StatusBadge` has two looks, and the context (inside a table or list or not) decides which.
- **Text: two levels only.** `foreground` = marine-900. `muted-foreground` = neutral-600 (6.8:1 on white, 6.0:1 on `muted`). A third, lighter level was rejected because it would only pass on white. `darkGrey`, `grey` and the `gray-*` text classes all collapse into these two.
- **Surfaces:** `background`/`card`/`popover` = white, `page` = neutral-50, `muted` = `secondary` = neutral-100, `accent` (menu and row hover) = marine-100.
- **Borders:** `border` = neutral-200 (decorative dividers, cards and table rows; no contrast requirement). `input` = neutral-400 (3.1:1, meeting WCAG 1.4.11 for field boundaries; today's `lightGray` is ~1.3:1).
- **Focus ring:** solid `ring` = orange-600, 2px, with a 1–2px white offset (4.3:1). dashV2's `ring-orange/40` (~1.5:1) fails and is replaced.
- **Charts:** `chart-1…6` = marine-700, orange-600, mint-600, pink-600, yellow-500, blue-500. **Every series is ≥ 3:1 on white** (WCAG 1.4.11). The vivid brand-bright set was rejected for data. Bright steps stay available as primitives for decoration.
- **Primitive scales:** 8 hues (`marine`, `orange`, `pink`, `mint`, `yellow`, `red`, `blue`, `neutral`), 50–950, generated in OKLCH. Each brand hex sits **unchanged** on its step: marine@900, orange@500 (plus `#B35300` pinned @700), pink@600, mint@400, yellow@300, red@500, blue (blueGeo)@500. The lightness curve puts a neutral 400 at ~3:1 and 600 at ~6.8:1. The generator is in the prototype (`scale()`), and the values below are its output.
- **Legacy colors are all retired**, including the 8 `logo*` colors, `lightGreen`, `purple`, `darkOrange`, `backgroundMarine`, `lightYellow` and `gray2`. Each existing use maps to its nearest scale step (prototype section 5). The forest greens `green2`/`darkGreen`/`green3` become `success`. `red`/`redError` become `destructive`. `grey`/`darkGrey`/`gray-*` text becomes `muted-foreground`. `lightGray` becomes `border`. `backgroundGrey` becomes `page`.
- **Home `[data-theme]` overrides are left to the expressive layer.** The prototype's marine section (marine-900 background, white text, marine-800 cards, mint-400 eyebrow, white `primary`) and pink section (pink-50 background, pink-600 accent) are a starting point, not a decision. That work also decides whether the CTA inside dark sections switches to the bright `#FF7600` with marine text, since `#B35300` on navy stands out poorly.
- **Dark mode:** no values here, which is out of scope.

### Values

#### Primitive scales (variant A, generated in OKLCH; brand hex pinned)

| hue | 50 | 100 | 200 | 300 | 400 | 500 | 600 | 700 | 800 | 900 | 950 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| marine | `#F7FAFF` | `#E8F2FE` | `#D5E2F3` | `#B2C2D7` | `#8699B0` | `#677C96` | `#4D6480` | `#364E6C` | `#203A59` | `#0B2747` | `#04101F` |
| orange | `#FFF9F5` | `#FFF1E9` | `#FFE3D4` | `#FFC5A7` | `#FF9A62` | `#FF7600` | `#C55A00` | `#B35300` | `#662B00` | `#3E1700` | `#1F0800` |
| pink | `#FFF8F9` | `#FFEDEF` | `#FFDADF` | `#FFB0BC` | `#FE6E8E` | `#ED4472` | `#DA005A` | `#A50042` | `#73002C` | `#480018` | `#260009` |
| mint | `#EDFFF9` | `#D5FFF2` | `#AAFEE7` | `#79EED1` | `#37D6B5` | `#00AB8E` | `#00846E` | `#006352` | `#004438` | `#002921` | `#00140F` |
| yellow | `#FFFBE3` | `#FFF8CC` | `#FFF2A6` | `#FFE53C` | `#CCAC00` | `#A78600` | `#856500` | `#674A00` | `#4A3200` | `#301C00` | `#1A0C00` |
| red | `#FFF8F7` | `#FFEDEB` | `#FFDAD5` | `#FFB0A7` | `#FF6E64` | `#F43535` | `#C5131D` | `#99000F` | `#6D0007` | `#460003` | `#270001` |
| blue | `#F6FBFF` | `#E8F3FF` | `#D0E7FF` | `#9DCCFC` | `#6FA6DF` | `#4D8CCB` | `#346CA3` | `#205181` | `#0B3860` | `#002141` | `#001024` |
| neutral | `#F7FAFF` | `#EBF1F8` | `#DAE0E8` | `#B7BEC7` | `#8B939D` | `#6D757F` | `#555B64` | `#40464D` | `#2C3137` | `#1A1E24` | `#0C1014` |

#### Semantic tokens (light)

| token | → primitive | hex | HSL channels |
|---|---|---|---|
| `--background` | white | `#FFFFFF` | `0 0% 100%` |
| `--foreground` | marine-900 | `#0B2747` | `212 73% 16%` |
| `--card` | white | `#FFFFFF` | `0 0% 100%` |
| `--card-foreground` | marine-900 | `#0B2747` | `212 73% 16%` |
| `--popover` | white | `#FFFFFF` | `0 0% 100%` |
| `--popover-foreground` | marine-900 | `#0B2747` | `212 73% 16%` |
| `--primary` | marine-900 | `#0B2747` | `212 73% 16%` |
| `--primary-foreground` | white | `#FFFFFF` | `0 0% 100%` |
| `--secondary-foreground` | marine-900 | `#0B2747` | `212 73% 16%` |
| `--accent-foreground` | marine-900 | `#0B2747` | `212 73% 16%` |
| `--cta` | orange-700 | `#B35300` | `28 100% 35%` |
| `--cta-foreground` | white | `#FFFFFF` | `0 0% 100%` |
| `--destructive-foreground` | white | `#FFFFFF` | `0 0% 100%` |
| `--success-foreground` | white | `#FFFFFF` | `0 0% 100%` |
| `--warning-foreground` | white | `#FFFFFF` | `0 0% 100%` |
| `--info-foreground` | white | `#FFFFFF` | `0 0% 100%` |
| `--page` | neutral-50 | `#F7FAFF` | `218 100% 98%` |
| `--muted` | neutral-100 | `#EBF1F8` | `212 48% 95%` |
| `--muted-foreground` | neutral-600 | `#555B64` | `216 8% 36%` |
| `--secondary` | neutral-100 | `#EBF1F8` | `212 48% 95%` |
| `--accent` | marine-100 | `#E8F2FE` | `213 92% 95%` |
| `--border` | neutral-200 | `#DAE0E8` | `214 23% 88%` |
| `--input` | neutral-400 | `#8B939D` | `213 8% 58%` |
| `--ring` | orange-600 | `#C55A00` | `27 100% 39%` |
| `--destructive` | red-600 | `#C5131D` | `357 82% 42%` |
| `--destructive-muted` | red-50 | `#FFF8F7` | `7 100% 98%` |
| `--success` | mint-700 | `#006352` | `170 100% 19%` |
| `--success-muted` | mint-50 | `#EDFFF9` | `160 100% 96%` |
| `--warning` | yellow-600 | `#856500` | `46 100% 26%` |
| `--warning-muted` | yellow-100 | `#FFF8CC` | `52 100% 90%` |
| `--info` | blue-600 | `#346CA3` | `210 52% 42%` |
| `--info-muted` | blue-50 | `#F6FBFF` | `207 100% 98%` |
| `--chart-1` | marine-700 | `#364E6C` | `213 33% 32%` |
| `--chart-2` | orange-600 | `#C55A00` | `27 100% 39%` |
| `--chart-3` | mint-600 | `#00846E` | `170 100% 26%` |
| `--chart-4` | pink-600 | `#DA005A` | `335 100% 43%` |
| `--chart-5` | yellow-500 | `#A78600` | `48 100% 33%` |
| `--chart-6` | blue-500 | `#4D8CCB` | `210 55% 55%` |
