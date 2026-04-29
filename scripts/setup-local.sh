#!/bin/bash
set -euo pipefail

echo "=== Loja Veloz — Setup Local ==="

# Cria secrets locais para dev
mkdir -p secrets
echo "lojaveloz_dev" > secrets/pg_password.txt
echo "lojaveloz_dev" > secrets/rabbit_password.txt
echo "admin" > secrets/grafana_password.txt
chmod 600 secrets/*.txt
echo "[ok] Secrets criados"

# Copia .env
cp .env.example .env
echo "[ok] .env criado"

# Torna scripts executáveis
chmod +x infra/postgres/init-multiple-dbs.sh
echo "[ok] Scripts com permissão de execução"

echo ""
echo "Para subir o ambiente:"
echo "  docker compose up -d"
echo ""
echo "Serviços disponíveis após inicialização:"
echo "  API Gateway:    http://localhost:8080"
echo "  Grafana:        http://localhost:3000  (admin/admin)"
echo "  RabbitMQ UI:    http://localhost:15672 (lojaveloz/lojaveloz_dev)"
echo "  Jaeger UI:      http://localhost:16686"
