# VULNERABILIDADE: Dockerfile Java Spring Boot inseguro

# VULNERABILIDADE: JDK completo em producao sem tag especifica
FROM openjdk:11

# VULNERABILIDADE: Rodando como root
# USER definido seria necessario

WORKDIR /app

# VULNERABILIDADE: Secrets em variaveis de ambiente
ENV SPRING_DATASOURCE_URL="jdbc:postgresql://db:5432/mydb" \
    SPRING_DATASOURCE_USERNAME="admin" \
    SPRING_DATASOURCE_PASSWORD="Admin123456" \
    JWT_SECRET="my-jwt-secret-key-for-tokens" \
    AWS_ACCESS_KEY_ID="AKIAIOSFODNN7EXAMPLE" \
    AWS_SECRET_ACCESS_KEY="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY" \
    REDIS_PASSWORD="RedisPassword123"

# VULNERABILIDADE: Instalando ferramentas desnecessarias
RUN apt-get update && \
    apt-get install -y \
    curl \
    wget \
    vim \
    git \
    maven \
    gradle

# VULNERABILIDADE: Copiando arquivo de configuracao com secrets
COPY application.properties /app/config/
COPY application-prod.yml /app/config/

# VULNERABILIDADE: Copiando JAR sem build multi-stage
COPY target/myapp.jar app.jar

# VULNERABILIDADE: Copiando arquivos de configuracao sensiveis
COPY src/main/resources/application-secrets.properties /app/
COPY keystore.jks /app/
COPY truststore.jks /app/

# VULNERABILIDADE: Definindo senha do keystore em variavel
ENV KEYSTORE_PASSWORD="keystorepass123"
ENV TRUSTSTORE_PASSWORD="truststorepass123"

# VULNERABILIDADE: Criando arquivo com credenciais de banco
RUN echo "spring.datasource.password=Admin123456" >> /app/config/application.properties

# VULNERABILIDADE: Permissoes muito abertas
RUN chmod 777 /app
RUN chmod 644 keystore.jks

# VULNERABILIDADE: Expondo porta de debug remoto
EXPOSE 8080
EXPOSE 5005

# VULNERABILIDADE: Expondo actuator endpoints
ENV MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE="*"

# VULNERABILIDADE: Debug remoto habilitado
ENV JAVA_TOOL_OPTIONS="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005"

# VULNERABILIDADE: Sem HEALTHCHECK

# VULNERABILIDADE: Executando com debug habilitado
CMD ["java", "-Dspring.profiles.active=prod", "-Ddebug=true", "-jar", "app.jar"]

# VULNERABILIDADES ADICIONAIS:
# - JDK completo em vez de JRE
# - Sem otimizacao de layers
# - Maven/Gradle em imagem de producao
# - Keystore e truststore na imagem
# - Debug remoto exposto
# - Actuator endpoints todos expostos
