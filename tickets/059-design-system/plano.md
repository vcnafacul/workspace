# Plano: Design system do client

Tarefas de implementação. Não é fonte de decisões: elas ficam em [`spec.md`](spec.md), que quem executa lê
junto com este plano. Os valores (tokens, tamanhos, mapeamentos) estão na spec e não são repetidos aqui: cada
tarefa diz a seção.

> **Para agentes:** use `superpowers:subagent-driven-development` (recomendado) ou
> `superpowers:executing-plans`, tarefa por tarefa. Os passos usam caixas (`- [ ]`).

**Objetivo:** levar o `client-vcnafacul` inteiro para o design system da spec, num PR só (D14).

**Arquitetura:** os tokens em CSS (`src/styles/tokens.css`) alimentam o Tailwind. Os componentes de
`src/components/ui` (shadcn/Radix + cva) usam só tokens semânticos. O guard, o teste de contraste e o
jsx-a11y mantêm o código no sistema. As telas migram por codemods (classes) e por famílias de componentes
(trocas de JSX), em commits ordenados.

**Tecnologias:** React 19, Vite 6, Tailwind 3.4, TypeScript 5.7, Vitest 3 (jsdom), Radix, cva,
react-day-picker 9, Storybook 10.6 e ESLint 9 (flat config).

**Spec:** `tickets/059-design-system/spec.md` (D1–D22).

## Restrições globais

- **Um PR para a `develop`**, com merge commit, sem squash. Cada commit fica verde sozinho: `tsc`, lint,
  vitest e `vite build`, mais `build-storybook` a partir da Task 4 (spec §7.1).
- **Branch:** `feat/059-01-design-system`, a partir de uma `develop` atual. Rebase diário e codemods rodados
  de novo depois de cada rebase (§7.1).
- **Escopo:** paridade mais as melhorias decididas. Bug encontrado vira issue, não correção. Teste é
  adaptado, nunca apagado; as asserções de comportamento ficam (§7.1).
- **Componentes e telas usam só tokens semânticos.** Os primitivos (`--<hue>-<step>`) não viram utilitário
  do Tailwind (§2.1).
- **Nomes em `ui` em inglês, arquivos em kebab-case.** Código de domínio continua em português (D13).
- **Tamanho mínimo de texto 12px** (`text-caption`). `text-hero` só no hero da home (§2.4).
- **Storybook com versão exata** (`storybook@10.6.x`, sem `^`), sem `@storybook/addon-vitest` (§4).
- **Textos novos seguem a §6** (voz, erros, formatos pt-BR). Textos existentes não mudam (§6, Errors).
- **No client, `yarn test` roda a suíte inteira**, inclusive `DashToolbar.test.tsx`, que o CI pula. Rode-a
  antes de cada push (skill `abrir-pr`).
- **`yarn build` suja `tsconfig.app.tsbuildinfo`:** `git checkout -- tsconfig.app.tsbuildinfo` antes de
  cada commit.

## Pontos de atenção na revisão

Casos que a spec implica e que nenhum teste de tarefa cobriria sozinho. Cada um tem o seu teste na tarefa
indicada.

1. **Classes fora de `className="…"`:** em template literal com condição, em `cn()`/`clsx()` com objeto, em
   `cva` e em `tv()`. O codemod precisa trocar todas, ou o guard vai falhar depois (Task 9).
2. **Celular baixo** (390×640): no Dialog com rodapé fixo, a ação principal tem que continuar visível com o
   teclado fechado. O jsdom não mede layout; a captura da Task 14 inclui essa viewport.
3. **`@/lib/toast`** mantém a API inteira do react-toastify (`toast.promise`, `toast.update`,
   `toast.dismiss`, `toast.isActive`), não só `toast.success`/`toast.error` (Task 8).
4. **DataTable com paginação no servidor:** um filtro que reduz o total para menos que a página atual não
   pode deixar a tela vazia. A tabela volta para a página 1 (Task 7).
5. **`SegmentedControl` dentro de `<form>` e em várias linhas:** Enter e Espaço não enviam o formulário, e as
   setas não pulam para o grupo da linha seguinte (Task 5).

---

## Task 1: Fase 0, conserto do `tailwind.config.js`

**Card:** `tickets/059/01`

