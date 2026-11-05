---
name: abrir-pr
description: Abre o PR de um card em qualquer repo do workspace, rodando antes as verificações daquele repo e registrando o PR no card. Use sempre que for abrir um pull request em um repo da plataforma.
---

# Abrir o PR de um card

Execute **na ordem** e **pare no primeiro passo que falhar**. Rode os comandos dentro da pasta do repo.
Sem ticket (mudança pequena, ver o contrato §2), pule o que diz respeito ao card.

## 1. Leia o card

Leia `tickets/NNN-slug/NN-AREA-slug.md` e confirme que o ticket tem `spec.md` se ele decide algo. Sem spec,
pare e avise.

## 2. Confira a branch

```bash
git diff --name-only <base>...HEAD
git log --oneline <base>..HEAD
git diff <base>...HEAD --stat
```

- **Recuse** se a branch tocar `docs/superpowers/`: specs e planos ficam no ticket.
- Procure `console.log`, `.only` em `describe`/`it`, arquivo fora do escopo do card, e qualquer mudança em
  lockfile que não tenha sido de propósito.
- Confira o conteúdo contra a regra de conteúdo público (contrato §7).

## 3. Rode as verificações do repo

| Repo | Verificações |
|---|---|
| `client-vcnafacul` | `yarn test`, `yarn build`, `yarn test:ci`, e o lint dos arquivos alterados (ver abaixo) |
| `api-vcnafacul` | `yarn test` (precisa de Docker) e `yarn lint` |
| `ms-simulado` | `yarn test` e `yarn lint` |
| `vcnafacul-form` | `yarn test` e `yarn lint` |
| `ms-omr` | `uv run pytest` (inclui os testes `integration`, que o CI pula) e `uv run ruff check .` |
| `vcnafacul-stack` | Sem suíte: descreva no PR como a mudança foi testada |

`yarn lint` na api, no ms-simulado e no form roda com `--fix`. Se ele alterar arquivos, revise e faça commit
só do que for parte do card.

### `client-vcnafacul`

⚠️ **O CI não roda a suíte completa.** Ele usa `yarn test:ci`, que exclui
`src/components/dashV2/DashToolbar.test.tsx`. **Só este passo roda esses testes antes de um merge.**

Popover e Tooltip do Radix degradam o jsdom de forma progressiva. Esse arquivo leva quase toda a duração da
suíte, que passava do tempo que o RPC do vitest tolera no runner: a pipeline falhava com
`Timeout calling "onTaskUpdate"` e **todos os testes verdes**. A causa raiz não foi encontrada. As hipóteses já
descartadas estão no docblock no fim daquele arquivo: leia antes de tentar de novo.

- **`yarn test`**: todos os arquivos verdes, incluindo `DashToolbar.test.tsx`.
  - ⚠️ **Confira a contagem, não só a ausência de `FAIL`.** Um arquivo corrompido produz `Tests  no tests` com
    `FAIL`, o que parece falha de asserção e não é. Se o número de testes cair sem você ter removido nenhum,
    investigue antes de seguir.
  - ⚠️ `Errors  1 error` **depois** de `Tests ... passed` é o problema de RPC acima. Confira também o
    `yarn test:ci`, porque o CI vai reagir diferente.
- **`yarn build`**: o CI também roda. ⚠️ Ele suja `tsconfig.app.tsbuildinfo`, que é rastreado. Restaure antes
  de fazer commit: `git checkout -- tsconfig.app.tsbuildinfo`.
- **`yarn test:ci`**: se este passar e o `yarn test` tiver falhado, **não abra o PR**. O CI ficaria verde
  escondendo um teste quebrado.
- **Lint**: ⚠️ **não rode `yarn lint`.** Está quebrado (ESLint 9 com `.eslintrc.cjs` legado). Use
  `ESLINT_USE_FLAT_CONFIG=false npx eslint <caminhos explícitos>`.

## 4. Abra o PR

**Base:** `develop`. Se o card precisa do código de outro card do mesmo repo ainda não mergeado, a base é a
branch desse card, e o corpo diz `Base: #N (NNN/MM)`. O merge é de baixo para cima.

**Título:** `<tipo>(<escopo>): <descrição> (NNN/NN)`.

**Corpo:** escreva a partir de `docs/modelos/pr.md`. Linke o card em vez de repetir o que ele diz. Em
`## Verificação`, registre os comandos, as contagens e o que **não** foi conferido. No client, diga que
`DashToolbar.test.tsx` foi rodado localmente e o que o jsdom não alcança (layout, densidade, sticky, truncamento).

```bash
git push -u origin <branch>
gh pr create --base <base> --title "<título>" --body-file <arquivo>
```

## 5. Registre o PR no card

No workspace, escreva `vcnafacul/<repo>#N` em `prs` no card e passe para `status: em-revisao`. Depois, faça
commit e push no `main` do workspace, só desse arquivo.

## Não faça

- ⚠️ **Não use `git add -A` nem `git add .`.** Sempre caminhos explícitos.
- ⚠️ **Não rode `yarn install` sem necessidade.** Use `--frozen-lockfile`, que falha em vez de reescrever o
  lockfile.
