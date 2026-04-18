FROM eclipse-temurin:17-jdk-alpine AS builder
WORKDIR /src
COPY pom.xml .
COPY src ./src

RUN apk add --no-cache maven && \
    mvn clean package -DskipTests && \
    ls -la target/

FROM eclipse-temurin:17-jre-alpine
ENV CATALINA_HOME=/opt/tomcat \
    JAVA_OPTS="-Xmx1g -Xms512m -XX:+UseG1GC" \
    CATALINA_OPTS="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=8000"

RUN apk add --no-cache \
    curl \
    tomcat \
    && mkdir -p /opt/tomcat

WORKDIR /opt/tomcat

# Copy built WAR from builder
COPY --from=builder /src/target/*.war /opt/tomcat/webapps/app.war

EXPOSE 8080 8000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8080/ || exit 1

CMD ["catalina.sh", "run"]