**Arquivos:**
- Alterar: `tailwind.config.js`
- Criar: `src/design-system/tailwindConfig.test.ts`

- [ ] **Teste que falha.** Use `// @vitest-environment node`, `resolveConfig` de `tailwindcss/resolveConfig`
  e o `tailwind.config.js`:
  - `theme.colors.red[500]` está definido e `theme.colors.red.DEFAULT === "#F43535"`; o mesmo vale para
    `orange`, `yellow`, `green`, `pink` e `purple`, cada um com o seu hex atual;
  - `theme.animation.spin` e `theme.animation.pulse` estão definidos;
  - `theme.backgroundImage["gradient-to-r"]` está definido.
- [ ] Rode `yarn vitest run src/design-system/tailwindConfig.test.ts` → FAIL (as escalas padrão foram
  sobrescritas).
- [ ] **Implemente.** Envolva as cores planas que colidem como `{ ...colors.<hue>, DEFAULT: "<hex atual>" }`
  e mova `animation`/`keyframes`/`backgroundImage` para dentro de `extend` (§2.3, "Phase 0").
- [ ] Rode o teste → PASS. Rode `yarn test`, `yarn build` e `npx tsc --noEmit` → verdes.
- [ ] **Commit:** `fix(tailwind): fase 0, escalas padrão e animações voltam a existir (059/01)`.

## Task 2: Tokens

**Card:** `tickets/059/01`

**Arquivos:**
- Criar: `src/styles/tokens.css` (§2.2 inteiro), `tailwind/type-scale.js` (§2.4), `src/lib/palette.ts` (§2.7)
- Alterar: `tailwind.config.js` (§2.3, menos o legado), `src/index.css` (importa `tokens.css` no topo; sai o
  bloco zinc do `:root` e o `.dark`), `index.html` (pesos da Raleway, §2.4)
- Testes: `src/design-system/tailwindConfig.test.ts`, `src/design-system/typeScale.test.ts`

**Interfaces:**
- Produz: as utilities semânticas (`bg-cta`, `text-muted-foreground`, `bg-success-muted`, …);
  `.text-<step>` para os 14 passos; `palette` e `chartSeries` exportados de `@/lib/palette`.

- [ ] **Testes que falham.**
  - `tailwindConfig.test.ts`: `theme.colors.cta.DEFAULT === "hsl(var(--cta) / <alpha-value>)"`;
    `theme.zIndex.popover === "50"`; `theme.maxWidth.form === "560px"`; `theme.borderRadius.lg ===
    "var(--radius)"`.
  - `typeScale.test.ts`, no ambiente node: compile `<h1 class="text-h1 text-hero">` com
    `postcss([tailwindcss(config)])` e confira no CSS:
    - `.text-h1{font-size:24px;line-height:1.2}`;
    - `@media (min-width: 768px)` com `.text-h1{font-size:30px}`;
    - `:where(.text-h1){font-weight:700}`;
    - `.text-hero` com 48, 72 (≥1200) e 96 (≥1565).
- [ ] Rode os dois → FAIL.
- [ ] **Implemente** os arquivos acima com os valores da spec. A cor legada continua no tema (o comentário do
  §2.3 diz até quando) e o `fontSize` padrão também.
- [ ] Rode os testes → PASS. Rode `yarn test` e `yarn build` → verdes. Abra `yarn dev` na home e num painel:
  nada some, e o shadcn passa de zinc a marine.
- [ ] **Commit:** `feat(design-system): tokens, escala de texto e palette (059/01)`.

## Task 3: Lint e guardas

**Card:** `tickets/059/01`

**Arquivos:**
- Criar: `eslint.config.js`; `src/design-system/guard/rules.ts`; `src/design-system/guard/baseline.json`;
  `src/design-system/guard.test.ts`; `src/design-system/guard/rules.test.ts`;
  `src/design-system/contrast.test.ts`
- Apagar: `.eslintrc.cjs`
- Alterar: `package.json` (`eslint-plugin-jsx-a11y`, `typescript-eslint`; `"lint": "eslint ."` sem
  `--max-warnings 0` até a Task 13)

