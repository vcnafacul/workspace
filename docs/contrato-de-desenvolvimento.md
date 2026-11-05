# Contrato de desenvolvimento

Como qualquer pessoa ou agente — com qualquer conjunto de skills — planeja, registra e entrega trabalho
no Você na Facul. Os conjuntos de skills (hoje o superpowers) **se adaptam a este contrato**
(`docs/adaptadores/`); nunca o redefinem. Mudanças neste arquivo só por PR, com uma linha em `## Histórico`.

## 1. Vocabulário

**Ticket**: a unidade de planejamento — uma funcionalidade, mudança ou lote de correções. Vive em
`tickets/NNN-slug/`. _Evite_: série, esforço, épico, issue.
**Card**: a unidade de entrega dentro de um ticket. Vira **um PR por repo que toca**, ou nenhum PR
(QA manual, operação no servidor, tutorial). _Evite_: task, tarefa (são do plano).
**Spec**: as decisões do ticket, `D1…Dn`, com o porquê e as alternativas descartadas.
**Plano**: as tarefas de implementação, `Task N`, cada uma ligada a um card.
**Decisão**: um item `Dn` da spec. Numeração nunca reaproveitada.
**Área**: o tipo de trabalho de um card (não o repo).
**Issue**: um pedido de entrada (bug, ideia, solicitação) aberto em `vcnafacul/workspace`. Não é um
artefato de planejamento.

## 2. Quando abrir um ticket

Abra um ticket quando a mudança **decide algo**, **toca mais de um repo** ou **precisa de mais de um PR**.
Um ticket com um card só é normal. Mudança sem decisão, em um repo e um PR (um typo, um ajuste pontual)
**não precisa de ticket**: o PR (e a issue, se houver) é o registro. Um lote de correções de uma mesma
origem é um ticket comum com vários cards.

## 3. Estrutura de um ticket

```
tickets/NNN-slug/
├── README.md          objetivo, status, issue, ordem de deploy, fica para depois, como ficou
├── spec.md            decisões D1…Dn (obrigatória se o ticket decide algo)
├── plano.md           tarefas Task N → card (opcional, gerado pelo conjunto de skills)
├── 01-BACK-slug.md    cards: NN-AREA-slug.md
├── 02-FRONT-slug.md
├── planejamento/      material do planejamento (mapa e questões, transcrição de brainstorm)
├── pesquisa/          achados de pesquisa
└── prototipos/        protótipos descartáveis
```

Arquivo com número é card; sem número é documento. Tickets concluídos **nunca são apagados nem movidos**:
a pasta é o registro permanente do porquê.

## 4. Identidade e citação

- **Número do ticket**: três dígitos, global e sequencial. Novos tickets começam em **058**; `001`–`057`
  são reservados ao legado (ver `docs/migracao-de-legado.md`). O próximo número é o maior `tickets/NNN`
  + 1, tomado no primeiro commit do ticket. Colisão: o ticket mais novo é renumerado antes de qualquer PR
  citá-lo.
- **Slug**: substantivo em pt-BR, kebab-case. Não muda depois que um PR o cita.
- **Número do card**: dois dígitos por ticket, a partir de `01`; `00` só para um card de pré-requisito.
  Card adicionado depois pega o **próximo número livre** — nada de `01b`. A ordem vem de `depende_de`.
- **Áreas**: `FRONT`, `BACK` (api e microsserviços), `FULL` (as duas pontas), `INFRA` (stack, CI, compose),
  `OPS` (trabalho manual em servidor), `QA` (verificação manual), `DOCS` (site de ajuda ou docs do
  workspace), `PRODUTO` (decisão de produto sem código). Segurança e bug vão em `natureza:`.
- **Formas de citação** — uma por nível, em código, testes, commits e PRs:

  | Nível | Forma | Exemplo |
  |---|---|---|
  | Ticket | `tickets/NNN` | `/** Ex-membros (tickets/058) */` |
  | Card | `tickets/NNN/NN` | `it('tickets/058/03: oculta quem saiu', …)` |
  | Decisão | `tickets/NNN D3` | `// tickets/058 D3: guard no handler` |
  | Tarefa | `tickets/NNN Task 5` | só em PRs, se útil |

  Tudo resolve em `https://github.com/vcnafacul/workspace/tree/main/tickets/`. **Nunca** cite caminho
  local absoluto nem lugar privado.

## 5. Formato e ciclo de vida

**README do ticket** — frontmatter:

```yaml
titulo: Ex-membros do cursinho
status: planejando        # planejando → pronto → em-andamento → concluido | cancelado
issue: vcnafacul/workspace#12   # opcional
criado: 2026-11-10
responsavel: login-no-github
repos: [api-vcnafacul, client-vcnafacul]
```

