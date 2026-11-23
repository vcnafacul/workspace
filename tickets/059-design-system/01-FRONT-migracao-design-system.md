---
titulo: Migração do client para o design system
area: FRONT
repos: [client-vcnafacul]
status: em-andamento            # aberto → em-andamento → em-revisao → concluido | cancelado
responsavel: GessioMori
depende_de: []
prs: []                   # vcnafacul/<repo>#N, preenchido pelo abrir-pr
natureza:
---

## Objetivo

Levar o `client-vcnafacul` inteiro para o design system da spec, **num PR só**, com commits ordenados
(`tickets/059 D14`): tokens, componentes de `ui`, Storybook, guardas, migração de todas as telas e remoção
das bibliotecas aposentadas. É o que fazem as Tasks 1–14 do [plano](plano.md).

## Critérios de aceite

- [ ] Branch `feat/059-01-design-system`, PR para a `develop`, merge commit sem squash.
- [ ] Cada commit fica verde sozinho: `tsc`, `yarn lint`, `yarn test` (suíte inteira) e `yarn build`, mais
  `yarn build-storybook` a partir da Task 4.
- [ ] O guard está estrito (zero em toda regra) e o jsx-a11y está em `error` (§5.2, §5.4).
- [ ] O teste de contraste passa em `:root` e em cada `[data-theme]` (§5.3).
- [ ] Todo arquivo de `src/components/ui` tem histórias, e o teste de fumaça das histórias passa (§5.1).
- [ ] Saíram do `package.json` as dependências da coluna "Retire" da §4. O `@mui/material` fica só como
  dependência do `@mui/x-charts`.
- [ ] As telas do mapeamento da §7.4 estão migradas, inclusive as de 2026-11 (D17–D22).
- [ ] Nenhum teste foi apagado, e a contagem de testes não caiu.
- [ ] O relatório de capturas antes e depois (390×844, 390×640 e 1280×800) foi revisado e está resumido no
  PR (§7.5).

## Notas

- Os valores estão na [spec](spec.md); o plano diz a seção de cada tarefa. Cite as decisões como
  `tickets/059 D17`.
- Rebase diário na `develop` e codemods rodados de novo depois de cada rebase. O time combina 2–3 dias de
  congelamento de UI para a homologação (card 02) e o merge (§7.1).
- Bug encontrado no caminho vira issue, não correção, a não ser que a troca já o corrija.
- **Depois do merge:** no `AGENTS.md` do workspace, o `yarn lint` do client deixa de estar quebrado.
  Atualize a tabela de repos por PR no workspace.
- [ ] Afeta a arquitetura? → atualizar docs/arquitetura.md neste card

## Handoff (2026-11-23)

**Onde parou:** Tasks 1–14 do [plano](plano.md) implementadas e revisadas, e a revisão final da branch
também. Falta só o que depende de pessoas: decisões abaixo, congelamento de UI, push e PR.

- Branch `feat/059-01-design-system` no `client-vcnafacul`, HEAD `baac115b`, 115 commits sobre
  `develop` @ `6d782d4d` (a `develop` não andou; sem rebase pendente).
- A branch já tem upstream (`origin/feat/059-01-design-system`); os 2 commits de 2026-11-23 ainda não
  foram enviados. Não há PR aberto: abra pela skill `abrir-pr`, que roda as verificações.
- Estado verificado no HEAD (2026-11-23): `yarn test:ci` 368 arquivos / 3208 testes, `yarn build` e
  `yarn build-storybook` ok, `yarn lint` 0 erros e 44 avisos (teto, ver item 3), guard estrito em zero.
  O CI passou a rodar `yarn lint`.
- O registro detalhado (cada tarefa, commits, revisões, decisões R1–R56 e achados menores adiados) está no
  ledger local `client-vcnafacul/.superpowers/sdd/plano/progress.md` (ignorado pelo git). Para retomar a
  execução, use `superpowers:subagent-driven-development` com este plano: o ledger diz onde está.

**Decisões (antes do merge):**
1. ~~Contraste (R12)~~ **Resolvido em 2026-11-23** (`9073405c`): `orange-700` passou a `#AD5100` e o tema
   amarelo ganhou `--input: neutral-500`, e as três exceções saíram do `contrast.test.ts`. As 16 exceções do
   tema marinho ficam, com a regra "status, gráficos e `page` não entram em seções escuras" na spec §2.2 e na
   página de cores do Storybook.
2. ~~`DashToolbar.test.tsx` fora do `test:ci` (R20)~~ **Resolvido em 2026-11-23** (`baac115b`): o
   `--exclude` saiu e o `test:ci` roda a suíte inteira (368 arquivos, 3208 testes).
3. Teto `--max-warnings 44` (R52): **aceito o teto**. Os 44 avisos são `react-hooks/exhaustive-deps` em
   efeitos de montagem, e corrigi-los muda quando os efeitos rodam. **Issue a abrir depois:** zerar os avisos,
   cada correção com teste de comportamento, baixando o teto no mesmo PR.
4. Geo, passo 1 (R36): **fica obrigatório**. Na `develop` o campo já aparecia como obrigatório
   (`required: true` em `src/pages/Geo/data.ts`), mas o schema não validava, e o select nativo gravava
   "Coordenador" sem escolha. **Issue a abrir depois:** registrar que os cadastros antigos com
   "Coordenador" podem não ter sido escolhidos, para quem analisa esses dados. Citar a mudança no PR.
5. Conferir no PR: `pendencias-da-questao/classificacao` — no celular, Aceitar/Rejeitar ficam atrás do
   Dialog em tela cheia.

**Para o PR e a homologação:**
- Rodar `scripts/ds-screenshots.ts` (instruções no topo do arquivo) e revisar os 240 pares antes/depois;
  só 8 foram vistos um a um. O resumo do que mudou de propósito por rota está no relatório da Task 14 no
  ledger.
- Combinar com o time os 2–3 dias de congelamento de UI (§7.1) e seguir o card 02 com o
  `src/design-system/docs/qa-checklist.mdx`.

**Issues a abrir (bugs que já existiam no `develop`; somam-se às dos itens 3 e 4 acima):** `calculateAge` conta 18 anos um dia antes a oeste
de São Paulo; resumo de chamadas adianta a data depois das 21h (`toISOString`); `activeTab={0}` fixo em
`actionAreas`; editores de texto rico sem nome acessível; 4 testes falham com `TZ=Pacific/Kiritimati`;
`geoSearch/index.test.tsx` instável.

**Atualizar a spec no fim** (o R12 já entrou na §2.2): R31/R55 (SegmentedControl 44px no celular), R34 (tamanho do Dialog pelo
conteúdo, §7.4), R35 (`OptionsSelect` e `PasswordInput` na §3), R45 (cortes 1200/1565 da navegação, §3),
`react-refresh` desligado em `ui/**` e as opções novas do jsx-a11y.

**Depois do merge:** marcar este card `concluido`, preencher `prs`, e no `AGENTS.md` o `yarn lint` do
client deixa de estar quebrado e o CI deixa de pular o `DashToolbar.test.tsx`.
