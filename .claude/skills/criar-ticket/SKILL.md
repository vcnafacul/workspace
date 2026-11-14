---
name: criar-ticket
description: Use quando alguém pedir para criar ou abrir um ticket a partir de um bug, pedido ou contexto ("cria um ticket pra isso", "abre um ticket", "registra isso como ticket", "/criar-ticket"), inclusive quando também pedir para subir o ticket para o board do GitHub (Project #2 do vcnafacul).
---

# Criar ticket

Do contexto ao ticket em `tickets/NNN-slug/` e, **só com o OK de quem pediu**, a um draft no board. Quem pediu
escolhe a solução e o recorte. O agente investiga e propõe; não decide por essa pessoa.

**Violar a letra destes passos é violar o espírito.** Os erros que esta skill evita: escrever D1 sozinho, juntar
repos num ticket sem perguntar e criar os arquivos antes das escolhas.

## Passos

Na ordem. Os passos 3 e 4 são **paradas**: espere a resposta antes de seguir.

1. **Prepare o workspace.** Leia `docs/contrato-de-desenvolvimento.md` e os modelos em `docs/modelos/`. Repo
   que falta → `./ws clonar`. O commit do passo 7 vai no `main` atualizado: se o workspace estiver em outra
   branch ou com mudanças, **não troque nem descarte nada agora**; isso se resolve no passo 7, com a pessoa.

2. **Ache a causa raiz.** Siga o dado de ponta a ponta nos repos (`docs/arquitetura.md` mostra o caminho):
   client → api → microsserviço → banco. Para cada elo, `arquivo:linha`. Procure **o mesmo defeito em outros
   lugares** (outra tela, outro export, outro serviço). Para bug, siga a fase 1 (investigação) de
   superpowers:systematic-debugging. Reproduzir é desejável, não obrigatório: se a causa vier só da leitura do
   código, diga isso no passo 3. Falta informação para seguir? Pergunte, em vez de supor.

3. **Mostre a causa e proponha soluções. Pare.** Use `AskUserQuestion` (sem ela, escreva a pergunta e
   encerre o turno):
   - A causa raiz em 2–4 linhas, com `arquivo:linha`, todos os lugares afetados e se foi reproduzida.
   - **De 2 a 4 soluções**, cada uma com prós, contras, repos tocados e tamanho (P/M/G). Recomende uma, como
     primeira opção, com "(Recomendado)".
   - Uma única solução óbvia ainda é apresentada, com a alternativa mais próxima, para a pessoa confirmar.

4. **A solução toca mais de um repo? Pergunte o recorte. Pare.** "Um ticket com um card por repo" ou "um
   ticket por repo". Quem decide é a pessoa. Se só algumas soluções tocam mais de um repo, faça a pergunta
   junto da do passo 3, condicionada a elas. Com um repo só, pule.

5. **Escreva o ticket** com o que foi escolhido, a partir de `docs/modelos/`:
   - Número = maior `tickets/NNN` + 1 (o primeiro é `058`). Um ticket por repo → números seguidos, e o
     `README.md` de cada um cita os outros em `## Ordem de deploy`.
   - `README.md`: `status: pronto`, `responsavel:` = login no GitHub de quem pediu (o seu, por
     `gh api user -q .login`, se foi essa pessoa quem chamou), `repos:`, objetivo com a causa raiz, ordem de
     deploy (contrato §5).
   - `spec.md`: **D1 = a solução escolhida**; as outras opções do passo 3 entram como "Alternativas
     descartadas", com o motivo dado pela pessoa (ou "não escolhida por <nome>"). Achados da investigação
     (`arquivo:linha`) vão em `pesquisa/causa-raiz.md`.
   - Um ticket por repo: `spec.md` e `pesquisa/` ficam no ticket de quem produz o dado (ordem de deploy). Os
     outros não decidem nada: sem spec, citam `tickets/NNN D1` no objetivo, e o card usa
     `depende_de: [NNN/NN]`.
   - Cards `NN-AREA-slug.md`, **um por repo**, `natureza: bug` quando for bug, critérios de aceite verificáveis.
   - Decisões menores que a solução abre (permissão, texto, formato): não decida sozinho. Registre em
     `## Notas` do card como "Em aberto" e pergunte no passo 6; o que a pessoa decidir vira `D2…Dn`.
   - **Conteúdo público** (contrato §7): nenhum dado pessoal, dado real de estudante, host de produção ou
     credencial.

6. **Mostre o ticket e peça o OK para o GitHub.** Liste os arquivos e o corpo do card do board (abaixo).
   Pergunte os campos com estes defaults: Status=To Do, Priority=Internal-P1, Flag=Bug (bug) ou Task,
   Epic/Story/Area pelo assunto (`references/campos-do-board.md`). Na mesma pergunta: os pontos "Em aberto"
   e, se o workspace não estiver limpo no `main`, como proceder no passo 7. Sem OK explícito, pare aqui: o
   ticket fica local.

7. **Com o OK:** o ticket vai no `main` (contrato §5). Em outra branch ou com mudanças, pergunte como
   proceder; nunca use `stash`, `reset` nem `checkout --` sem que a pessoa peça. No `main`: `git pull`,
   confira se o número ainda está livre (se não estiver, renumere), commit só da pasta do ticket
   (`git add tickets/NNN-slug`) e push. Se a permissão bloquear o push, peça para a pessoa rodar
   `! git push`. Depois, siga **todas** as regras de
   segurança de `references/board.md`: leituras primeiro, depois **2 escritas** pelo script. Um ticket por
   repo → um draft por ticket, em série.

8. **Registre e relate.** No `README.md`, a linha `Board: draft <item id> em To Do, AAAA-MM-DD`; commit e
   push. Relate os números, os links (`https://github.com/vcnafacul/workspace/tree/main/tickets/NNN-slug`)
   e o id de cada draft.

## Corpo do card do board

Não é card de QA: nada de `[QA]` no título nem checkbox de QA.

- **Título:** `NNN · <titulo do README>`.
- **Corpo:**

```markdown
Ticket [tickets/NNN](https://github.com/vcnafacul/workspace/tree/main/tickets/NNN-slug) · <bug|melhoria> · repos: <repos>

**Problema:** <o que quem usa vê, em linguagem de produto>
**Causa raiz:** <1–2 linhas>
**Solução escolhida:** <D1 em uma linha>

## Cards
- [ ] `NN` · <repo> · <título do card>
```

## Racionalizações

| Desculpa | Realidade |
|---|---|
| "A solução é óbvia, já escrevo a D1" | Quem pediu escolhe. Mostre as opções, mesmo que sejam duas |
| "Escrevo os arquivos e peço revisão depois" | Revisar um ticket pronto empurra para o sim. Arquivo só depois das escolhas |
| "São dois repos do mesmo bug, é um ticket só" | Pode ser, mas quem decide é a pessoa (passo 4) |
| "Uso o formato da ticket-para-board" | Aquele é para QA de série entregue. Aqui é o corpo acima |
| "Sobe pro board" no pedido já é o OK | O OK é para o corpo e os campos mostrados no passo 6 |

## Red flags
- Escrever `spec.md` antes da resposta do passo 3
- Repos afetados > 1 e nenhuma pergunta sobre o recorte
- `gh` de escrita fora de `scripts/criar-card.sh`, ou antes do OK do passo 6
