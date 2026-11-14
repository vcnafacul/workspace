# Workspace do Você na Facul

Este repo (`vcnafacul/workspace`) é a pasta-mãe dos repos da plataforma. Ele guarda o planejamento e o
registro de tudo o que é desenvolvido (`tickets/`), a documentação de desenvolvimento (`docs/`,
`CONTEXT.md`) e as instruções para agentes. **Os repos de código ficam em subpastas ignoradas** — cada um
tem o seu próprio git.

## Comece pela raiz

**Abra a sessão na raiz do workspace**, não dentro de um repo. Só aqui valem as skills, os plugins, os hooks
e estas instruções. Para trabalhar num repo, leia e edite `<repo>/…` a partir da raiz. Antes de começar,
confira `./ws status` (o hook de início de sessão já mostra o resumo); se algo estiver desatualizado,
`./ws atualizar`.

## Repos

(gerado de `repos.txt` — mantenha os dois em acordo)

| Repo | O que é | Testes | Lint | Rodar |
|---|---|---|---|---|
| `api-vcnafacul` | Gateway NestJS + TypeORM (MySQL). Autenticação, cursinhos, processos seletivos, matrículas, frequência | `yarn test` (sobe um MySQL de teste no Docker) | `yarn lint` | `yarn dev` · migrations `yarn migration:run` |
| `client-vcnafacul` | SPA React + Vite (Tailwind, shadcn) | `yarn test` (**suíte completa**; o CI pula `DashToolbar.test.tsx`) | `ESLINT_USE_FLAT_CONFIG=false npx eslint <caminhos>` (**`yarn lint` está quebrado**) | `yarn dev` · vitrine em `/dev/vitrine` |
| `ms-simulado` | Microsserviço NestJS + Mongoose (Mongo rs0): provas, simulados, questões, relatórios | `yarn test` · `yarn test:e2e` | `yarn lint` | `yarn dev` · migrações `yarn migracoes` |
| `ms-omr` | Microsserviço Python 3.11 + FastAPI + OMRChecker: leitura de cartão-resposta | `uv run pytest` (o CI pula `-m integration`; rode tudo localmente) | `uv run ruff check .` | `make up` |
| `vcnafacul-form` | Microsserviço NestJS + Mongoose: construtor de formulários, usado em processos seletivos | `yarn test` | `yarn lint` | `yarn dev` |
| `vcnafacul-stack` | Docker compose da plataforma inteira (local, homol, prod) | — | — | `make up` (local) · `make infra` (só bancos) · `make up-homol` |

`yarn lint` na api, no ms-simulado e no form roda com `--fix` e altera arquivos: revise o diff depois.

Como os serviços conversam: `docs/arquitetura.md`. **Nada de instrução para agentes entra no
`vcnafacul-stack`** — ele é clonado nos servidores e atualizado a cada deploy.

## Como trabalhamos

Leia **`docs/contrato-de-desenvolvimento.md`** antes de criar ou mudar qualquer ticket, card, spec ou plano.
O essencial:

- Mudança que decide algo, toca mais de um repo ou precisa de mais de um PR → **ticket** em
  `tickets/NNN-slug/` (próximo número = maior existente + 1). Senão, basta o PR.
- Ticket → `README.md`, `spec.md` (decisões `D1…Dn`), `plano.md` e cards `NN-AREA-slug.md` (um PR por repo).
  Problema visto na plataforma (em geral pela QA) vira **card no board pela skill `criar-ticket`**; o ticket
  em `tickets/` é criado por quem pegar o card para desenvolver.
- Branch `<tipo>/NNN-NN-slug`, igual em todos os repos do card. PR para `develop`; empilhe só quando
  precisar, e o merge é de baixo para cima. Título termina em `(NNN/NN)`. **Abra PRs pela skill `abrir-pr`.**
- Cite em código como `tickets/NNN`, `tickets/NNN/NN` ou `tickets/NNN D3`.
- Assuma um card escrevendo `responsavel` + `status` e fazendo **push no `main` do workspace antes** de
  começar.
- Ordem de deploy padrão: ms-omr / ms-simulado / vcnafacul-form → api → client.

O conjunto de skills ativo e o seu adaptador estão no `CLAUDE.md`. Outras ferramentas seguem o contrato
diretamente.

## Conteúdo público

Este repo é **público**. Nunca escreva dados pessoais, dados reais de estudantes, hostnames/IPs de
produção ou credenciais (inclusive de homologação) — nem em tickets, nem em PRs, nem em comentários de
código. Prints só de homologação ou fictícios. Valores de `.env` de homologação vêm do time, em privado.

## Documentação

- `CONTEXT.md` — glossário do produto (termos como Processo seletivo, Inscrição, Matrícula). Use os termos de
  lá; termo novo decidido num ticket entra lá.
- `docs/arquitetura.md` — serviços, bancos e fluxos.
- `docs/adr/` — decisões que valem para a plataforma toda.
- `tickets/` — o porquê de cada funcionalidade. `tickets/LEGADO.md` resolve citações antigas.
- Site de ajuda para quem usa a plataforma: repo `docs` (clone com `./ws clonar --com docs`).

## Ferramentas

- `./ws clonar [--com <nome>] [--todos]` · `./ws atualizar` · `./ws status [--curto]`
- `cd vcnafacul-stack && make up` para subir tudo localmente (ver o README da stack).
- Idioma: **pt-BR** em tudo (docs, tickets, PRs, commits).
- Git dentro de um repo filho pede aprovação a partir da raiz; para uma sessão longa num repo só, use
  `/add-dir <repo>`.
