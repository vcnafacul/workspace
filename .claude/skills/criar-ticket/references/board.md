# Subir para o board sem arriscar a conta

O detector de abuso do GitHub já sinalizou uma conta do time por criar poucas issues, labels e discussions em
sequência. Ele vê padrão (criações iguais, em rajada, da mesma conta), não intenção. Limite publicado: 80
criações de conteúdo por minuto e 500 por hora, e o flag vem antes disso. A reinstalação levou semanas.

## Regra

| Operação | Quantidade |
|---|---|
| Draft no Project #2 (`gh project item-create`) | **1** por ticket |
| Mutation GraphQL de campos | **1**, com aliases |
| `gh issue create`, labels, discussions, comentários, sub-issues, `gh issue edit` | **0** |
| Paralelismo, retry em 403/429/"secondary rate limit" | **0** |

`scripts/criar-card.sh` faz as 2 escritas em série, com 2 s entre elas, e para no primeiro erro. Não rode `gh`
de escrita fora dele. Vários tickets: um script por vez, com pelo menos 1 min entre eles.

## Antes de escrever (leituras)

```bash
gh project item-list 2 --owner vcnafacul --limit 200 --format json   # filtre pelo título: duplicata → pare e mostre
gh api rate_limit                                                    # core ou graphql abaixo de 500 → pare
```

## Rodar

```bash
FLAG=14014d75 EPIC=<id> STORY=<id> AREA=<id> \
  .claude/skills/criar-ticket/scripts/criar-card.sh "<NNN · título>" <arquivo-do-corpo.md>
```

Ids em `campos-do-board.md`. `DRY_RUN=1` mostra os comandos sem escrever. O corpo vai num arquivo temporário
(scratchpad), não na pasta do ticket.

## Erros

- 403, 429, `retry-after`, "secondary rate limit", "abuse": **pare**, mostre a mensagem inteira e não repita.
  Draft criado sem os campos é aceitável: a pessoa ajusta no site.
- Conta já sinalizada: nenhuma escrita.
- Precisa de issue de verdade? O draft tem "Convert to issue" no site: 1 clique, nenhuma escrita por script.