**Interfaces:**
- Produz:
  - `type GuardRule = { id: string; description: string; match(source: string, file: string): number }`;
  - `export const rules: GuardRule[]` com os 10 itens da §5.2, com estes ids: `legacy-color`,
    `legacy-size`, `arbitrary-spacing`, `flagged-elevation`, `hero-outside-home`, `banned-import`,
    `frozen-folder`, `missing-stories`, `ds-review-marker`, `ui-semantic-only`;
  - `baseline.json` no formato `{ [ruleId]: number }`.

- [ ] **Testes que falham.**
  - `rules.test.ts`, um `it` por regra, com fonte de exemplo:
    - `legacy-color` conta 1 em `className="text-marine"`, 1 em `` `${a ? "bg-gray-100" : ""}` `` e 0 em
      `className="text-white"`;
    - `banned-import` conta 1 em `import { Button } from "@mui/material"` num arquivo que não é de gráfico;
    - `hero-outside-home` conta 1 para `text-hero` fora de `src/pages/homeV2`;
    - `frozen-folder` conta 1 para um caminho novo em `src/components/molecules/` que não está na lista.
  - `guard.test.ts`: para cada regra, a soma em `src/**/*.{ts,tsx}` (fora os testes) é `≤ baseline[id]`.
  - `contrast.test.ts`: os pares da §5.3 (≥4.5:1 para texto, ≥3:1 para `input`/`ring`/`chart-*`) em `:root`
    e em cada `[data-theme]`, e `palette.ts` igual aos primitivos do CSS.
- [ ] Rode → FAIL (os módulos ainda não existem).
- [ ] **Implemente.** `rules.ts` com expressões regulares sobre o texto-fonte (o precedente é
  `src/semComponenteNoRender.test.ts`). Gere o `baseline.json` uma vez com as contagens de hoje. Para o
  `frozen-folder`, a lista permitida é a lista de arquivos de hoje, guardada no próprio `baseline.json`. O
  ESLint usa flat config com typescript-eslint, react-hooks, react-refresh e `jsx-a11y` recomendado em
  `warn` (§5.4).
- [ ] Rode os testes → PASS. Rode `yarn lint` → termina sem erro (só avisos). Rode `yarn test` e
  `yarn build`.
- [ ] **Commit:** `feat(design-system): guard em catraca, contraste e eslint flat com jsx-a11y (059/01)`.

## Task 4: Storybook

**Card:** `tickets/059/01`

**Arquivos:**
- Criar:
  - `.storybook/main.ts` e `.storybook/preview.tsx` (§5.1);
  - `src/design-system/docs/foundations/{colors,typography,spacing}.mdx`;
  - `src/design-system/docs/guidelines/{voice,errors,accessibility,responsiveness,usage-rules}.mdx`, com o
    conteúdo da §6, incluindo as regras da D17, da D19 e da D22.
- Alterar:
  - `package.json`: `storybook`, `@storybook/react-vite`, `@storybook/addon-a11y` e `@storybook/addon-docs`,
    com versão exata; scripts `storybook` e `build-storybook`;
  - `.github/workflows/ci-homol.yml`: `build-storybook` com filtro de caminho, pelos caminhos da §5.1.

- [ ] Rode `yarn build-storybook` → falha (ainda não existe).
- [ ] **Implemente.**
  - `viteFinal` tira o `VitePWA`.
  - O `preview` importa `src/index.css`, carrega a Raleway como o `index.html` e tem os decorators de
    `MemoryRouter` e do container de toast.
  - Barras de ferramentas: viewports 390, 768 e 1200; seletor de `[data-theme]` (`neutral`, `marine`,
    `yellow`).
- [ ] Rode `yarn build-storybook` → sai sem erro, e `storybook-static/index.json` lista as 8 páginas MDX.
  Rode `yarn test` e `yarn build`.
- [ ] **Commit:** `feat(design-system): storybook com fundamentos e guias (059/01)`.

## Task 5: `ui`, ações e formulário

**Card:** `tickets/059/01`

**Arquivos (em `src/components/ui/`, cada um com `*.stories.tsx`):**
- `button.tsx`, `field.tsx`, `input.tsx`, `textarea.tsx`, `select.tsx`, `combobox.tsx`, `checkbox.tsx`,
  `radio-group.tsx`, `switch.tsx`, `segmented-control.tsx`, `calendar.tsx`, `date-picker.tsx`,
  `date-range-picker.tsx` (vem do `dashV2/DashDateRangeFilter`)
