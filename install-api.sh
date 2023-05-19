#!/bin/bash

showMESSAGE() {
    MESSAGE=$1
    USE_CLEAR=$2
    SLEEP_VALUE=$3
    if [ $USE_CLEAR ]; then
        clear
    fi
    printf "$MESSAGE" |& tee -a Logs.txt
    printf "\n" |& tee -a Logs.txt
    if [ $SLEEP_VALUE ]; then
        sleep $SLEEP_VALUE
    fi
}

showMESSAGE "Obrigado por utilizar o meu API generator!" true 3

showMESSAGE "Criando NodeJS API." true 1
showMESSAGE "Criando NodeJS API.." true 1
showMESSAGE "Criando NodeJS API..." true 2

showMESSAGE "Criando package.json..." true 2
npm init -y |& tee -a Logs.txt  

showMESSAGE "Criando diretório principal (src)..." true 2
mkdir src |& tee -a Logs.txt

showMESSAGE "Instalando fastify para gerenciar as rotas da aplicação..." true 2
npm i fastify |& tee -a Logs.txt

showMESSAGE "Instalando o typescript..." true 2
npm i typescript -D |& tee -a Logs.txt

showMESSAGE "Iniciando a configuração do typescript..." true 2 
npx tsc --init |& tee -a Logs.txt

sleep 5
showMESSAGE "Alterando versão do Ecma Script para es2020 no arquivo tsconfig.json(De: \"target\": \"es2016\" para \"target\": \"es2020\")..." true 2
sed -i 's/"target": "es2016"/"target": "es2020"/g' tsconfig.json |& tee -a Logs.txt

showMESSAGE "Instalando tsx para executar arquivos node com typescript sem precisar converter (Ex: npx tsx src/server.ts)..." true 2
npm i tsx -D |& tee -a Logs.txt

showMESSAGE "Instalando tsup para compilar arquivos typescript sem necessidade de configuração ..." true 2
npm i tsup -D |& tee -a Logs.txt

sleep 5

showMESSAGE "Incluindo no package.json um script para executar com o tsx e com hot reload: (\"dev\": \"tsx watch src/server.ts\" (para executar, digite no console: npm run dev))..." true 2
sed -i 's/"test": "echo \\"Error: no test specified\\" && exit 1"/"dev": "tsx watch src\/server.ts"/g' package.json |& tee -a Logs.txt

showMESSAGE "Instalando prisma ORM para gerenciar persistência com banco de dados..." true 2
npm i -D prisma |& tee -a Logs.txt

showMESSAGE "Instalando @prisma/client para acessar o ORM como client..." true 2
npm i @prisma/client |& tee -a Logs.txt

showMESSAGE "Instalando @types/node ..." true 2
npm install @types/node -D |& tee -a Logs.txt

#######

MENU='Selecione o datasource-provider a ser utilizado na API: \n1 - postgresql \n2 - mysql \n3 - sqlite \n4 - mongodb \n5 - cockroachdb \n6 - sqlserver \n**Para executar localmente sem um datasource instalado, escolha a opção 3\n\n'

OPT_SELECTED="NOT_SELECTED"
DATABASE_URL="Para configurar corretamente a sua conexão com banco de dados CockroachDB, acesse: https://www.prisma.io/docs/concepts/database-connectors/cockroachdb"
DATABASE_URL_PATTERN=""

while [ "$OPT_SELECTED" == "NOT_SELECTED" ];
do
    clear
    printf "$MENU" #'Selecione o datasource-provider a ser utilizado na API: \n1 - postgresql \n2 - mysql \n3 - sqlite \n4 - mongodb \n5 - cockroachdb \n6 - sqlserver \n'
    read opt
    case $opt in
        1* )     OPT_SELECTED="postgresql";DATABASE_URL="postgresql://USER:PASSWORD@HOST:PORT/DATABASE";DATABASE_URL_PATTERN="^postgresql://(.*)+:(.*)+@(.*)+:[0-9]+/(.*)*$";;
        
        2* )     OPT_SELECTED="mysql";DATABASE_URL="mysql://USER:PASSWORD@HOST:PORT/DATABASE";DATABASE_URL_PATTERN="^mysql://(.*)+:(.*)+@(.*)+:[0-9]+/(.*)*$";;
        
        3* )     OPT_SELECTED="sqlite";;
        
        4* )     OPT_SELECTED="mongodb";DATABASE_URL="mongodb://USERNAME:PASSWORD@HOST/DATABASE";DATABASE_URL_PATTERN="^mongodb://(.*)+:(.*)+@(.*)+/(.*)*$";;
        
        5* )     OPT_SELECTED="cockroachdb";;
        
        6* )     OPT_SELECTED="sqlserver";DATABASE_URL="sqlserver://HOST:PORT;database=DATABASE;user=USER;password=PASSWORD;encrypt=true";DATABASE_URL_PATTERN="^sqlserver://(.*)+:[0-9]+;database=(.*)+;user=(.*)+;password=(.*)+;(.*)*$";;
    esac
done

