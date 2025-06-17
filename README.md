# Nexus Repository H2-to-PostgreSQL Migration Container

> A Docker/Podman container for migrating a Nexus Repository's embedded H2 database to a PostgreSQL backend. Designed for masochists who enjoy command-line spells and tinkering with Java flags.

## Features

- Minimalist base image (Eclipse Temurin JDK 17)
- Includes `h2.jar` for H2 database inspection
- All parameters configurable via environment variables
- Runs the official `nexus-db-migrator` from Sonatype

## Build the Image

```bash
podman build --build-arg MIGRATOR_VERSION=3.78.2-04 -t nexus-h2-psql-migrator:3.78.2-04 .
```

## Run the Migration

```bash
podman run -it --rm \
  -e NEXUS_DB_UID=nexus \
  -e NEXUS_DB_PWD=supersecret \
  -e NEXUS_DB_HOST=10.110.1.101 \
  -e NEXUS_DB_PORT=5432 \
  -e NEXUS_DB_NAME=nexus \
  -e NEXUS_DB_SCHEMA=public \
  -e JAVA_XMX=-Xmx4G \
  -e JAVA_XMS=-Xms2G \
  -v /opt/nexus/nexus-data/db:/h2-data \
  nexus-h2-psql-migrator:3.78.2-04
```

## Debug Mode

```bash
podman run -it --rm \
  --entrypoint /bin/bash \
  -v /opt/nexus/nexus-data/db:/h2-data \
  nexus-h2-psql-migrator:3.78.2-04

# Inside the container
cd /h2-data
/opt/migrator/java -Xmx8G -Xms8G -jar nexus-db-migrator-3.78.2-04.jar \
  --migration_type=h2_to_postgres \
  --db_url="jdbc:postgresql://10.110.1.101:5432/nexus?user=nexus&password=supersecret&currentSchema=public" \
  --debug 2>&1 | tee /h2-data/migration.log
```

## Bonus: Inspect the H2 Database

```bash
java -cp h2.jar org.h2.tools.Shell -url jdbc:h2:/h2-data/nexus -user ""
```

If you're wondering what the flags do:

- `-cp h2.jar` – tells Java to include the H2 toolset
- `org.h2.tools.Shell` – launches the SQL CLI
- `-url jdbc:h2:/h2-data/nexus` – connects to your file-based DB
- `-user ""` – uses empty username, which is standard for H2 unless configured otherwise

## Other sources of information on this matter

- <https://help.sonatype.com/en/migrating-to-a-new-database.html#migrating-from-h2-to-postgresql>
- <https://support.sonatype.com/hc/en-us/articles/39119364119571-Troubleshooting-common-errors-for-Database-Migration-from-H2-to-PostgreSQL>

---

Use wisely. Make backups.