- Apagar `form.tsx`. Criar `stories.test.tsx`.
- Dependências: `@radix-ui/react-radio-group`, `@radix-ui/react-switch` e `cmdk` (§4).

**Interfaces:**
- Produz:
  - `Button`: `variant: "cta"|"primary"|"secondary"|"outline"|"ghost"|"destructive"|"link"`,
    `size: "sm"|"md"|"lg"|"icon"`, `loading?`, `asChild?`. Com `size: "icon"`, `aria-label` é obrigatório no
    tipo.
  - `Field`: `{ label, hint?, error?, required?, maxLength?, children }`. Liga `aria-describedby`,
    `aria-invalid` e `aria-required` ao controle filho.
  - `FormLegend`.
  - `Input` e `Textarea`: `leading?`, `trailing?: ReactNode`, `suffix?: string`.
  - `SegmentedControl`: `{ value, onValueChange, options: { value: string; label: string; icon?: LucideIcon
    }[], size?: "sm"|"md", fullWidth?, "aria-label": string }`.
  - `DatePicker`: `{ value?: Date, onChange }`; `DateRangePicker`: `{ value?: DateRange, onChange }`.

- [ ] **Testes que falham.**
  - `stories.test.tsx`: `composeStories` em todo `src/components/ui/*.stories.tsx`, e cada história renderiza
    sem erro.
  - `field.test.tsx`:
    - com `error`, o input tem `aria-invalid="true"` e `aria-describedby` aponta para a mensagem;
    - com `required`, há um `*` com `aria-hidden` e o input tem `required`;
    - com `maxLength={500}`, depois de digitar "abc" aparece "3/500".
  - `segmented-control.test.tsx`:
    - `role="radiogroup"` com `aria-label`;
    - a seta para a direita marca a opção seguinte e chama `onValueChange`;
    - dentro de um `<form onSubmit={spy}>`, Enter e Espaço não chamam o `spy`;
    - com dois grupos em linhas seguidas, a seta no último item do primeiro não move o foco para o segundo.
  - `button.test.tsx`: um `// @ts-expect-error` para `<Button size="icon" />` sem `aria-label`. Com
    `loading`, o botão fica `disabled` e mostra o spinner.
- [ ] Rode → FAIL.
- [ ] **Implemente** pela tabela da §3, com o visual de `prototipos/components.html?variant=C` e a densidade
  adaptativa: h-9 no desktop, 44px abaixo de 768.
- [ ] Rode os testes → PASS. Rode `yarn test`, `yarn build` e `yarn build-storybook`. O guard
  `missing-stories` fica em zero para `ui`.
- [ ] **Commit:** `feat(ui): ações e formulário do design system (059/01)`.

## Task 6: `ui`, sobreposições

**Card:** `tickets/059/01`

**Arquivos (com histórias):** `dialog.tsx`, `alert-dialog.tsx`, `sheet.tsx`, `popover.tsx`, `tooltip.tsx`,
`dropdown-menu.tsx` (dependência `@radix-ui/react-dropdown-menu`).

**Interfaces:**
- Produz:
  - `Dialog` com `size: "sm"|"md"|"lg"|"full"`;
  - `DialogContent` com `banner?: ReactNode`;
  - `DialogFooter` com `status?: ReactNode`, que vai num `aria-live="polite"` à esquerda;
  - `Sheet` com `side: "right"|"left"`.

- [ ] **Testes que falham** (`dialog.test.tsx`):
  - o `banner` aparece entre o cabeçalho e o corpo;
  - `status` é renderizado dentro de `[aria-live="polite"]`;
  - o cabeçalho e o rodapé ficam fora do contêiner que rola (`data-slot="dialog-body"` com `overflow-y-auto`);
  - Esc fecha;
  - abaixo de 768 (`matchMedia` mockado), o conteúdo recebe a classe de tela cheia.
- [ ] Rode → FAIL.
- [ ] **Implemente** pela §3 e pela D21: altura máxima `calc(100dvh-2rem)` a partir de 768, z-index
  `overlay`/`popover`.
- [ ] Rode os testes → PASS. Rode `yarn test`, `yarn build` e `yarn build-storybook`.
- [ ] **Commit:** `feat(ui): dialog, sheet, menus e popovers do design system (059/01)`.

## Task 7: `ui`, dados

