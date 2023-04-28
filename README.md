# NodeApi Generator
Gerador de Api NodeJS


## Libs, frameworks, types, validators, compilers e formaters utilizados

1. fastify
2. typescript
3. tsc
4. tsx
5. tsup
6. prisma
7. @prisma/client
8. @types/node -D
9. dotenv
10. @fastify/cors
11. zod
12. dayjs


## Instalação

1. Clone o repo;
2. Execute o script "install-api.sh";
3. Quando solicitado, ** * **informe os dados necessários;
4. Crie suas rotas no arquivo **_src/routes.ts_** seguindo os exemplos e usufrua da sua API!


** * ** No momento da instalação do prisma, será necessário informar a connectionString para o seu banco de dados. Quando solicitado, faça conforme abaixo:
| DATABASE | ConnectionString FORMAT |
| --- | --- |
|postgresql| postgresql://USER:PASSWORD@HOST:PORT/DATABASE|
|mysql| mysql://USER:PASSWORD@HOST:PORT/DATABASE|
|mongodb| mongodb://USERNAME:PASSWORD@HOST/DATABASE|
|sqlserver| sqlserver://HOST:PORT;database=DATABASE;user=USER;password=PASSWORD;encrypt=true|
|sqlite| Não precisa de connectionString por se tratar de local file database (será criado um arquivo)|
|cockroachdb| Utiliza o formato do POSTGRESQL(Acessse https://www.prisma.io/docs/concepts/database-connectors/cockroachdb para mais informações)|
 