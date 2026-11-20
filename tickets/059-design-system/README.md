---
titulo: Design system do client
status: planejando        # planejando → pronto → em-andamento → concluido | cancelado
issue: vcnafacul/client-vcnafacul#343
criado: 2026-10-28
responsavel: GessioMori
repos: [client-vcnafacul]
---

> **Migrado do wayfinder** (`343-design-system`). O planejamento foi feito em inglês e foi mantido assim:
> `spec.md`, `planejamento/`, `pesquisa/` e `prototipos/` estão em inglês. A spec ganhou os números
> `D1…D16` na migração; o conteúdo é o original.
>
> O número é 059, e não 058, porque o 058 já foi usado pelo ticket "pin do mapa de cursinho", removido em
> vcnafacul/workspace#3. O histórico ainda cita aquele 058.

## Objetivo

Dar ao `client-vcnafacul` um design system definido em código: tokens da marca em variáveis CSS ligadas ao
Tailwind, uma biblioteca de componentes só (shadcn/Radix + cva, em `src/components/ui`), Storybook como
catálogo e testes de guarda que mantêm o código no sistema. A migração de todas as telas e a remoção das
bibliotecas substituídas estão na [spec](spec.md) (§7).

A spec foi fechada em 2026-10-28 sobre o `origin/develop` @ `bdb34525`. **Antes de virar `pronto`, ela será
revista contra o `develop` de hoje**: telas, componentes e bibliotecas que entraram depois daquele commit.

## Muda algum fluxo de quem usa a plataforma?

Não muda fluxos, mas muda a aparência de todas as telas. A spec (D14) prevê uma nota curta de "o que mudou"
para as coordenações de cursinho no lançamento. Se as páginas do site de ajuda tiverem prints, vale um card
`DOCS` no repo `docs` para trocá-los.

## Fica para depois

- A biblioteca no Figma pedida na issue #343: o código é a fonte da verdade (D1).
- Valores do modo escuro: só a estrutura dos tokens precisa permitir (D5).
- Consolidar as bibliotecas de gráficos: só as cores dos gráficos entram.
- Promover o `DashListTemplate` a padrão do design system, depois que o V1 sair.
- Publicar o Storybook.

## Material

- [`spec.md`](spec.md): a spec de implementação, com o índice de decisões em §1.
- [`planejamento/mapa.md`](planejamento/mapa.md): o mapa do wayfinder, com o resumo de cada decisão.
- `planejamento/01…14-*.md`: as perguntas do planejamento, com a justificativa e as alternativas
  descartadas de cada decisão (antes, `tickets/` do wayfinder).
- `planejamento/presentation*.html`: a apresentação da proposta (inglês e pt-BR).
- `pesquisa/`: o inventário da UI e as opções de catálogo.
- `prototipos/`: protótipos HTML descartáveis com o visual decidido (abra no navegador).
