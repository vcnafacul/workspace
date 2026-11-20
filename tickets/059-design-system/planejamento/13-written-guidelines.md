---
title: Written guidelines
type: grilling
status: closed
assignee: GessioMori
blocked_by: []
---

## Question

Which usage rules does the design system document? They live as MDX pages in Storybook (`src/design-system/docs/`, per [Permanent component catalog](08-permanent-catalog.md)).

- **Accessibility:** rules beyond what's already decided (AA contrast, 12px minimum, solid focus ring, 3:1 input borders). Cover semantic headings, labels and error association (`aria-describedby`), icon-only buttons need `aria-label`, keyboard reachability, motion (`prefers-reduced-motion`), alt text, and touch target size on mobile.
- **Writing (pt-BR UI copy):** tone of voice (você, informal-friendly vs neutral), button labels (verb first: "Salvar prova"), error messages (what happened + what to do, no blame, no codes), empty states, confirmation dialogs (name the action, not "OK"), toasts (short, no exclamation overload), capitalization (sentence case vs Title Case), numbers and dates (pt-BR formats).
- **Responsiveness:** tables becoming cards, full-screen dialogs and 44px touch targets on mobile are already decided in [Core components visual prototype](10-core-components-prototype.md). Still open: navigation patterns (header/sidebar on mobile), forms on mobile, and the remaining layout guidance.
- **Usage rules** already decided that need one home: at most one `cta` per screen, the red asterisk for required fields, error/warning toasts that persist, borders vs shadows, the dot vs tint `StatusBadge`, `prose` vs `body`, when to use `muted-foreground`.

## Resolution

Decided in a grilling session on 2026-10-28. All guidelines are **MDX pages in Storybook** under `src/design-system/docs/`. Survey of today's copy (`origin/develop`): "você" 123 vs "tu"/imperative-tu 6; sentence-case multi-word labels 96 vs Title Case 29; 20 of 141 literal toasts end in "!"; 31 of 220 `toast.error` calls start with "Erro ao".

**Voice and writing**
- **Friendly and direct, addressing the user as "você".** No impersonal-institutional tone.
- **Sentence case everywhere**: buttons, titles, menus, table headers, tabs ("Salvar alterações", not "Salvar Alterações").
- **Buttons start with a verb and name the object**: "Excluir prova", "Criar turma", "Salvar rascunho". Never "OK", "Sim" or "Confirmar" alone. AlertDialogs repeat the action in title and button.
- **"!" only for real celebrations** ("Inscrição confirmada!"), never in errors or warnings.
- **No codes or jargon for users.** HTTP statuses, stack traces and internal ids go to logs, not toasts.
- **Uppercase only through the `overline` step** (eyebrows), never typed in caps.
- **pt-BR formats through `Intl`/`date-fns-tz` with `America/Sao_Paulo`:**
  - dates `12/11/2026` in tables and forms, `12 de novembro de 2026` in prose;
  - relative "há 3 dias" for recent activity;
  - numbers `1.284` and `7,5`, with no "1.2k" abbreviations in the admin area.
- **Empty states have three parts**: what's missing ("Nenhuma prova encontrada"), why it might be empty ("Tente outros filtros…"), and an action ("Limpar filtros" / "Criar prova").

**Errors**
- **Pattern: what happened + what to do.** "Não foi possível salvar a prova. Verifique sua conexão e tente de novo." The first sentence names the failure without blame and without "Erro ao". The second gives the next step when there is one.
- **Field errors live under the field** (the `Field` error slot, `aria-describedby`), never in a toast. They state the rule ("Ano deve ter 4 dígitos."), without "Por favor" and without a bare "inválido".
- **Toasts are for things with no place on screen**: network and server failures, background jobs, confirmations of actions done elsewhere.
- **Errors that block the whole screen** use an inline `Alert` (destructive) with a "Tentar de novo" action where retrying makes sense.
- **Applies to new code and to screens as they are touched.** The migration PR keeps existing wording (parity rule, [Migration plan](12-migration-plan.md)).

**Accessibility** (in addition to what's already decided: AA contrast, the 12px minimum, the solid focus ring, 3:1 input borders, 44px mobile targets, Radix focus management, required-field markup)
- One `h1` per page, and heading levels never skip.
- Every control is labelled through `Field`. **Icon-only buttons need `aria-label`, enforced as a required prop in TypeScript when `size="icon"`.**
- **Color is never the only signal**: status dots always sit next to text, and errors have an icon and text.
- Content images get a meaningful `alt`. Decorative images get `alt=""`.
- **No clickable `div`s or `span`s.** Interactive things are `button`/`a`, everything is reachable by keyboard, and focus is always visible.
- **`prefers-reduced-motion`** skips GSAP/Motion page and section animations. Spinners and skeleton pulse stay, since they communicate state.
- `lang="pt-BR"` on the document.
- **Enforcement:** the Storybook axe panel (manual), plus **`eslint-plugin-jsx-a11y` (recommended rules) in CI**. **The migration PR fixes the currently broken ESLint setup** (ESLint 9 with legacy `.eslintrc.cjs` → `eslint.config.js` flat config), enables jsx-a11y, and resolves its violations. That counts as accessibility work under the PR's scope rule.

**Responsiveness** (in addition to what's already decided in [Core components visual prototype](10-core-components-prototype.md): tables become cards, dialogs go full-screen, 44px targets)
- **Navigation:** under 768px, **both the public header menu and the dash sidebar open as a left `Sheet`** from a hamburger button in the header. It's shadcn `Sidebar`'s mobile mode, with the same pattern reused for the public menu (it replaces `organisms/menuMobile`). It has a focus trap and closes on Esc, outside tap and navigation.
- **Forms under 768px:**
  - **single column**, labels above fields (never beside);
  - **actions full-width at the bottom, main action on top**, matching full-screen dialogs;
  - long forms (inscription steps) keep a **sticky bottom action bar**.
- **Inputs use the right `type` / `inputMode` / `autoComplete`**: email, tel, numeric for CPF/CEP, `one-time-code`, `name`, `street-address`, …
- **Nothing depends on hover.** Tooltips also open on tap or focus, and hover-revealed actions are always visible on touch.

**Usage rules page**, one place for the rules scattered across tickets:
- at most one `cta` per screen;
- borders for in-page surfaces, shadows only for floating elements;
- `StatusBadge` dot in tables/lists, tint elsewhere;
- `prose` for long reading, `body` for UI;
- `muted-foreground` is the only secondary text color;
- red asterisk for required fields;
- error and warning toasts persist, success and info close after 5s;
- underline tabs only;
- 12px is the minimum text size.