**Card:** `tickets/059/01`

**Arquivos (com histórias):**
- `data-table.tsx` (vem do `dashV2/DashTable`), `table.tsx`, `list.tsx`, `timeline.tsx`, `tabs.tsx`,
  `card.tsx`, `badge.tsx`
- `status-badge.tsx` (vem do `dashV2`), `pagination.tsx`, `accordion.tsx`
- `skeleton.tsx`, com `TableSkeleton`, que vem dos skeletons do dashV2
- `separator.tsx`, `scroll-area.tsx`, `label.tsx`

**Interfaces:**
- Produz:
  - `DataTable`: as props da §3. `columns[].mobile` aceita `"title"|"meta"|"status"|"hidden"`.
  - `List` e `ListItem`: `{ title, meta?: ReactNode[], badges?, trailing? }`. `List` aceita `state:
    "loading"|"empty"|"error"|"ready"`, `onRetry?` e `empty?: { icon, title, hint, action? }`.
  - `Timeline` e `TimelineItem`: `{ icon: LucideIcon, variant, who, what, when: Date, detail?, action? }`.
  - `StatusBadge`: `{ variant, look: "dot"|"tint", icon?, value? }`.

- [ ] **Testes que falham.**
  - `data-table.test.tsx`:
    - o rodapé mostra "Mostrando 11–20 de 45" na página 2 com 10 por página;
    - no mobile, as linhas viram cartões pelos papéis padrão;
    - com paginação no servidor, quando `total` cai para 5 estando na página 3, a tabela chama
      `onPageChange(1)`.
  - `list.test.tsx`: `state="error"` mostra um `Alert` e "Tentar de novo" chama `onRetry`; `state="empty"`
    mostra o título vazio.
  - `timeline.test.tsx`: um `<ol>` com um `<li>` por evento; o último item não tem a linha de ligação.
  - `pagination.test.tsx`: "Anterior" e "Próxima" são `<button>`.
  - `status-badge.test.tsx`: `variant="warning" value="32%"` renderiza "32%" e nenhuma classe com `orange`.
- [ ] Rode → FAIL.
- [ ] **Implemente.** As telas do dashV2 passam a importar de `ui`. `dashV2/index.ts` reexporta por enquanto;
  a Task 11 termina a separação.
- [ ] Rode os testes → PASS. Rode `yarn test`, inclusive `DashToolbar.test.tsx`, e `yarn build`.
- [ ] **Commit:** `feat(ui): tabelas, listas, linha do tempo e selos do design system (059/01)`.

## Task 8: `ui`, retorno e navegação

**Card:** `tickets/059/01`

**Arquivos (com histórias):**
- `alert.tsx`, `error-summary.tsx`, `toast.tsx`, `spinner.tsx`, `progress.tsx` (dependência
  `@radix-ui/react-progress`), `sidebar.tsx`
- Criar também: `src/lib/toast.ts`

**Interfaces:**
- Produz:
  - `ErrorSummary`: `{ items: { message: string; where?: string; onGoTo: () => void }[] }`;
  - `src/lib/toast.ts`: reexporta a API do `toast` do react-toastify, com `autoClose` 5000 em
    `success`/`info` e `false` em `warning`/`error`; opção explícita na chamada vence.

- [ ] **Testes que falham.**
  - `error-summary.test.tsx`: com 1 item, mostra "1 problema impede salvar"; com 2, "2 problemas impedem
    salvar"; "Ir até o campo" chama `onGoTo`.
  - `src/lib/toast.test.ts`:
    - `toast.error("x")` sai com `autoClose: false`;
    - `toast.success("x", { autoClose: 1000 })` mantém 1000;
    - `toast.promise`, `toast.update`, `toast.dismiss` e `toast.isActive` existem e delegam para o
      react-toastify.
- [ ] Rode → FAIL.
- [ ] **Implemente** pela §3 (Toast, Alert, Spinner, Progress, Sidebar) e pela D19.
- [ ] Rode os testes → PASS. Rode `yarn test`, `yarn build` e `yarn build-storybook`.
- [ ] **Commit:** `feat(ui): alertas, resumo de erros, toast e navegação do design system (059/01)`.

## Task 9: Codemods

**Card:** `tickets/059/01`

