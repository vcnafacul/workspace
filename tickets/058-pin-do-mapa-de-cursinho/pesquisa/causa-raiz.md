# Causa raiz

Investigação de 2026-11-14 no `client-vcnafacul` (`develop`, commit `6d782d4d`). Tudo vem da **leitura do
código**: não houve reprodução no navegador.

## O mecanismo

Duas coisas escrevem na posição do pin (`selectedPosition`):

1. **O clique no mapa** (`MapEvents` → `useMapEvents.click`): põe o pin no ponto e chama
   `getCepByLatAndLon` (Nominatim, busca reversa). A resposta preenche os campos, **inclusive o `cep`**.
2. **O efeito em `[cep]`**: quando o `cep` tem 8 dígitos, chama a BrasilAPI (`/api/cep/v2/{cep}`), e
   `setAddressFromCep` põe o pin em `location.coordinates`. Para o CEP geral de uma cidade, essa coordenada é
   o centro dela.

O freio é a flag `clicou`/`clicked`: o clique a liga e o efeito do CEP a desliga na primeira mudança. Qualquer
mudança de CEP com a flag desligada move o pin:

- **CEP restaurado na montagem**: a tela devolve ao formulário um CEP salvo, o `watch("cep")` vê isso como
  mudança, e o pin vai para a coordenada do CEP, apagando a que estava salva.
- **CEP digitado ou corrigido** depois de marcar o ponto.
- **Dois cliques em ruas diferentes** antes de o Nominatim responder: a primeira resposta desliga a flag e a
  segunda passa pela BrasilAPI.

## Onde acontece

| Tela | Arquivo | Efeito do CEP | Move o pin | Gatilho na montagem |
|---|---|---|---|---|
| Cadastro público, etapa de endereço | `src/components/organisms/geoForm/steps/step3.tsx` | `:129` | `:110` | `:77` (`reset(formData)` ao voltar para a etapa; o `GeoForm` desmonta a etapa a cada troca) |
| Painel, criar cursinho | `src/pages/dashGeo/modals/modalCreateDashGeo.tsx` | `:139` | `:129` | nenhum (só CEP digitado ou cliques seguidos) |
| Painel, editar cursinho | `src/pages/dashGeo/modals/modalEditDashGeo/index.tsx` | `:488` | `:388` | `:464` (`setValue("cep", geo.cep)` ao abrir) |

No modal de edição, `UpdateGeo` envia `selectedPosition` ao salvar (`:157`). Abrir a edição de um cursinho e
salvar qualquer campo pode, então, **gravar a coordenada do CEP no lugar da coordenada real**.

## Problemas vizinhos (mesmo código)

- `data.address.postcode.replace(...)` sem checar se `postcode` existe: `step3.tsx:89`,
  `modalCreateDashGeo.tsx:151`, `modalEditDashGeo/index.tsx:269`. Quando o Nominatim não devolve CEP, quem
  cadastra vê um erro genérico.
- `MapEvents` e `CenterMap` são declarados dentro do render (`step3.tsx:136` e `:171`,
  `modalCreateDashGeo.tsx:175` e `:198`, `modalEditDashGeo/index.tsx:293` e `:317`). Eles remontam a cada render
  e o `CenterMap` recentraliza o mapa toda vez.
- O checkbox "Definir localização manualmente" (`useCep`, `step3.tsx:36`) só desliga a busca reversa do
  clique: o CEP continua movendo o pin.
- Em desenvolvimento, o `React.StrictMode` (`src/main.tsx:30`) roda os efeitos de montagem duas vezes.

## Fora do defeito

A api só guarda a coordenada recebida (`api-vcnafacul/src/modules/geo/geo.entity.ts:10`,
`dto/create-geo.dto.input.ts:15`). A busca do Localiza Cursinho (`src/pages/geoSearch/`) só lê coordenadas
salvas e não move pin com base em CEP.
