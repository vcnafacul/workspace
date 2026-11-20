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
