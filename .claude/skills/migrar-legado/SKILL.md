---
name: migrar-legado
description: Migra um esforço de planejamento legado para tickets/ do workspace, em um PR para revisão humana. Use quando alguém pedir para migrar tickets, cards ou mapas antigos.
---

# Migrar legado

Siga `docs/migracao-de-legado.md` para **um único esforço de origem**, usando o prompt no fim daquele arquivo.
Se não souber qual é a origem, pergunte.

Abra um PR no workspace com a seção `## Achados de conteúdo`: cada achado da varredura, com o arquivo e uma
proposta (remover, generalizar ou mover para o repo `privado`). Sem achados, diga isso na seção.

**Nunca faça o merge.** Uma pessoa revisa e faz o merge. Não altere código em nenhum repo.
