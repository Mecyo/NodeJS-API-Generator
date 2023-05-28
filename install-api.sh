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

showMESSAGE "Instalando gerenciamento de Multipart(upload de arquivos)..." true 2
npm i @fastify/multipart |& tee -a Logs.txt

showMESSAGE "Instalando biblioteca de gerenciamento de arquivos estáticos..." true 2
npm i @fastify/static |& tee -a Logs.txt

showMESSAGE "Instalando biblioteca de gerenciamento de autenticação das requisições HTTP (JWT)..." true 2
npm i @fastify/jwt |& tee -a Logs.txt

showMESSAGE "Criando arquivo de padronização das informações contidas no token JWT..." true 2

cat <<EOF >src/auth.d.ts
import '@fastify/jwt';

declare module '@fastify/jwt' {
    export interface FastifyJWT {
        user: {
            id: string
            name: string
            avatarUrl: string
        }
    }
}
EOF

showMESSAGE "Instalando axios para abstração de requisições HTTP..." true 2
npm i axios |& tee -a Logs.txt

showMESSAGE "Instalando ZOD para validar os dados de requests utilizando objects..." true 2
npm i zod |& tee -a Logs.txt

showMESSAGE "Instalando dayjs..." true 2
npm i dayjs |& tee -a Logs.txt

prismaActivateLogQuery=''
prepareLogQueryOption() {
  prismaActivateLogQuery="{
  log: ['query'],
}"
    echo Log query habilitado!
}
read -p "Deseja habilitar o log de queries? ([S]im/[N]ão) " yn

case $yn in 
	Sim ) prepareLogQueryOption;;
  sim ) prepareLogQueryOption;;
  [sS] ) prepareLogQueryOption;;
  Yes ) pprepareLogQueryOption;;
  yes ) pprepareLogQueryOption;;
  [yY] ) prepareLogQueryOption;;
	* ) echo Log query desabilitado!;
esac

showMESSAGE "Criando arquivo de instanciação do prisma e exportando..." true 2

mkdir src/lib |& tee -a Logs.txt
cat <<EOF >src/lib/prisma.ts
import { PrismaClient } from '@prisma/client';

export const prisma = new PrismaClient($prismaActivateLogQuery);
EOF

showMESSAGE "Criando arquivo server.ts para inicialização do servidor..." true 2

cat <<EOF >src/server.ts
import Fastify from "fastify";
import dotenv from 'dotenv';
import jwt from '@fastify/jwt';
import cors from '@fastify/cors';
import { appRoutes } from './routes/routes';
import { authRoutes } from './routes/auth';


dotenv.config();

const app = Fastify();

app.register(cors);
app.register(appRoutes);
app.register(authRoutes);
app.register(jwt, {
	secret: process.env.JWT_SECRET || 'myJWTSecret'
});

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

mkdir src/routes |& tee -a Logs.txt
cat <<EOF >src/routes/routes.ts
import { FastifyInstance } from "fastify";
import { prisma } from "../lib/prisma";
import dotenv from 'dotenv';
import { z } from 'zod';

dotenv.config();

export async function appRoutes(app: FastifyInstance) {

    app.addHook('preHandler', async (request) => {
        await request.jwtVerify()
    });
    
    app.get('/health-check', async () => {
        const databaseDate = await prisma.test.count();
        return 'SERVER RUNNING!'
    });

    app.get('/getTestParams', async (request, reply) => {
        const getTestParams = z.object({
            nome: z.string()
        });
        
        const { nome } = getTestParams.parse(request.query);//Valida os dados enviados na request
        
        const teste = await prisma.test.findFirstOrThrow({//retorna a primeira linha encontrada da tabela test, de acordo ocm os parâmetros da cláusula where
            where: {//cláusula where da consulta
                name: {
                    equals: nome,
                    mode: 'insensitive'
                },
                active: true
            },
            select: {//Colunas retornadas pelo select
                id: true,
                userId: true,
            },
        });

        if (teste.userId !== request.user.id) {
            return reply.status(401).send()
        }
        const idTest = teste ? teste.id : undefined;
        
        return idTest;
    });
}
EOF

showMESSAGE "Adicionando variáveis SERVER_PORT e SERVER_HOST ao arquivo .env ..." false 2
echo $'SERVER_PORT=\"3333\"' >> .env |& tee -a Logs.txt

echo $'SERVER_HOST=\"0.0.0.0\"' >> .env |& tee -a Logs.txt

