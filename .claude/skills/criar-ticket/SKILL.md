---
name: criar-ticket
description: Use quando alguém pedir para criar ou abrir um ticket a partir de um bug, pedido ou contexto ("cria um ticket pra isso", "abre um ticket", "registra isso como ticket", "achei um problema na plataforma", "/criar-ticket"), inclusive quando também pedir para subir o ticket para o board do GitHub (Project #2 do vcnafacul). Vale também quando quem pede é QA ou outra pessoa que não programa.
---

# Criar ticket

Do relato ao ticket em `tickets/NNN-slug/` e, **só com o OK de quem pediu**, a um draft no board. Quem pediu
escolhe a solução e o recorte. O agente investiga e propõe; não decide por essa pessoa.

**Quem chama, em geral, não programa**: é QA ou alguém do time que conhece a plataforma pelo uso. Ela não
escolhe bem entre opções que não entende. Por isso há **duas linguagens**:

| Onde | Linguagem |
|---|---|
| Tudo o que você diz ou pergunta à pessoa | **Linguagem de quem usa a plataforma** (ver "Como falar") |
| `pesquisa/causa-raiz.md`, cards (`## Notas`), `spec.md` (o porquê técnico) | Técnica, com `arquivo:linha`: é para quem vai desenvolver |
| `README.md` (`## Objetivo`) e o corpo do board | Linguagem de quem usa |

**Violar a letra destes passos é violar o espírito.** Os erros que esta skill evita: decidir a solução
sozinho, juntar partes do sistema num ticket sem perguntar, criar os arquivos antes das escolhas e fazer
perguntas que só um dev entende.

## Como falar com a pessoa

- Fale de **telas, perfis, ações e regras**: "na tela de inscritos, quem administra o cursinho clica em
  Exportar". Use os termos de `CONTEXT.md` (Processo seletivo, Inscrição, Matrícula…).
- **Nunca** cite na conversa: arquivo, pasta, linha, função, componente, endpoint, rota, banco, tabela,
  coluna, campo, id, nomes de repo (`api-vcnafacul`, `client`…), "front/back", "api", "microsserviço",
  "deploy", "branch", "commit", "PR". Mesmo entre parênteses. Mesmo "para referência".
- Explique a causa como uma **regra**: "quando acontece X, o sistema faz Y; por isso a pessoa vê Z". Dê um
  exemplo concreto com dados fictícios.
- Explique cada opção pelo **efeito para quem usa**: o que passa a acontecer, o que não resolve, quem sente a
  mudança, e o esforço em palavras (pequeno: dias; médio: uma ou duas semanas; grande: mais que isso).
- Termo técnico que não dá para evitar? Explique em uma frase simples na primeira vez.

| Técnico (não diga) | Como dizer |
|---|---|
| "agrupa pelo texto, não pelo `questionId`" | "a planilha junta as respostas pelo enunciado da pergunta; se o enunciado muda, a mesma pergunta vira duas colunas" |
| "toca api e client" / "dois repos" | "muda duas partes do sistema: a que prepara os dados e a tela que os mostra" |
| "gerar o xlsx no backend" | "o arquivo passa a ser montado pelo sistema, não mais pelo navegador de quem clica" |
| "falta validação no DTO" | "o sistema aceita uma data de fim antes da data de início" |
| "não reproduzi, foi pela leitura do código" | "ainda não consegui repetir o problema; pela regra que encontrei, é isso que acontece" |

## Passos

Na ordem. Os passos 3, 4, 5 e 7 são **paradas**: espere a resposta antes de seguir. Para perguntar, use
`AskUserQuestion` (sem ela, escreva a pergunta e encerre o turno). Os rótulos das opções também seguem
"Como falar".

1. **Prepare o workspace.** Leia `docs/contrato-de-desenvolvimento.md` e `CONTEXT.md` (os modelos de
   `docs/modelos/` só no passo 6). Repo que falta → `./ws clonar`. O commit do passo 8 vai no `main` atualizado: se o
   workspace estiver em outra branch ou com mudanças, **não troque nem descarte nada agora**.

2. **Entenda o relato e ache a causa raiz.** Falta algo para investigar? Pergunte em linguagem de uso: em
   que tela, com qual perfil (estudante, cursinho, admin…), o que fez, o que esperava, o que aconteceu, se
   acontece sempre e desde quando. Depois, siga o dado de ponta a ponta nos repos (`docs/arquitetura.md`),
   anotando `arquivo:linha` para o `pesquisa/causa-raiz.md`. Procure **o mesmo defeito em outras telas ou
   fluxos**. Para bug, siga a fase 1 (investigação) de superpowers:systematic-debugging; reproduzir é
   desejável, não obrigatório.

3. **Explique a causa e proponha soluções. Pare.**
   - A causa como regra, com um exemplo, curta (um bloco por causa); outras telas ou fluxos com o mesmo
     problema; e se o problema foi repetido ou só deduzido.
   - **Separe defeito de regra.** Se parte do que a pessoa viu é a regra atual funcionando, diga isso com
     clareza ("hoje a regra é esta, e ela está funcionando"), sem tratar como erro dela. Mudar a regra entra
     como uma das opções, e você avisa que é uma decisão de produto que muda algo para quem usa.
   - **De 2 a 4 soluções**, cada uma pelo efeito para quem usa, com o que melhora, o que piora ou não resolve,
     e o esforço. Recomende uma, como primeira opção, com "(Recomendado)", e diga por quê em uma frase.
     Recomende pelo que a pessoa esperava ver e pelo risco para quem usa, não só pelo menor esforço. Se a
     recomendação não atende o que ela esperava, diga isso explicitamente.
   - Uma única solução óbvia ainda é apresentada, com a alternativa mais próxima, para a pessoa confirmar.

4. **A solução muda mais de uma parte do sistema? Pergunte o recorte. Pare.** Parte = repo: duas telas do
   mesmo repo são uma parte só. Explique quais são as partes, em linguagem de uso, e as duas opções:
   - "**Um ticket só**: tudo é acompanhado junto e só fica pronto quando todas as partes estiverem prontas."
   - "**Um ticket por parte**: cada parte pode ser feita por uma pessoa diferente e entregue no seu tempo; a
     parte que depende da outra espera por ela."

   Se só algumas soluções mudam mais de uma parte, faça as duas perguntas no mesmo `AskUserQuestion`; a do
   recorte começa com "Se escolher a opção X…" e a resposta dela vale só nesse caso. Com uma parte só, pule.

5. **Pergunte os detalhes da solução escolhida. Pare.** Volte ao código com a escolha em mãos e procure o
   que ela deixa em aberto **para quem usa**: outras telas, relatórios ou perfis que a regra nova alcança e
   que a opção não citou; textos, ordem, quem pode ver; casos de borda ("e se todas as faltas forem
   justificadas?"). Pergunte tudo de uma vez (até 4 perguntas), em linguagem de uso, com opções e uma
   recomendada. O que ela decidir vira `D2…Dn`. Se a descoberta muda o tamanho da solução escolhida, diga isso
   e ofereça voltar ao passo 3. Se uma opção desfaz algo decidido num ticket anterior (`tickets/`), diga isso
   em linguagem de uso ("isso foi combinado de propósito antes, por este motivo…"); na spec, a decisão nova
   cita a antiga (`tickets/NNN Dn`). Detalhes puramente técnicos não são perguntados: ficam em `## Notas` do card
   como "Em aberto", para quem desenvolver. Nada em aberto para quem usa? Pule.

6. **Escreva o ticket** com o que foi escolhido, a partir de `docs/modelos/` (sem as linhas de instrução dos
   modelos):
   - Número = maior `tickets/NNN` + 1 (o primeiro é `058`). Um ticket por repo → números seguidos, e o
     `README.md` de cada um cita os outros em `## Ordem de deploy`.
   - `README.md`: `status: pronto`, `responsavel:` = login no GitHub de quem pediu (`gh api user -q .login`
     é o de quem está logado; se não for a pessoa, deixe vazio e pergunte no passo 7), `repos:`, objetivo em
     linguagem de uso, ordem de deploy (contrato §5).
   - `spec.md`: **D1 = a solução escolhida**, `D2…Dn` = os detalhes do passo 5; as outras opções do passo 3
     entram como "Alternativas descartadas", com o motivo dado pela pessoa. Os achados técnicos vão em
     `pesquisa/causa-raiz.md`.
   - Um ticket por repo: `spec.md` e `pesquisa/` ficam no ticket de quem produz o dado (ordem de deploy). Os
     outros não decidem nada: sem spec, citam `tickets/NNN D1` no objetivo, e o card usa
     `depende_de: [NNN/NN]`.
   - Cards `NN-AREA-slug.md`, **um por repo**, `natureza: bug` quando for bug. Critérios de aceite como
     **comportamentos que a QA consegue conferir na tela** (ação → resultado), mais os técnicos que fizerem
     falta.
   - Nada de decidir sozinho algo que muda o que quem usa vê: se aparecer agora, volte ao passo 5.
   - **Conteúdo público** (contrato §7): nenhum dado pessoal, dado real de estudante, host de produção ou
     credencial.

7. **Resuma o ticket e peça o OK para publicar. Pare.** Sem listar arquivos nem mostrar markdown: em poucas
   linhas, o número, o problema, a solução escolhida (com os detalhes do passo 5) e o que vai ser feito,
   inclusive atualizar o site de ajuda, se houver card `DOCS`. Na mesma pergunta:
   - Os campos do board, com os valores sugeridos e uma explicação curta de cada um: **Prioridade**
     (Internal-P1 = importante, entra na fila normal; Urgent-P0 = largar tudo), **Tipo** (Bug = algo quebrado;
     Melhoria = algo novo ou uma regra que muda; Ajuste = correção pequena de texto ou aparência),
     **Assunto** (Epic/Story, pelo tema: ver `references/campos-do-board.md`). Area (a parte com mais
     trabalho) e Status (To Do) você define sozinho e só informa.
   - Se o workspace não estiver no `main` ou tiver mudanças: "tem outro trabalho em andamento nesta pasta;
     posso guardar o ticket sem mexer nele?", e espere.

   Sem OK explícito, pare aqui: o ticket fica só neste computador.

8. **Com o OK:** o ticket vai no `main` (contrato §5). Nunca use `stash`, `reset` nem `checkout --` sem que
   a pessoa peça. No `main`: `git pull`, confira se o número ainda está livre (se não estiver, renumere),
   commit só da pasta do ticket (`git add tickets/NNN-slug`) e push. Se a permissão bloquear o envio, diga:
   "Para eu enviar o ticket, digite `! git push` aqui na conversa e aperte Enter." Depois, siga **todas** as
   regras de `references/board.md`: leituras primeiro, depois **2 escritas** pelo script. Um ticket por repo →
   um draft por ticket, em série.

9. **Registre e relate.** No `README.md`, a linha `Board: draft <item id> em To Do, AAAA-MM-DD`; commit e
   push. Para a pessoa, em linguagem de uso: o número de cada ticket, o link do ticket
   (`https://github.com/vcnafacul/workspace/tree/main/tickets/NNN-slug`) e o do board
   (`https://github.com/orgs/vcnafacul/projects/2`), e onde o card aparece (coluna To Do).

## Corpo do card do board

Não é card de QA: nada de `[QA]` no título nem checkbox de QA. Problema e solução em linguagem de uso.

- **Título:** `NNN · <titulo do README>`.
- **Corpo:**

```markdown
Ticket [tickets/NNN](https://github.com/vcnafacul/workspace/tree/main/tickets/NNN-slug) · <bug|melhoria> · repos: <repos>

**Problema:** <o que quem usa vê>
**Por que acontece:** <a regra, em 1–2 linhas>
**Solução escolhida:** <D1 em uma linha, pelo efeito para quem usa>

## Cards
- [ ] `NN` · <repo> · <título do card>
```

## Racionalizações

| Desculpa | Realidade |
|---|---|
| "A solução é óbvia, já escrevo a D1" | Quem pediu escolhe. Mostre as opções, mesmo que sejam duas |
| "Escrevo os arquivos e peço revisão depois" | Revisar um ticket pronto empurra para o sim. Arquivo só depois das escolhas |
| "São duas partes do mesmo bug, é um ticket só" | Pode ser, mas quem decide é a pessoa (passo 4) |
| "Cito o arquivo só para dar credibilidade" | Para quem não programa, isso é ruído. Vai no `pesquisa/causa-raiz.md` |
| "Sem o nome técnico a opção fica imprecisa" | Descreva o efeito. A precisão técnica fica no card |
| "Uso o formato da ticket-para-board" | Aquele é para QA de série entregue. Aqui é o corpo acima |
| "Sobe pro board" no pedido já é o OK | O OK é para o resumo e os campos mostrados no passo 7 |

## Red flags
- Na conversa: caminho de arquivo, `arquivo:linha`, nome de função, endpoint, id, nome de repo, "api",
  "client", "front/back"
- Escrever qualquer arquivo do ticket antes das respostas dos passos 3, 4 e 5
- Solução que muda mais de uma parte e nenhuma pergunta sobre o recorte
- `gh` de escrita fora de `scripts/criar-card.sh`, ou antes do OK do passo 7
