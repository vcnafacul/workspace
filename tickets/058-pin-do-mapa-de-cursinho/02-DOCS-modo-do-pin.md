---
titulo: Site de ajuda explica o modo do pin no cadastro de cursinho
area: DOCS
repos: [docs]
status: aberto
responsavel:
depende_de: [058/01]
prs: []
natureza:
---

## Objetivo

O site de ajuda explica como posicionar o pin ao cadastrar um cursinho: os modos "Seguir o CEP" e "Ponto no
mapa" (`tickets/058 D1`).

## Critérios de aceite

- [ ] A página sobre o cadastro de cursinho no Localiza Cursinho explica os dois modos.
- [ ] A página diz que clicar no mapa fixa o ponto (`tickets/058 D2`).
- [ ] Se o card 01 tirar o checkbox "Definir localização manualmente", a página para de mencioná-lo.
- [ ] Prints só de homologação ou com dados fictícios.

## Notas

- Clone com `./ws clonar --com docs`. Publique só depois que o card 01 estiver no ar.
- Se não existir página sobre o cadastro de cursinho, feche como `cancelado`, com o motivo. Criar a página
  inteira fica fora deste ticket.

- [ ] Afeta a arquitetura? → atualizar docs/arquitetura.md neste card
