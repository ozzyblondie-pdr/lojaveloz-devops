#!/bin/bash
# Cria múltiplos bancos de dados a partir da variável POSTGRES_MULTIPLE_DATABASES
set -e

if [ -n "$POSTGRES_MULTIPLE_DATABASES" ]; then
  for db in $(echo "$POSTGRES_MULTIPLE_DATABASES" | tr ',' ' '); do
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-SQL
      CREATE DATABASE $db;
      GRANT ALL PRIVILEGES ON DATABASE $db TO $POSTGRES_USER;
SQL
    echo "Database '$db' created"
  done
fi
