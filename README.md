# vcnafacul/workspace

A pasta-mãe dos repos do [Você na Facul](https://github.com/vcnafacul): o planejamento e o registro do
que é desenvolvido, a documentação de desenvolvimento e as instruções para agentes de IA.

## Começar

```bash
git clone https://github.com/vcnafacul/workspace vcnafacul
cd vcnafacul
./ws clonar                 # clona api, client, ms-simulado, ms-omr, form e stack; cria os .env locais
claude plugin install superpowers@claude-plugins-official --scope project   # uma vez, se usar Claude Code
cd vcnafacul-stack && make up                                               # sobe tudo localmente
```

Precisa de `git`; recomendados `gh` (logado) e Docker. Valores de homologação não ficam em repo nenhum:
peça ao time.

## O que tem aqui

| Caminho | Para quê |
|---|---|
| `tickets/` | Um ticket por funcionalidade ou mudança: objetivo, decisões, cards e PRs |
| `docs/contrato-de-desenvolvimento.md` | Como planejamos, registramos e entregamos |
| `docs/arquitetura.md` | Como os serviços conversam |
| `CONTEXT.md` | Glossário do produto |
| `AGENTS.md` / `CLAUDE.md` | Instruções para agentes |
| `./ws` | Clonar, atualizar e ver o estado dos repos |

## Pedidos e bugs

Abra uma [issue aqui](https://github.com/vcnafacul/workspace/issues/new/choose), seja qual for o repo.

## Regras

Repo **público**: nada de dados pessoais, dados reais de estudantes, endereços de produção ou credenciais.
Idioma: pt-BR.