**Arquivos:**
- Criar:
  - `scripts/ds-codemods/{colors,sizes,weights,radius-shadow-z,arbitrary,icons}.ts`;
  - `scripts/ds-codemods/run.ts`;
  - `scripts/ds-codemods/__tests__/*.test.ts`, com os casos da §7.3 como fixture.

**Interfaces:**
- Produz: `transform(source: string, file: string): { code: string; reviews: number }`. Ela troca as classes
  pelo mapeamento da §7.3 e, nas linhas marcadas como **review**, deixa `/* ds-review: <motivo> */` em vez de
  trocar.

- [ ] **Testes que falham**, um `it` por linha das tabelas da §7.3, além de:
  - `` `${ok ? "text-red" : "text-gray-500"}` `` → `` `${ok ? "text-destructive" : "text-muted-foreground"}` ``;
  - `cn({ "bg-orange": cta })` → `cn({ "bg-cta": cta })`;
  - uma variante `cva` com `"border-lightGray"` → `"border-border"`;
  - `hover:bg-gray-100` → `hover:bg-muted`;
  - `text-lg md:text-xl` → `text-h3`;
  - `text-orange` → mantido, com o marcador `ds-review`.
- [ ] Rode → FAIL.
- [ ] **Implemente** os transforms e rode as varreduras, **um commit por varredura**, na ordem da §7.2 (item
  6). Resolva à mão os marcadores `ds-review` no mesmo commit da varredura. A catraca do guard só pode
  descer: atualize o `baseline.json` para as contagens novas no mesmo commit.
- [ ] Depois de cada varredura: `yarn test`, `yarn build` e `yarn lint`. Zero `ds-review`, e o guard verde.
- [ ] **Commits:** `refactor(design-system): codemod de <varredura> (059/01)`, um por varredura.

## Task 10: Famílias de componentes

**Card:** `tickets/059/01`

**Arquivos:** os da tabela da §7.4, inclusive o bloco "Screens added up to 2026-11-20".

- [ ] Para cada família da §7.2 (item 7), **um commit por família**, e **um commit por tela com DataGrid**
  (6 telas). Em cada uma:
  - [ ] adapte os testes existentes da tela ao novo markup, sem tirar nenhuma asserção de comportamento.
    Quando a tela tiver vitrine, confira o estado em `/dev/vitrine`;
  - [ ] troque pelo mapeamento da §7.4;
  - [ ] corrija os avisos de jsx-a11y dos arquivos que tocou;
  - [ ] rode `yarn test` (contagem igual ou maior), `yarn build` e o guard (as contagens descem;
    atualize o `baseline.json`).
- [ ] Ordem: Button V1 → overlays (`ModalTemplate`/`ModalConfirmCancel`/`ModalTabTemplate`/`AlertDialogUI`
  e os `fixed inset-0`) → `Text` V1 → inputs V1 → MUI por família → DataGrid (6 telas, uma por commit) →
  PrimeReact → headlessui → loaders → toast (codemod de import para `@/lib/toast`) → nav mobile → as telas de
  2026-11 (chamada, histórico, alerta de evasão, motivo de rejeição, copiar contato, dados sensíveis,
  pendências da questão, linhas do tempo, `FiltrosDoGeo`).
- [ ] **Commits:** `refactor(ui): <família> no design system (059/01)`.

## Task 11: Separação do dashV2

**Card:** `tickets/059/01`

**Arquivos:**
- Alterar: `DashListTemplate`, `DashToolbar`, `DashFilterBar`, `DashListFooter`, que passam a usar `ui`.
  O `DashFilterBar` ganha o comportamento da D22.
- Apagar: `dashV2/tokens.ts` e `dashV2/tokens.test.ts`.
- Alterar o `dashV2/README.md`: a regra "`components/ui/*` não são editados" é trocada por um link para
  este design system (§7.2, item 8).

- [ ] **Teste que falha** (`DashFilterBar.test.tsx`):
  - com `matchMedia` abaixo de 768, só a busca aparece e há um botão "Mais filtros (2)" quando 2 filtros
    estão ativos;
  - clicar nele mostra os outros campos;
  - digitar na busca chama `onChange` uma vez, 400ms depois da última tecla (com timers falsos).
- [ ] Rode → FAIL. Implemente. Rode o teste → PASS, depois `yarn test` (inclusive `DashToolbar.test.tsx`) e
  `yarn build`.
