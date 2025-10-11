# VULNERABILIDADE: Dockerfile para aplicacao Node.js com multiplas falhas

# VULNERABILIDADE: Imagem base desatualizada sem tag especifica
FROM node:14

# VULNERABILIDADE: Executando como root durante todo o build
# VULNERABILIDADE: Sem USER definido

# VULNERABILIDADE: Definindo diretorio de trabalho como root
WORKDIR /app

# VULNERABILIDADE: Secrets hardcoded como variaveis de ambiente
ENV NODE_ENV=production \
    DATABASE_URL="postgresql://admin:SuperSecret123@db.example.com:5432/mydb" \
    API_KEY="sk-proj-1234567890abcdefghijklmnopqrstuvwxyz" \
    JWT_SECRET="my-super-secret-jwt-key-12345" \
    AWS_ACCESS_KEY_ID="AKIAIOSFODNN7EXAMPLE" \
    AWS_SECRET_ACCESS_KEY="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY" \
    STRIPE_SECRET_KEY="sk_live_51234567890abcdefghijklmnopqrstuvwxyz" \
    SESSION_SECRET="my-session-secret-key"

# VULNERABILIDADE: Instalacao sem limpeza de cache
RUN apt-get update && \
    apt-get install -y \
    curl \
    wget \
    vim \
    git \
    build-essential

# VULNERABILIDADE: Copiando package.json sem usar cache de layers
COPY package.json .
COPY package-lock.json .

# VULNERABILIDADE: npm install sem --production e sem limpeza de cache
RUN npm install

# VULNERABILIDADE: Instalando dependencias globais desnecessarias
RUN npm install -g nodemon pm2

# VULNERABILIDADE: Copiando codigo fonte incluindo arquivos sensiveis
COPY . .

# VULNERABILIDADE: Arquivos sensiveis podem ser copiados
# .env
# .git
# node_modules duplicado
# credentials.json

# VULNERABILIDADE: Expondo porta de debug
EXPOSE 3000
EXPOSE 9229

# VULNERABILIDADE: Sem HEALTHCHECK definido

# VULNERABILIDADE: Comando usando npm start em vez de node direto
CMD ["npm", "start"]

# VULNERABILIDADE: Sem multi-stage build
# VULNERABILIDADE: Imagem final muito grande com dev dependencies
# VULNERABILIDADE: Build tools presentes em producao
# VULNERABILIDADE: Sem scanning de vulnerabilidades
# VULNERABILIDADE: Sem USER non-root
# VULNERABILIDADE: WORKDIR com permissoes de root
