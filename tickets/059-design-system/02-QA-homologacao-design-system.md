---
titulo: Homologação do design system
area: QA
repos: [client-vcnafacul]
status: aberto            # aberto → em-andamento → em-revisao → concluido | cancelado
responsavel:
depende_de: [059/01]
prs: []
natureza:
---

## Objetivo

Percorrer o checklist de homologação da migração (`src/design-system/docs/qa-checklist.mdx`, §7.5 da
[spec](spec.md)) durante o congelamento de UI, com a branch do card 01 em homologação, **antes** do merge.
É a Task 15 do [plano](plano.md).

## Critérios de aceite

- [ ] O checklist foi percorrido no desktop e em 390 de largura: área pública, área do estudante, painéis e
  os itens transversais, inclusive o bloco "Added 2026-11-20".
- [ ] Os itens ★ foram feitos só com teclado.
- [ ] Cada problema virou comentário no PR do card 01, com tela, largura e passo, e nenhum ficou aberto.

## Notas

- Prints só de homologação ou com dados fictícios (contrato §7).
- Este card depende de o PR do card 01 estar aberto e em homologação, não do merge.
- [ ] Afeta a arquitetura? → atualizar docs/arquitetura.md neste card
