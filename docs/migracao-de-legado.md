# Migração de legado

Como trazer planejamento antigo para `tickets/`, com qualquer agente. Migrar é opcional e feito **um esforço
de origem por vez**, cada um em **um PR no workspace**, nunca direto no `main`. **Quem faz o merge é uma
pessoa, depois de revisar o conteúdo.**

O código dos repos **nunca é reescrito**: os números preservados e o `tickets/LEGADO.md` resolvem as citações
existentes.

## Tickets numerados `tickets/NNN-slug/`

Mantêm número e slug, para que as citações no código continuem resolvendo.

| Origem | Destino |
|---|---|
| `tickets/NNN-slug/` | Mesmo caminho. `001`–`016`, que são planos, também ficam nesta faixa reservada |
| `NN-AREA-slug.md` | Mesmo nome. **Exceções válidas só no legado:** sufixos de letra (`01b`, `34A`), áreas `SEG` e `BUG`, regras `R` ao lado de `D` |
| README da série | `README.md`, com o frontmatter do contrato. Status inferido dos PRs: mergeado → `concluido` |
| Spec e plano do superpowers | `spec.md` e `plano.md`, mantendo a numeração `D`. Regras `R` viram `## Regras (legado)` na `spec.md` |
| PRs | Reconstruídos do GitHub (`gh pr list --search "NNN/"` e nomes de branch) nos `prs` de cada card e em `## Como ficou` |
| `docs/superpowers/` dos repos | **Copiados** para o ticket a que pertencem, se útil. Nunca apagados dos repos por este fluxo |

## Origens sem número

Entram em `tickets/LEGADO.md`, que mapeia cada forma antiga de citação para o novo lugar. `tickets/legado/` é a
única exceção à regra de que todo ticket tem número.

| Origem | Destino |
|---|---|
| `tickets-documentacao` | `tickets/032-documentacao/ajustes/` (cards mantidos como `NN-*.md`) |
| `docs/cards/<série>/…` e `docs/cards/etapa-N/…` | `tickets/legado/<série>/` (nomes mantidos) |
| `docs/prova-latex-overleaf/cards/` | `tickets/legado/prova-latex-overleaf/` |
| Instruções do workspace privado anterior | Registre em `LEGADO.md` quais regras foram para qual `AGENTS.md` |

## Esforços do wayfinder

`343-design-system`, `686-cursinho-monitoramento`, `chat-improvements` e `workspace-repo` ganham **números novos
a partir de `058`**, na ordem em que forem migrados. O número de issue no nome antigo vai para `issue:`. Conteúdo
em inglês fica em inglês, com uma nota no README.

| Origem | Destino |
|---|---|
| `map.md` | `planejamento/mapa.md` |
| `tickets/NN-*.md` | `planejamento/NN-*.md` |
| `research/` | `pesquisa/` |
| `prototypes/` | `prototipos/` |
| `spec.md` | `spec.md`, com números `D` nas decisões, se não tiverem |

## Prompt

```text
Migre um esforço de legado para o workspace, seguindo docs/migracao-de-legado.md e
docs/contrato-de-desenvolvimento.md.

Origem: <caminho do esforço>

1. Trabalhe só neste esforço, numa branch do workspace chamada docs/migrar-<slug>.
2. Aplique as tabelas de mapeamento. Preserve número e slug quando a tabela mandar. Não reescreva
   código em nenhum repo.
3. Reconstrua a lista de PRs a partir do GitHub, quando a tabela pedir.
4. Atualize tickets/LEGADO.md, se a origem não tiver número.
5. Varredura obrigatória de conteúdo em tudo o que foi migrado: e-mails, telefones, padrões de CPF,
   nomes de estudantes ou de equipes fora do time, contagens reais que identifiquem pessoas, hostnames,
   IPs, tokens e chaves, valores de .env, prints.
6. Abra o PR com a seção "Achados de conteúdo": cada achado com o arquivo e uma proposta (remover,
   generalizar ou mover para o repo privado).

Nunca mergeie: uma pessoa revisa.
```
