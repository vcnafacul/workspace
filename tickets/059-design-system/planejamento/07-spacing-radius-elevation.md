---
title: Spacing, radius, shadows and breakpoints
type: grilling
status: closed
assignee: GessioMori
blocked_by: [01]
---

## Question

What are the spacing, radius, shadow and breakpoint tokens?

- Spacing: keep Tailwind's 4px scale with a recommended subset, or define a named scale?
- Radius: shadcn uses `--radius: 0.5rem`, and V1 has its own. Which steps exist (sm/md/lg/full)?
- Shadows: how many levels, and when do we use a shadow versus a border (dashV2: borders in listings)?
- Breakpoints: keep the custom `sm 768 / md 1200 / lg 1400 / xl 1565`, or return closer to Tailwind defaults? What would migrating cost?
- Layout grid and the page gutters per breakpoint.

The values are delivered as static Tailwind theme entries (`spacing`, `boxShadow`, `screens`). Only `--radius` stays a CSS variable ([How tokens are structured](04-token-architecture.md)).

## Resolution

Decided in a grilling session on 2026-10-28, based on [Current UI inventory](01-ui-inventory.md) §4. All values are static Tailwind theme entries, except the `--radius` and `--header-h` CSS variables ([How tokens are structured](04-token-architecture.md)).

- **Spacing: keep Tailwind's 4px scale** and document a subset. **Component spacing** is `0.5, 1, 1.5, 2, 3, 4, 6, 8` (2–32px), which is what ~4,500 existing padding, margin and gap uses already cluster on. **Layout spacing** is `10, 12, 16, 20, 24` (40–96px). Other steps keep working but are not used in design-system components. Arbitrary `p-[Npx]`/`m-[Npx]`/`gap-[Npx]` are banned in new code by the guard test. A named scale and a restricted theme were rejected (churn with no visual gain).
- **Radius:** `--radius` stays `0.5rem`. Each step has one job:

  | Step | Size | Used for |
  |---|---|---|
  | `rounded-sm` | 4px | checkboxes, small chips, inner elements |
  | `rounded-md` | 6px | buttons, inputs, selects, menu items |
  | `rounded-lg` | 8px | cards, popovers, menus, toasts, alerts |
  | `rounded-xl` | 12px | modals, sheets |
  | `rounded-full` | — | pills, badges, avatars, dots |

  `rounded-2xl`/`3xl` and one-sided corners are only for the home expressive layer.
- **Shadows: elevation means floating.** In-page surfaces (cards, tables, panels) get a 1px `border` and **no shadow**, which generalizes dashV2's rule. `boxShadow` is replaced by three **marine-tinted** levels (based on `rgba(11,39,71,…)`, as in the student dashboard's existing shadow). Exact shadow values are set when the components prototype renders them.

  | Level | Used for |
  |---|---|
  | `shadow-sm` | sticky headers and toolbars while scrolling |
  | `shadow-md` | dropdowns, popovers, menus, toasts, tooltips |
  | `shadow-lg` | modals, sheets, dialogs |

  `shadow-xl`/`2xl`/`inner` are flagged by the guard test.
- **Breakpoints: the custom screens stay.** `sm` 768 is the mobile/desktop split (the type scale switches here too). `md` 1200 is full desktop. `lg` 1400 and `xl` 1565 are only for wide-screen adjustments. No `xs` is added. Switching to Tailwind's defaults was rejected: ~960 responsive classes (`sm:` 570, `md:` 352), 69 files with JS width checks (`useAcimaDeSm`, `matchMedia`) and ~30 CSS media queries depend on these widths, and the names would silently change meaning. The design-system docs must note that **our `sm` = Tailwind's default `md`**, so shadcn examples need translating.
- **Layout tokens:**
  - **Page gutter** (`container` padding): 16px under 768, 24px from 768, 32px from 1200.
  - **Content widths** (`maxWidth`): `max-w-prose-content` 720px (reading: questions, materials, news), `max-w-form` 560px (forms, modal bodies), `max-w-page` 1200px (public-site container). Admin screens are full width inside the dash shell.
  - **Dialog widths** come from the Dialog component's `size` prop: `sm` 400, `md` 560, `lg` 800, `full`. They replace the arbitrary `max-w-[500px]`/`[600px]`/`[90vw]` modal widths.
  - **`--header-h`** is a CSS variable: 76px, and 88px from 768. It replaces the 17 hard-coded `calc(100vh-76px|88px)` and the `scroll-margin-top: 76px` in `index.css`. It's the same kind of exception as `--radius` (it feeds `calc()`).

  Exact pixel values may still be tuned in the components prototype. That these tokens exist is decided.
- **z-index: named layers** in Tailwind's `zIndex`, replacing `z-0…50`:

  | Token | Value | Used for |
  |---|---|---|
  | `z-base` | 0 | |
  | `z-raised` | 10 | elements lifted inside a component |
  | `z-sticky` | 20 | sticky headers and toolbars |
  | `z-header` | 30 | app header and sidebar |
  | `z-overlay` | 40 | modal/sheet backdrop + content |
  | `z-popover` | 50 | dropdowns, selects, popovers, tooltips; above modals so they work inside them |
  | `z-toast` | 60 | toasts, including the react-toastify container (replacing 9999) |

  shadcn components get the right token. Arbitrary `z-[N]` (today `60`, `70`, `500`, `600`, `1400`) is banned in new code.
- **Border width:** 1px everywhere. 2px only for the focus ring and selected states (for example a selected question alternative). V1's `border-2` buttons retire with V1.

