FROM eclipse-temurin:17-jdk

ARG MIGRATOR_VERSION=3.78.2-04
ARG H2_VERSION=2.2.224

ENV MIGRATOR_VERSION=${MIGRATOR_VERSION}
ENV H2_VERSION=${H2_VERSION}

# Default database connection settings — override with -e if you must
ENV NEXUS_DB_UID=nexus
ENV NEXUS_DB_PWD=supersecret
ENV NEXUS_DB_HOST=localhost
ENV NEXUS_DB_PORT=5432
ENV NEXUS_DB_NAME=nexus
ENV NEXUS_DB_SCHEMA=public

# Java memory settings
ENV JAVA_XMX=-Xmx4G
ENV JAVA_XMS=-Xms2G

WORKDIR /opt/migrator

ADD https://sonatype-download.global.ssl.fastly.net/repository/downloads-prod-group/nxrm3-migrator/nexus-db-migrator-${MIGRATOR_VERSION}.jar nexus-db-migrator-${MIGRATOR_VERSION}.jar
ADD https://repo1.maven.org/maven2/com/h2database/h2/${H2_VERSION}/h2-${H2_VERSION}.jar h2.jar

RUN echo '#!/bin/sh' > /opt/migrator/start.sh && \
    echo '[ -z "$NEXUS_DB_HOST" ] && echo "ERROR: NEXUS_DB_HOST is not set. Usage: -e NEXUS_DB_HOST=your.db.host" && exit 1' >> /opt/migrator/start.sh && \
    echo 'cd /h2-data' >> /opt/migrator/start.sh && \
    echo 'java ${JAVA_XMX} ${JAVA_XMS} -jar /opt/migrator/nexus-db-migrator-${MIGRATOR_VERSION}.jar \\' >> /opt/migrator/start.sh && \
    echo '  --migration_type=h2_to_postgres \\' >> /opt/migrator/start.sh && \
    echo '  --db_url="jdbc:postgresql://${NEXUS_DB_HOST}:${NEXUS_DB_PORT}/${NEXUS_DB_NAME}?user=${NEXUS_DB_UID}&password=${NEXUS_DB_PWD}&currentSchema=${NEXUS_DB_SCHEMA}"' >> /opt/migrator/start.sh && \
    chmod +x /opt/migrator/start.sh

VOLUME /h2-data

CMD ["/opt/migrator/start.sh"]
