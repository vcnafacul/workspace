---
titulo: Pin do mapa de cursinho pula para o centro do CEP
status: pronto
issue:
criado: 2026-11-14
responsavel: cleytonbiffe
repos: [client-vcnafacul, docs]
---

## Objetivo

**O problema.** Ao cadastrar um cursinho no Localiza Cursinho, a pessoa marca no mapa onde ele fica, e o pin
pula sozinho para o centro da cidade. Isso acontece logo depois de marcar e toda vez que a pessoa volta uma
etapa e avança de novo. No painel, só abrir a edição de um cursinho e salvar já pode trocar a localização
salva. O resultado é o cursinho aparecendo no lugar errado para os estudantes.

**A causa.** Duas coisas movem o pin: o clique no mapa e a mudança do CEP, que busca o CEP na BrasilAPI e
põe o pin na coordenada devolvida, muitas vezes o centro da cidade. Uma flag de uso único (`clicou`) tenta
separar as duas e falha sempre que o CEP muda sem vir de um clique, inclusive quando a tela restaura um CEP
já salvo. O mesmo código se repete em 3 telas do client. Detalhes, com `arquivo:linha`, em
`pesquisa/causa-raiz.md`.

**A solução** (`spec.md` D1). As 3 telas passam a usar um só componente de mapa com endereço, em que um
modo explícito, **"Seguir o CEP"** ou **"Ponto no mapa"**, decide quem move o pin. Clicar no mapa passa
para "Ponto no mapa", e a edição já começa nele (D2).

## Muda algum fluxo de quem usa a plataforma?

Sim. O cadastro de cursinho ganha o controle de modo do pin (duas opções de rádio, `spec.md` D3). Card
`02-DOCS`.

## Ordem de deploy

client-vcnafacul → docs. Só o client tem código. O site de ajuda é atualizado depois que a mudança estiver
no ar.

## Fica para depois

- Corrigir localizações já salvas erradas no banco. Não há como saber quais foram afetadas: se for preciso,
  é revisão manual no painel.
- Mover as chamadas ao Nominatim e à BrasilAPI para o back-end ou pôr cache nelas.
- Arrastar o pin como alternativa ao clique.