jwtSecret="myJWTSecret"
read -p "Informe a JWT-Secret que será utilizada na assinatura do token(default='myJWTSecret') " jwtS

if [ ! -z "$jwtS" ]; then
    jwtSecret=$jwtS
fi

showMESSAGE "Adicionando variável JWT_SECRET ao arquivo .env com o valor: '$jwtSecret'" false 2
echo "JWT_SECRET=\"$jwtSecret\"" >> .env |& tee -a Logs.txt

prepareLogQueryOption() {
    echo "Para isso, será necessário informar 'GITHUB_CLIENT_ID' e 'GITHUB_CLIENT_SECRET' do seu app do GitHub:"
    echo "Caso ainda não tenha um, você pode criar em: 'https://github.com/settings/applications/new'"

    read -p "Informe o 'GITHUB_CLIENT_ID': " gitClientId
    showMESSAGE "Adicionando variável 'GITHUB_CLIENT_ID' ao arquivo .env com o valor: '$gitClientId'" false 2
    echo "GITHUB_CLIENT_ID=\"$gitClientId\"" >> .env |& tee -a Logs.txt

    read -p "Agora informe o 'GITHUB_CLIENT_SECRET': " gitClientSecret
    showMESSAGE "Adicionando variável 'GITHUB_CLIENT_SECRET' ao arquivo .env com o valor: '$gitClientSecret'" false 2
    echo "GITHUB_CLIENT_SECRET=\"$gitClientSecret\"" >> .env |& tee -a Logs.txt

    showMESSAGE "Criando arquivo de rota para autenticação/registro de usuário utilizando o GitHub..." true 2

    cat <<EOF >src/routes/auth.ts
    import { FastifyInstance } from 'fastify'
    import axios from 'axios'
    import { z } from 'zod'
    import { prisma } from '../lib/prisma'

    export async function authRoutes(app: FastifyInstance) {
        app.post('/register', async (request) => {
            const bodySchema = z.object({
            code: z.string(),
            })

            const { code } = bodySchema.parse(request.body)

            const accessTokenResponse = await axios.post(
                'https://github.com/login/oauth/access_token',
                null,
                {
                    params: {
                    client_id: process.env.GITHUB_CLIENT_ID,
                    client_secret: process.env.GITHUB_CLIENT_SECRET,
                    code,
                    },
                    headers: {
                    Accept: 'application/json',
                    },
                },
            )

            const { access_token } = accessTokenResponse.data

            const userResponse = await axios.get('https://api.github.com/user', {
                headers: {
                    Authorization: \`Bearer ${access_token}\`,
                },
            })

            const userSchema = z.object({
                id: z.number(),
                login: z.string(),
                name: z.string(),
                avatar_url: z.string().url(),
            })

            const userInfo = userSchema.parse(userResponse.data)

            let user = await prisma.user.findUnique({
                where: {
                    githubId: userInfo.id,
                },
            })

            if (!user) {
                user = await prisma.user.create({
                    data: {
                        githubId: userInfo.id,
                        login: userInfo.login,
                        name: userInfo.name,
                        avatarUrl: userInfo.avatar_url,
                    },
                })
            }

            const token = app.jwt.sign(
                {
                    name: user.name,
                    avatarUrl: user.avatarUrl,
                },
                {
                    sub: user.id,
                    expiresIn: '30 days',
                },
            )

            return {
                token,
            }
        })
    }
EOF
}

read -p "Deseja habilitar o login utilizando o GitHub? ([S]im/[N]ão) " activateGitHubLogin

case $activateGitHubLogin in 
	Sim ) prepareLogQueryOption;;
  sim ) prepareLogQueryOption;;
  [sS] ) prepareLogQueryOption;;
  Yes ) prepareLogQueryOption;;
  yes ) prepareLogQueryOption;;
  [yY] ) prepareLogQueryOption;;
	* ) echo Login com GitHub desabilitado!;
esac

showMESSAGE "Adicionando exemplo de model(test) ao schema.prisma ..." true 2
echo $'
model User {
  id        String @id @default(uuid())
  githubId  Int    @unique
  name      String
  login     String
  avatarUrl String

  tests Test[]
  @@map("users")
}\nmodel Test {
  id            Int      @id @default(autoincrement())
  name          String   @unique
  userId        String
  active        Boolean
  user          User @relation(fields: [userId], references: [id])
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
