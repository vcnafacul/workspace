---
name: criar-ticket
description: Use quando alguém, em geral a QA (que não programa), quiser registrar no board do GitHub (Project #2 do vcnafacul) um problema ou pedido visto na plataforma — "cria um ticket pra isso", "abre um card", "achei um bug", "registra isso no board", "/criar-ticket".
---

# Criar ticket (card de problema no board)

Transforma o que a QA viu na plataforma em **um card no board que se explica sozinho**: qualquer pessoa, de
dentro ou de fora do projeto, lê e entende o problema sem abrir nada além dele.

**O que esta skill não faz:** não cria pasta em `tickets/`, spec, plano nem cards do contrato, não faz commit
e **não pede para a QA escolher solução**. Quem pegar o card para desenvolver abre uma sessão, investiga e só
então cria o ticket do contrato, com spec e plano. A solução é decisão de quem desenvolve.

**Violar a letra destes passos é violar o espírito.** Os erros que esta skill evita: card que depende de
link, card com jargão, e solução técnica decidida por quem não programa.

## Regras do card

- **Autossuficiente.** Nada de link, caminho, "ver X", número de ticket, PR ou commit. Tudo o que importa está
  no texto.
- **Linguagem de quem usa a plataforma**, no card e na conversa: telas, menus, perfis, ações e regras. Use os
  termos de `CONTEXT.md` (Processo seletivo, Inscrição, Matrícula…) e, para o resto, os nomes como aparecem
  na tela (títulos, botões, menus), entre aspas.
- **Nunca**, nem entre parênteses: arquivo, pasta, linha, função, componente, variável, endpoint, banco,
  tabela, campo, id, serviço externo pelo nome, nome de repo, "api", "client", "front/back".
- **Detalhado.** Passos para reproduzir com dados fictícios, o esperado, o que acontece, o impacto e os outros
  lugares onde acontece.
- **Sugestões, não decisões.** De 1 a 3 caminhos simples, pelo efeito para quem usa, rotulados como sugestão.
  Nada de "como implementar".
- **Conteúdo público** (contrato §7): nenhum dado pessoal, dado real de estudante, host de produção ou
  credencial. Prints só de homologação ou fictícios.

| Técnico (não escreva) | Como escrever |
|---|---|
| "a mudança do CEP chama a BrasilAPI e move o pin" | "quando o CEP muda, o sistema leva o pin para o ponto central daquele CEP" |
| "o efeito roda de novo ao remontar a etapa" | "ao voltar uma etapa e avançar de novo, o sistema refaz essa conta" |
| "agrupa pelo texto, não pelo `questionId`" | "a planilha junta as respostas pelo enunciado; se o enunciado muda, a mesma pergunta vira duas colunas" |
| "acontece em três componentes do client" | "acontece também no painel, ao criar e ao editar um cursinho" |

## Passos

Para perguntar, use `AskUserQuestion` (sem ela, escreva a pergunta e encerre o turno).

1. **Entenda o relato.** Pergunte só o que faltar, em linguagem de uso: em que tela (e por qual menu se
   chega), com qual perfil, o passo a passo, o que esperava, o que aconteceu, se acontece sempre, desde
   quando, em homologação ou produção. Não invente o que ela não disse.

2. **Investigue, sem mostrar a investigação.** Leia `CONTEXT.md` e `docs/arquitetura.md` e siga o caminho do
   dado nos repos (`./ws clonar` se faltar algum). O código serve só para **você** descrever com precisão:
   - em que condições acontece, inclusive as que a QA não percebeu;
   - outras telas e perfis com o mesmo problema. Em cada uma, confira **todas** as condições de novo,
     inclusive só abrir a tela, voltar, editar e salvar sem mexer, que costumam ser as mais graves;
   - a consequência: algo fica salvo errado? um dado que estava certo pode ser estragado? quem vê o erro
     depois?
   - se parte do relato é a regra atual funcionando, e não um defeito.

   Reproduzir é desejável, não obrigatório. Para bug, siga a fase 1 (investigação) de
   superpowers:systematic-debugging, sem propor correção técnica.

3. **Confirme o que mudou no entendimento.** Se a investigação trouxe algo que a QA não disse (outro lugar
   afetado, condição diferente, "isso é a regra hoje"), conte em linguagem de uso e confirme antes de
   escrever. Se a análise **contradiz** o relato, diga isso com cuidado, peça para a QA repetir o teste com
   os passos que você encontrou e registre a divergência em "Observações". Se nada mudou, siga.

4. **Escreva o rascunho e mostre. Pare.** Escreva o card (modelo abaixo) num arquivo no scratchpad, nunca no
   workspace. Mostre **o texto inteiro** à QA e sugira os campos do board, com uma explicação curta de cada um:
   - **Tipo:** Bug (algo quebrado), Melhoria (algo novo ou uma regra que muda), Ajuste (texto ou aparência);
   - **Prioridade:** Internal-P1 (importante, fila normal), Urgent-P0 (largar tudo), Internal-P2 (pode
     esperar);
   - **Assunto:** Epic e Story pelo tema (`references/campos-do-board.md`); com várias telas, a Story da
     tela onde a QA viu o problema.

   A Prioridade sobe para Urgent-P0 quando um dado certo pode ser estragado ou quando quem usa fica travado
   sem alternativa.

   Area (a parte com mais trabalho) e Status (To Do) você define e só informa. Peça o OK para publicar ou os
   ajustes. Sem OK explícito, nada vai para o GitHub.

5. **Publique.** Siga **todas** as regras de `references/board.md`: leituras primeiro, depois **2 escritas**
   pelo script, **um card só**, mesmo que o problema apareça em várias partes do sistema.

6. **Relate** à QA: o link do board (`https://github.com/orgs/vcnafacul/projects/2`), a coluna (To Do) e o
   título do card.

## Modelo do card

**Título:** o problema numa frase de uso, sem número e sem prefixo. Ex.: "Pin do mapa volta para o centro do
CEP ao cadastrar um cursinho".

```markdown
## O que acontece
<2–4 linhas: o problema, para quem nunca usou essa tela.>

## Onde
- **Tela:** <nome e como chegar: menu › submenu>
- **Perfil:** <estudante, equipe do cursinho, admin…>
- **Ambiente:** <homologação | produção | ambos>

## Como reproduzir
1. <passo, com dados fictícios>
2. …

**Esperado:** <o que deveria acontecer>
**Acontece:** <o que acontece>

## Impacto
<Quem é afetado, o que fica salvo errado, quem vê o erro depois, com que frequência.>

## Também acontece em
- <outra tela ou fluxo, e em que condição> (ou "Não encontrei em outros lugares.")

## Por que acontece
<A regra que o sistema segue hoje, em linguagem de uso, com um exemplo. Se parte do relato é a regra
funcionando, diga aqui.>

## Sugestões de caminho
_Sugestões para quem for desenvolver. A decisão é de quem pegar o card._
- <caminho, pelo efeito para quem usa>

## Observações
<Se foi reproduzido pela QA, se a explicação veio da análise do funcionamento, desde quando acontece.>
```

## Racionalizações

| Desculpa | Realidade |
|---|---|
| "Ponho o arquivo e a linha para o dev achar rápido" | O dev investiga de novo, com o código na mão. No card, isso é ruído e envelhece |
| "Linko o ticket com os detalhes" | Não há ticket ainda. O card se explica sozinho |
| "Pergunto à QA qual solução prefere" | Solução é decisão de quem desenvolve. A QA confirma o problema |
| "Crio logo o `tickets/NNN` para adiantar" | Quem cria é o dev, quando pegar o card |
| "São duas partes do sistema, faço dois cards" | Um problema, um card. O dev decide como dividir |
| "'Sobe pro board' já é o OK" | O OK é para o texto mostrado no passo 4 |

## Red flags
- No card ou na conversa: link, caminho, `arquivo:linha`, nome de função, componente, repo, "api", "client"
- Pergunta à QA do tipo "qual solução você prefere?"
- Qualquer escrita em `tickets/` ou `git commit`
- `gh` de escrita fora de `scripts/criar-card.sh`, ou antes do OK do passo 4
