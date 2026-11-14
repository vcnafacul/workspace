# Adaptador: superpowers (v7.x)

Como as skills do superpowers produzem os artefatos do `docs/contrato-de-desenvolvimento.md`.
**Estas instruções têm precedência sobre os padrões das skills** (a própria skill `using-superpowers` diz
que instruções do usuário em CLAUDE.md/AGENTS.md vencem).

| Skill | Sob o contrato |
|---|---|
| `brainstorming` | **Não** roda para relato de problema da QA: esse vira card no board pela skill `criar-ticket`, e o brainstorming fica para quem pegar o card. Roda com o ticket em `planejando`. A spec vai para **`tickets/NNN-slug/spec.md`** — nunca `docs/superpowers/specs/` — com decisões `D1…Dn` no modelo `docs/modelos/spec.md`. Transcrição ou material do visual companion que valha guardar vai em `planejamento/`. |
| `writing-plans` | Escreve **`tickets/NNN-slug/plano.md`** — nunca `docs/superpowers/plans/`. Um plano por ticket; **toda Task nomeia o seu card**. Logo depois, crie os cards e passe o ticket a `pronto`. |
| `using-git-worktrees` | Preferência declarada: worktree só para sessões simultâneas, em `.worktrees/<repo>/NNN-NN` via `git -C <repo> worktree add`. Não use o `EnterWorktree` nativo na raiz. |
| `executing-plans`, `subagent-driven-development`, `dispatching-parallel-agents` | Sim. Cada card é executado no seu repo. |
| `test-driven-development`, `systematic-debugging`, `verification-before-completion`, `requesting-code-review`, `receiving-code-review` | Sim, sem mudança. |
| `finishing-a-development-branch` | Sim, mas "abrir PR" é **sempre pela skill `abrir-pr`** do workspace. |
| `writing-skills` | Sim, só para skills do workspace (`.claude/skills/`). |

**Fluxo**: issue (opcional) → ticket em `planejando` (`README.md`) → `brainstorming` → `spec.md` →
`writing-plans` → `plano.md` + cards → ticket `pronto` → por card: assumir, branch, executar, `abrir-pr` →
merge → card `concluido` → ticket `concluido` + `## Como ficou`.

**Instalação**: `.claude/settings.json` já habilita `superpowers@claude-plugins-official`; cada pessoa roda
uma vez, na raiz do workspace: `claude plugin install superpowers@claude-plugins-official --scope project`.
Para desligar só para você: `"enabledPlugins": {"superpowers@claude-plugins-official": false}` no seu
`.claude/settings.local.json`.
