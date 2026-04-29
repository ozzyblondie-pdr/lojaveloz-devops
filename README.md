# Loja Veloz — Plataforma de Pedidos em Microsserviços

Projeto de referência: entrega contínua de uma plataforma e-commerce do Docker Compose ao Kubernetes com observabilidade e CI/CD.

## Estrutura do Projeto

```
lojaveloz/
├── services/
│   ├── api-gateway/          # Node.js/TypeScript — roteamento e rate limiting
│   ├── order-service/        # Java/Spring Boot — gestão de pedidos
│   ├── payment-service/      # Java/Spring Boot — processamento de pagamentos
│   └── stock-service/        # Java/Spring Boot — controle de estoque
├── k8s/
│   ├── base/                 # Manifests base (Deployment, Service, HPA, NetworkPolicy)
│   └── overlays/             # Kustomize overlays por ambiente (staging, production)
├── infra/
│   ├── otel/                 # OpenTelemetry Collector config
│   ├── prometheus/           # Prometheus + regras de alertas
│   └── grafana/              # Datasources e dashboards
├── terraform/
│   ├── modules/              # Módulos reutilizáveis: vpc, eks, rds
│   └── environments/         # tfvars por ambiente
├── .github/workflows/        # Pipelines CI/CD por serviço
└── scripts/                  # Scripts utilitários
```

## Início Rápido (local)

```bash
# 1. Setup inicial
./scripts/setup-local.sh

# 2. Subir todos os serviços
docker compose up -d

# 3. Verificar saúde
docker compose ps
curl http://localhost:8080/health
```

## Arquitetura

```
Client → API Gateway (8080)
              ├── /api/v1/orders   → order-service (8081)
              ├── /api/v1/payments → payment-service (8082)
              └── /api/v1/stock    → stock-service (8083)

Mensageria (RabbitMQ):
  order-service  →[ORDER_CREATED]→  payment-service
                                    stock-service
```

## Observabilidade

| Ferramenta   | URL local          | Função                    |
|--------------|--------------------|---------------------------|
| Grafana      | localhost:3000      | Dashboards e alertas      |
| Jaeger       | localhost:16686     | Distributed tracing       |
| RabbitMQ UI  | localhost:15672     | Monitoramento de filas    |
| Prometheus   | (interno)           | Coleta de métricas        |

## Deploy Kubernetes

```bash
# Staging
kubectl apply -k k8s/overlays/staging

# Produção (via CI/CD com aprovação manual no GitHub)
kubectl apply -k k8s/overlays/production
```

## Infraestrutura (AWS via Terraform)

```bash
cd terraform
terraform init
terraform workspace select staging
terraform apply -var-file=environments/staging/terraform.tfvars
```

## Vídeo Pitch

> Adicione o link após gravar: `https://youtube.com/watch?v=SEU_ID`

[![Loja Veloz — Vídeo Pitch](https://img.shields.io/badge/YouTube-Vídeo%20Pitch-red)](https://youtube.com/watch?v=SEU_ID)

Roteiro detalhado disponível em [`docs/roteiro-video-pitch.md`](docs/roteiro-video-pitch.md).

---

## Documentação

| Documento | Descrição |
|---|---|
| [`docs/relatorio-teorico.md`](docs/relatorio-teorico.md) | Relatório teórico (Parte 1) — conceitos e justificativas |
| [`docs/relatorio-pratico.md`](docs/relatorio-pratico.md) | Relatório técnico (Parte 2) — documentação do projeto |
| [`docs/roteiro-video-pitch.md`](docs/roteiro-video-pitch.md) | Roteiro e checklist do vídeo pitch |

---

## Estratégia de Deploy

Rolling Update com `maxUnavailable: 0` — garante zero downtime sem overhead de infra adicional.

## Pipeline CI/CD

Cada serviço possui workflow independente em `.github/workflows/`:
1. Build + testes unitários
2. Scan de segurança (Trivy)
3. Build e push da imagem Docker (GHCR)
4. Deploy automático em staging
5. Deploy em produção com aprovação manual
