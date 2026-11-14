---
titulo: Mapa com endereço e modo do pin nas telas de cursinho
area: FRONT
repos: [client-vcnafacul]
status: aberto
responsavel:
depende_de: []
prs: []
natureza: bug
---

## Objetivo

Criar o componente de mapa com endereço e modo explícito do pin, "Seguir o CEP" ou "Ponto no mapa"
(`tickets/058 D1`, D2, D3), e usá-lo no cadastro público e nos modais de criar e editar cursinho do painel. Os
arquivos e as linhas estão em `pesquisa/causa-raiz.md`.

## Critérios de aceite

- [ ] As 3 telas (`geoForm/steps/step3.tsx`, `modalCreateDashGeo.tsx`, `modalEditDashGeo/index.tsx`) usam o
      mesmo componente, e a flag `clicou`/`clicked` não existe mais.
- [ ] Em "Seguir o CEP", digitar um CEP válido preenche o endereço e põe o pin na coordenada do CEP.
- [ ] Em "Ponto no mapa", mudar o CEP, à mão ou pela busca reversa, preenche só os campos de texto. O pin
      não se move.
- [ ] Cadastro público: marcar um ponto, voltar uma etapa e avançar mostra o pin no mesmo ponto e no mesmo modo, sem
      consultar a BrasilAPI na montagem.
- [ ] Editar no painel: abrir a edição e salvar sem mexer no mapa mantém a `latitude`/`longitude` salvas.
- [ ] O cadastro público e o modal de criar começam em "Seguir o CEP", e o modal de editar começa em "Ponto
      no mapa" (`tickets/058 D2`).
- [ ] Em "Seguir o CEP", clicar no mapa põe o pin no ponto e passa o modo para "Ponto no mapa"
      (`tickets/058 D2`).
- [ ] O controle são duas opções de rádio, "Seguir o CEP" e "Ponto no mapa" (`tickets/058 D3`).
- [ ] Dois cliques seguidos em ruas diferentes deixam o pin no último ponto, mesmo com respostas do
      Nominatim fora de ordem.
- [ ] O payload enviado à api (`createGeolocation` e `UpdateGeolocation`) não ganha campos novos.
- [ ] Testes (Vitest + Testing Library) cobrem os critérios acima, simulando `react-leaflet` e o `fetch` do
      Nominatim e da BrasilAPI (padrão de `src/components/molecules/mapBox/mapBox.test.tsx`).
- [ ] Prints no PR só com dados fictícios.

## Notas

Decidido depois da criação do ticket: modo inicial e efeito do clique em `tickets/058 D2`, formato do
controle em `tickets/058 D3`.

**Em aberto** (decidir antes de começar; o que for decidido vira `D4…Dn` na spec):
1. **O checkbox "Definir localização manualmente"**: some, substituído pelo controle, ou continua (e com
   qual papel)?
2. **Correções vizinhas** (`postcode` sem checagem, `MapEvents`/`CenterMap` no render): entram neste card?

Dicas:
- Para descartar respostas antigas do Nominatim, use um contador do último clique ou um `AbortController`.
- O modo é estado de tela e não vai para a api.

- [ ] Afeta a arquitetura? → atualizar docs/arquitetura.md neste card
