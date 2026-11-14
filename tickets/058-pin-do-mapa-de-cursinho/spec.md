# Spec: Pin do mapa de cursinho pula para o centro do CEP

Numeração nunca reaproveitada. Decisão mudada: `~~D4~~ substituída por D9`.

## D1: Um componente de mapa com endereço, com modo explícito do pin, nas 3 telas de cursinho

O cadastro público (`geoForm`, etapa de endereço), o modal de criar cursinho e o modal de editar cursinho no
painel passam a usar **um só componente**. Nele, a posição do pin obedece um modo que a pessoa vê e troca:

- **Seguir o CEP**: a mudança do CEP preenche o endereço e põe o pin na coordenada do CEP, se houver.
- **Ponto no mapa**: só o clique move o pin. A mudança do CEP, digitado ou vindo da busca reversa do
  clique, preenche **só os campos de texto**.

Em qualquer modo, restaurar um CEP já salvo (voltar e avançar uma etapa, ou abrir a edição) **nunca** move o
pin. A flag de uso único `clicou`/`clicked` deixa de existir.

**Por quê:** os sintomas vêm de dois donos disputando a posição do pin. Com o modo, a regra fica visível para
quem cadastra e simples de testar. Ter um componente só impede que as 3 telas voltem a divergir. Escolhida
por cleytonbiffe, que pediu a correção nas 3 telas.

**Alternativas descartadas:**
- **Modo explícito só no cadastro público e correção mínima no painel**: não escolhida por cleytonbiffe. Ficariam
  duas lógicas diferentes para a mesma coisa.
- **Corrigir só o cadastro público**: não escolhida por cleytonbiffe. A edição no painel continuaria podendo
  trocar localizações salvas.
- **O ponto marcado sempre vence, sem controle visível**: não escolhida por cleytonbiffe, que preferiu deixar a
  pessoa escolher.
- **O CEP digitado à mão move o pin, o CEP vindo do clique não**: não escolhida por cleytonbiffe. A regra
  continuaria implícita.

## D2: O modo inicial depende da tela, e clicar no mapa passa o modo para "Ponto no mapa"

O cadastro público e o modal de criar cursinho começam em **"Seguir o CEP"**. O modal de editar começa em
**"Ponto no mapa"**, porque o cursinho já tem coordenada salva. Em "Seguir o CEP", clicar no mapa põe o pin
no ponto e **passa o modo sozinho para "Ponto no mapa"**. Voltar para "Seguir o CEP" é sempre uma ação da
pessoa. No cadastro público, o modo escolhido sobrevive a voltar e avançar entre as etapas (fica no `dataGeo`
do `GeoForm`, sem ir para a api).

**Por quê:** na edição, a coordenada salva é a referência e não deve ser substituída por padrão. No clique,
se o modo continuasse em "Seguir o CEP", o próximo CEP desfaria o ponto marcado, que é o bug relatado.
Escolhida por cleytonbiffe.

**Alternativas descartadas:**
- **Sempre começar em "Seguir o CEP"**: não escolhida por cleytonbiffe. Na edição, qualquer CEP restaurado
  ou digitado moveria o pin salvo.
- **Deixar para quem implementar**: não escolhida por cleytonbiffe.

## D3: O controle de modo são duas opções de rádio, "Seguir o CEP" e "Ponto no mapa"

O controle fica junto do mapa, com exatamente esses dois rótulos.

**Por quê:** dois estados exclusivos com rótulo visível são mais claros que um alternador ou um checkbox.
Escolhida por cleytonbiffe.

**Alternativas descartadas:**
- **Deixar o formato para quem implementar**: não escolhida por cleytonbiffe.
