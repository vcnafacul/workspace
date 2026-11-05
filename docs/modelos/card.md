---
titulo: <título>
area: <FRONT|BACK|FULL|INFRA|OPS|QA|DOCS|PRODUTO>
repos: [<repo>]
status: aberto            # aberto → em-andamento → em-revisao → concluido | cancelado
responsavel:
depende_de: []            # ex.: [058/02]
prs: []                   # vcnafacul/<repo>#N, preenchido pelo abrir-pr
natureza:                 # opcional: seguranca | bug
---

## Objetivo

<O que este card entrega.>

## Critérios de aceite

- [ ] <Critério verificável.>

## Notas

<Contexto para quem for executar. Decisões ficam na `spec.md`: cite como `tickets/NNN D3`.>

- [ ] Afeta a arquitetura? → atualizar docs/arquitetura.md neste card
