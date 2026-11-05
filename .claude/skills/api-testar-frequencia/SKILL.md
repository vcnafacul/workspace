---
name: api-testar-frequencia
description: Sobe um ambiente local para testar a frequência (Justificativa de Período e Exportação Excel), com a infra da stack, migrations, dados fictícios, api e client. Use quando pedirem para testar a frequência localmente.
---

# Testar a frequência

Rode a partir da raiz do workspace. **Pare e avise no primeiro passo que falhar.**

## 1. Confira antes de subir

```bash
grep -E '^MY_(HOST|PORT|DB_NAME)=' api-vcnafacul/.env
```

**`MY_HOST` precisa ser `localhost` ou `127.0.0.1`.** Se apontar para outro lugar, **pare**: as migrations e
os dados de teste iriam para esse banco. Não edite o `.env` sem combinar com a pessoa.

Avise que:
- `make infra` derruba o modo homol da stack, se estiver no ar;
- os dados entram nos volumes locais da stack (`vcnafacul-local`), junto do que já houver lá.

## 2. Suba a infra

```bash
(cd vcnafacul-stack && make infra)
```

Sobe MySQL, Mongo, MinIO, Redis e Mailpit. Espere o MySQL responder:

```bash
for i in $(seq 1 30); do
  (cd vcnafacul-stack && docker compose -p vcnafacul-local --env-file .env.compose -f docker-compose.yml \
    -f docker-compose.dados-locais.yml exec -T mysql sh -c 'mysqladmin ping -uroot -p"$MYSQL_ROOT_PASSWORD" --silent') \
    && break
  sleep 2
done
```

## 3. Rode as migrations

```bash
(cd api-vcnafacul && yarn install --frozen-lockfile && yarn migration:run)
```

## 4. Insira os dados de teste

A senha é gerada na hora e não fica em nenhum arquivo. Pode rodar de novo: nada é duplicado e a senha é
atualizada.

```bash
SENHA="$(openssl rand -hex 12)"
HASH="$(cd api-vcnafacul && node -e 'console.log(require("bcrypt").hashSync(process.argv[1], 10))' "$SENHA")"
sed "s|__SENHA_HASH__|$HASH|g" .claude/skills/api-testar-frequencia/seed.sql \
  | (cd vcnafacul-stack && docker compose -p vcnafacul-local --env-file .env.compose -f docker-compose.yml \
      -f docker-compose.dados-locais.yml exec -T mysql sh -c 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD" vcnafacul')
echo "Senha: $SENHA"
```

Se a inserção falhar por coluna ou tabela que mudou, corrija o `seed.sql` e rode de novo.

## 5. Inicie a api e o client

Rode cada um em segundo plano:

```bash
(cd api-vcnafacul && yarn dev)
(cd client-vcnafacul && yarn install --frozen-lockfile && yarn dev)
```

## 6. Mostre o resumo

- **Client:** http://localhost:5173
- **API:** http://localhost:3333 (Swagger em `/api`)
- **Login:** `admin@example.com`, com a senha do passo 4

**Dados:** Cursinho Teste, Turma A (1º Semestre 2026) e o estudante `MAT-001`.

**Para testar:** entre como admin, abra a Turma A, abra o estudante e teste Justificar Período e o relatório
Excel.

**Ao terminar:** pare a api e o client. `(cd vcnafacul-stack && make down)` derruba a infra e mantém os dados.
Apagar os dados (`make down-v`) também apaga o resto dos volumes locais: só com a confirmação da pessoa.