if [ $OPT_SELECTED != "sqlite" ]; then
    if [ $OPT_SELECTED == "cockroachdb" ]; then
        showMESSAGE "$DATABASE_URL" true 6
    else
        DTBASE_URL="NOT_SELECTED"
        while [ "$DTBASE_URL" == "NOT_SELECTED" ];
        do
            clear
            printf "Informe a URL do seu database no formato: $DATABASE_URL \n"
            read db_url 
            if [[ "$db_url" =~ $DATABASE_URL_PATTERN ]]; then
                sed -i 's/DATABASE_URL/#DATABASE_URL/g' ./.env |& tee -a Logs.txt
                echo "DATABASE_URL=\"$db_url\"" >> .env |& tee -a Logs.txt
                DTBASE_URL=$db_url
            else
                showMESSAGE "É necessário informar a URL do seu database no formato: $DATABASE_URL \n" true 3
            fi
            echo $DTBASE_URL
        done
    fi
fi


showMESSAGE "Iniciando prisma e configurando para o banco ${OPT_SELECTED^^}" true 2
npx prisma init --datasource-provider $OPT_SELECTED |& tee -a Logs.txt


showMESSAGE "Instalando o DOTENV para permitir acessar as variáveis informadas no arquivo .env ..." true 2
npm install dotenv |& tee -a Logs.txt

showMESSAGE "Instalando gerenciamento de CORS..." true 2
npm i @fastify/cors |& tee -a Logs.txt

showMESSAGE "Instalando ZOD para validar os dados de requests utilizando objects..." true 2
npm i zod |& tee -a Logs.txt

showMESSAGE "Instalando dayjs..." true 2
npm i dayjs |& tee -a Logs.txt

showMESSAGE "Criando arquivo de instanciação do prisma e exportando..." true 2

mkdir src/lib |& tee -a Logs.txt
cat <<EOF >src/lib/prisma.ts
import { PrismaClient } from '@prisma/client';

export const prisma = new PrismaClient();
EOF

showMESSAGE "Criando arquivo server.ts para inicialização do servidor..." true 2

cat <<EOF >src/server.ts
import Fastify from "fastify";
import dotenv from 'dotenv';
import cors from '@fastify/cors';
import { appRoutes } from './routes'


dotenv.config();

const app = Fastify();

app.register(cors);
app.register(appRoutes);


//Porta liberada para o servidor
const port = process.env.SERVER_PORT ? Number(process.env.SERVER_PORT) : 3333;

//Host que será associado ao servidor
const host = process.env.SERVER_HOST || '0.0.0.0';

app.listen({
    host: host,
    port: port,
}).then(() => {
    console.log(\`🚀🚀🚀 HTTP Server host: \${host} running on port \${port}!\`);
});
EOF

showMESSAGE "Criando arquivo de rotas(endpoints) e exportando..." true 2

cat <<EOF >src/routes.ts
import { FastifyInstance } from "fastify";
import { prisma } from "./lib/prisma";
import dotenv from 'dotenv';
import { z } from 'zod';

dotenv.config();

export async function appRoutes(app: FastifyInstance) {

    app.get('/health-check', async () => {
        const databaseDate = await prisma.test.count();
        return 'SERVER RUNNING!'
    });

    app.get('/getTestParams', async (request) => {
        const getTestParams = z.object({
            nome: z.string()
        });
        
        const { nome } = getTestParams.parse(request.query);//Valida os dados enviados na request
        
        const teste = await prisma.test.findFirst({//retorna a primeira linha encontrada da tabela test, de acordo ocm os parâmetros da cláusula where
            where: {//cláusula where da consulta
                name: {
                    equals: nome,
                    mode: 'insensitive'
                },
                active: true
            },
            select: {//Colunas retornadas pelo select
                id: true,
            },
        });

        const idTest = teste ? teste.id : undefined;
        
        return idTest;
    });
}
EOF
showMESSAGE "Adicionando variáveis SERVER_PORT e SERVER_HOST ao arquivo .env ..." false 2
echo $'\nSERVER_PORT=\"3333\"' >> .env |& tee -a Logs.txt

echo $'\nSERVER_HOST=\"0.0.0.0\"' >> .env |& tee -a Logs.txt


showMESSAGE "Adicionando exemplo de model(test) ao schema.prisma ..." true 2
echo $'\nmodel Test {
  id            Int      @id @default(autoincrement())
  name String   @unique
  active        Boolean
  @@map("tests")
}\n'  >> prisma/schema.prisma |& tee -a Logs.txt

showMESSAGE "Iniciando o banco de dados com prisma ..." true 2
npx prisma generate |& tee -a Logs.txt

showMESSAGE "Gerando migrations para o banco de dados com prisma ..." false 2
npx prisma migrate dev --name init |& tee -a Logs.txt

echo $'\n' >> tsconfig.json |& tee -a Logs.txt

showMESSAGE "API CRIADA COM SUCESSO!" false 1

showMESSAGE "Developed by Mecyo!" false 2

if [ $OPT_SELECTED != "cockroachdb" ]; then
   printf "Deseja iniciar o servidor?  Y/N \n\n"
   read start_server

   if [ $start_server="Y" ]; then
       npm run dev |& tee -a Logs.txt
   fi
fi
