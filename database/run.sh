#!/bin/bash

### Fetch variables
set -a
: ${DATABASE_TCP_PORT:=18082}
: ${DATABASE_PG_PORT:=18083}
: ${DATABASE_WEB_PORT:=18084}
: ${DATABASE_DBUSER:=sa}
: ${DATABASE_DBPASS:=sa}
: ${DATABASE_H2JAR:=./build/libs/database.jar}
: ${DATABASE_DATA_DIR:=./_data}
: ${DATABASE_DBNAME:=traderx}
: ${DATABASE_HOSTNAME:=$HOSTNAME}
: ${DATABASE_JDBC_URL:="jdbc:h2:tcp://$HOSTNAME:$DATABASE_TCP_PORT/$DATABASE_DBNAME"}
: ${DATABASE_WEB_HOSTNAMES:=$HOSTNAME}
: ${DATABASE_INIT:=if-empty}

set +a

### Ensure data directory exists
mkdir -p $DATABASE_DATA_DIR

### Start the DB
echo "Data will be located in $DATABASE_DATA_DIR"
echo "Database name is $DATABASE_DBNAME"
echo "Database init mode is $DATABASE_INIT"

DB_FILE="$DATABASE_DATA_DIR/$DATABASE_DBNAME.mv.db"

if [ "$DATABASE_INIT" = "always" ]; then
    echo "DATABASE_INIT=always: Forcing schema initialization (will reset all data)"
    echo 'Running schema setup script with log output to stdout below'
    echo '---------------------------------------------------------------------------'
    java -cp $DATABASE_H2JAR org.h2.tools.RunScript -url "jdbc:h2:$DATABASE_DATA_DIR/$DATABASE_DBNAME;DATABASE_TO_UPPER=TRUE;TRACE_LEVEL_SYSTEM_OUT=3" -user $DATABASE_DBUSER -password $DATABASE_DBPASS -script initialSchema.sql
elif [ "$DATABASE_INIT" = "if-empty" ] && [ ! -f "$DB_FILE" ]; then
    echo "DATABASE_INIT=if-empty: Database file not found, initializing schema"
    echo 'Running schema setup script with log output to stdout below'
    echo '---------------------------------------------------------------------------'
    java -cp $DATABASE_H2JAR org.h2.tools.RunScript -url "jdbc:h2:$DATABASE_DATA_DIR/$DATABASE_DBNAME;DATABASE_TO_UPPER=TRUE;TRACE_LEVEL_SYSTEM_OUT=3" -user $DATABASE_DBUSER -password $DATABASE_DBPASS -script initialSchema.sql
elif [ "$DATABASE_INIT" = "never" ]; then
    echo "DATABASE_INIT=never: Skipping schema initialization"
else
    echo "Database file exists at $DB_FILE, skipping schema initialization"
    echo "Set DATABASE_INIT=always to force reset, or delete the volume to start fresh"
fi

echo 'Starting Database Server - DB logs below'
echo '---------------------------------------------------------------------------'
exec java -jar $DATABASE_H2JAR -pg -pgPort $DATABASE_PG_PORT -pgAllowOthers -baseDir $DATABASE_DATA_DIR -tcp -tcpPort $DATABASE_TCP_PORT -tcpAllowOthers -web -webPort $DATABASE_WEB_PORT -webExternalNames $DATABASE_WEB_HOSTNAMES -webAllowOthers
