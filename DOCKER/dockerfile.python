# VULNERABILIDADE: Dockerfile Python com vulnerabilidades

# VULNERABILIDADE: Imagem base sem tag especifica
FROM python:latest

# VULNERABILIDADE: Metadata faltando
# LABEL maintainer="email@example.com"

# VULNERABILIDADE: Executando como root
USER root

WORKDIR /app

# VULNERABILIDADE: Secrets hardcoded
ENV FLASK_ENV=production \
    SECRET_KEY="flask-secret-key-12345" \
    DATABASE_URI="mysql://root:password@db:3306/mydb" \
    API_TOKEN="Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9" \
    SENDGRID_API_KEY="SG.1234567890abcdefghijklmnopqrstuvwxyz" \
    AWS_ACCESS_KEY="AKIAIOSFODNN7EXAMPLE" \
    AWS_SECRET_KEY="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"

# VULNERABILIDADE: Instalando pacotes sem versoes especificas
RUN apt-get update && \
    apt-get install -y \
    gcc \
    g++ \
    make \
    wget \
    curl \
    vim \
    telnet \
    netcat

# VULNERABILIDADE: Baixando script da internet sem verificacao
RUN curl -sSL https://raw.githubusercontent.com/unknown/repo/main/setup.sh | bash

# VULNERABILIDADE: Pip install sem hash verification
COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# VULNERABILIDADE: Instalando versoes vulneraveis conhecidas
RUN pip install flask==0.12.2 \
    django==2.2.0 \
    pyyaml==3.12 \
    jinja2==2.10 \
    requests==2.19.0

# VULNERABILIDADE: Copiando arquivos sensiveis
COPY . .
COPY .env .
COPY config/secrets.yaml .
COPY .aws/credentials /root/.aws/

# VULNERABILIDADE: Permissoes muito abertas
RUN chmod 777 /app
RUN chmod 777 /tmp

# VULNERABILIDADE: Criando arquivo com credenciais
RUN echo "admin:password123" > /app/admin_credentials.txt

# VULNERABILIDADE: Expondo porta de debug do Python
EXPOSE 5000
EXPOSE 5678

# VULNERABILIDADE: Debug mode habilitado em producao
ENV FLASK_DEBUG=1
ENV PYTHONDONTWRITEBYTECODE=0

# VULNERABILIDADE: Comando executando com flask run em debug
CMD ["flask", "run", "--host=0.0.0.0", "--port=5000", "--debugger"]

# VULNERABILIDADES ADICIONAIS:
# - Sem multi-stage build
# - Build dependencies em producao
# - Sem health check
# - Imagem muito grande
# - Sem scan de vulnerabilidades