Seções: `## Objetivo`, `## Muda algum fluxo de quem usa a plataforma?` (se sim, um card `DOCS` no repo
`docs`), `## Ordem de deploy` (quando houver mais de um repo; padrão: quem produz o dado antes de quem
consome — ms-omr / ms-simulado / vcnafacul-form → api → client — e toda exceção traz o motivo),
`## Fica para depois`, e ao concluir `## Como ficou` (o que foi entregue e a lista de PRs).
`pronto` = spec fechada e cards criados.

**Card** — frontmatter:

```yaml
titulo: Lista de ex-membros
area: FULL
repos: [api-vcnafacul, client-vcnafacul]
status: aberto            # aberto → em-andamento → em-revisao → concluido | cancelado
responsavel:
depende_de: [058/02]
prs: []                   # vcnafacul/<repo>#N, preenchido pelo abrir-pr
natureza:                 # opcional: seguranca | bug
```

Seções: `## Objetivo`, `## Critérios de aceite`, `## Notas`, e a caixa
`- [ ] Afeta a arquitetura? → atualizar docs/arquitetura.md neste card`.
`em-revisao` = PR aberto; `concluido` = mergeado (ou feito à mão, para QA/OPS), com a data.

**Spec** — `D1…Dn`, cada uma com porquê e alternativas descartadas. Decisão mudada:
`~~D4~~ substituída por D9`. Nunca renumere.

**Plano** — `Task N`, cada uma com o card. Não é fonte de decisões.

**Assumir trabalho**: preencha `responsavel` e `status: em-andamento` no card (ou ticket), **faça commit e
push no `main` do workspace antes de começar**. Assunção sem push há 7 dias pode ser retomada por outra
pessoa, com uma nota no card.

**Commits no workspace**: artefatos (tickets, cards, status, `## Como ficou`) vão **direto no `main`**.
Mudanças neste contrato, em `AGENTS.md`/`CLAUDE.md`, `.claude/`, `ws` e `repos.txt` vão **por PR**.
Migração de legado vai por PR revisado por uma pessoa.

## 6. Executar um card

- **Branch**: `<tipo>/NNN-NN-slug` (`feat|fix|refactor|chore|ci|docs|test`), **o mesmo nome em todo repo**
  que o card toca. Sem ticket: `<tipo>/slug`.
- **Onde**: no checkout principal do repo, na branch do card. Worktree **só quando duas sessões precisam do
  mesmo repo ao mesmo tempo**: `git -C <repo> worktree add ../.worktrees/<repo>/NNN-NN <branch>`. Não use
  `claude -w` na raiz (o worktree do workspace não tem os repos). A stack monta os checkouts principais.
- **PR**: por padrão para `develop`. **Empilhe** só quando o card precisa do código de outro card **do
  mesmo repo** ainda não mergeado: a base é a branch desse card, e o corpo diz `Base: #N (NNN/MM)`.
  **Merge de baixo para cima**: a base entra na `develop` primeiro, depois a próxima (redirecionada para
  `develop`), e assim por diante.
- **Título**: `<tipo>(<escopo>): <descrição> (NNN/NN)` — um card por PR (se inevitável, `(NNN/NN+MM)`, um
  commit por card).
- **Corpo** (`docs/modelos/pr.md`): primeira linha `Card [tickets/NNN/NN](<link do arquivo>)`; depois
  `## O que muda`, `## Verificação` (comandos com contagens e o que **não** foi conferido), `## Pares` (os
  PRs do mesmo card em outros repos) e `## Depende de` / `Precisa no ar antes:` (vindos de `depende_de`).
  **Não repita o card**: linke. Muda fluxo de usuário? `- [ ] Após o deploy: atualizar <página>.mdx`.
- **Issue**: o PR não usa palavra de fechamento — o ticket fecha a issue. Exceção: PR sem ticket fecha a
  sua com `Closes vcnafacul/workspace#N`.
- **Encerrar**: após o merge, card `concluido` com a data. Todos os cards concluídos → ticket `concluido`
  com `## Como ficou`, e a issue é fechada com um comentário linkando o ticket.

## 7. Conteúdo público (regra dura)

O workspace é público. Em artefatos, corpos de PR e comentários de código, **nunca**: dados pessoais (CPF,
telefone, e-mail de estudantes ou de equipes de cursinho), dados reais de estudantes, hostnames ou IPs de
produção, credenciais (inclusive de homologação). Prints só de homologação ou com dados fictícios. Nomes e
logins do time podem aparecer. Notas operacionais sensíveis vão para o repo `privado`, citado só como
"ver `privado`". Antes de cada commit no workspace, confira o arquivo contra esta regra.

## Histórico

- 2026-11-04 — versão inicial.