- [ ] **Commit:** `refactor(dashV2): template e filtros sobre o ui, tokens próprios removidos (059/01)`.

## Task 12: Camada expressiva da home

**Card:** `tickets/059/01`

**Arquivos:**
- `src/pages/homeV2/**`, `src/pages/quemSomos/**`
- Apagar: `src/styles/sectionThemes.css`
- Alterar: o tipo `SectionTheme`, que perde `pink` e `green`

- [ ] **Teste que falha:** acrescente ao `contrast.test.ts` os pares de `[data-theme="marine"]` (`cta` sobre
  `background` = 5.62:1) e confira que nenhum arquivo da home tem `--section-` nem `home-section__eyebrow`.
- [ ] Rode → FAIL. **Implemente** pela §7.2 (item 9) e pela tabela "Home hard-coded colors" (§7.3).
  Confira contra `prototipos/home-expressive.html?variant=A&hero=96`.
- [ ] Rode o teste → PASS, depois `yarn test` e `yarn build`.
- [ ] **Commit:** `feat(home): camada expressiva sobre os tokens (059/01)`.

## Task 13: Limpeza

**Card:** `tickets/059/01`

- [ ] **Teste que falha:**
  - `guard.test.ts` passa a exigir **zero** em toda regra (o `baseline.json` sai);
  - `tailwindConfig.test.ts` confere que `theme.fontSize.sm` é `undefined` e que `theme.colors.marine` não
    existe.
- [ ] Rode → FAIL.
- [ ] **Implemente:**
  - apague os arquivos do kit V1 que ficaram sem uso e `scripts/ds-codemods/`;
  - tire do tema os nomes de cor legados e o `fontSize` padrão;
  - tire as dependências aposentadas (§4, coluna "Retire");
  - passe o jsx-a11y a `error` e volte o `--max-warnings 0` no `lint`.
- [ ] Rode `yarn test`, `yarn build`, `yarn lint` e `yarn build-storybook` → verdes. Rode `yarn why
  @mui/material` → só via `@mui/x-charts`.
- [ ] **Commit:** `chore(design-system): limpeza, guard estrito e dependências removidas (059/01)`.

## Task 14: Verificação antes e depois, e o PR

**Card:** `tickets/059/01`

**Arquivos:**
- Criar: `scripts/ds-screenshots.ts` (puppeteer do repo)
- Criar: `src/design-system/docs/qa-checklist.mdx`, com o checklist da §7.5, inclusive o bloco "Added
  2026-11-20"

- [ ] **Implemente o script.** Ele percorre todas as rotas `/dev/vitrine/:componente/:estado` em **390×844,
  390×640 e 1280×800**, na `develop` e na branch, e escreve `ds-screenshots/report.html` com os pares lado a
  lado. O relatório não vai para o commit.
- [ ] Rode o script e revise cada par. Na 390×640, a ação principal de cada Dialog fica visível. Anote no PR
  o que ficou diferente de propósito.
- [ ] Combine com o time os 2–3 dias de congelamento de UI (§7.1). Faça o rebase final e rode os codemods de
  novo, se o rebase trouxe código antigo.
- [ ] **Abra o PR pela skill `abrir-pr`**, com merge commit. No corpo, liste os pares de ícones escolhidos à
  mão (§7.3, Icons) e as issues de bugs encontrados.
- [ ] **Commit:** `docs(design-system): checklist de homologação e script de capturas (059/01)`.

## Task 15: Homologação

**Card:** `tickets/059/02`

- [ ] Durante o congelamento, com a branch em homologação, percorra o `qa-checklist.mdx` no desktop e em 390,
  só com teclado nos itens ★.
- [ ] Registre cada problema como comentário no PR do card 01: tela, largura e passo. Prints só de
  homologação.
- [ ] Marque o card como concluído quando o checklist passar sem pendência aberta.

## Task 16: Nota de lançamento e site de ajuda

**Card:** `tickets/059/03`

- [ ] No repo `docs`, procure prints das telas que mudaram de aparência. Troque-os por prints de homologação
  depois do deploy.
- [ ] Escreva a nota curta "o que mudou" para as coordenações de cursinho (D14): o visual novo, onde ficaram
  os filtros no celular (D22) e a chamada nova.
