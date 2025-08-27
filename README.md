# Microsserviços .NET

Projeto de microsserviços utilizando .NET 8, Clean Architecture, SQL Server, Redis, RabbitMQ, Kubernetes e observabilidade completa.

## Arquitetura

Este projeto implementa uma arquitetura de microsserviços com as seguintes características:

- **Clean Architecture** com separação clara de responsabilidades
- **CQRS** com MediatR para separação de comandos e queries
- **Event-Driven Architecture** com RabbitMQ
- **Observabilidade completa** com OpenTelemetry, Prometheus, Grafana e Jaeger
- **Testes abrangentes** com testes unitários e de integração
- **Containerização** com Docker e orquestração com Kubernetes

## Stack Tecnológica

- **.NET 8** - Framework principal
- **SQL Server** - Banco de dados relacional
- **Redis** - Cache distribuído
- **RabbitMQ** - Message broker
- **Kubernetes** - Orquestração de containers
- **Prometheus** - Métricas
- **Grafana** - Dashboards e visualização
- **OpenTelemetry** - Telemetria
- **Jaeger** - Distributed tracing

## Estrutura do Projeto

```
├── src/
│   ├── services/
│   │   └── UserService/          # Microsserviço de usuários
│   └── shared/                   # Bibliotecas compartilhadas
├── docker/
│   ├── docker-compose.yml       # Infraestrutura local
│   └── monitoring/              # Configurações de monitoramento
├── k8s/                         # Manifestos Kubernetes
├── scripts/                     # Scripts de automação
└── docs/                        # Documentação
```

## Microsserviços

### UserService
Responsável pelo gerenciamento de usuários do sistema.

**Endpoints:**
- `GET /api/users/{id}` - Buscar usuário por ID
- `POST /api/users` - Criar novo usuário

## Como Executar

### Pré-requisitos
- .NET 8 SDK
- Docker e Docker Compose
- kubectl (para deploy Kubernetes)

### Desenvolvimento Local

1. **Clonar o repositório:**
```bash
git clone <repository-url>
cd microsservico
```

2. **Subir infraestrutura:**
```bash
cd docker
docker-compose up -d
```

3. **Restaurar dependências:**
```bash
dotnet restore
```

4. **Executar testes:**
```bash
dotnet test
```

5. **Executar UserService:**
```bash
cd src/services/UserService/UserService.API
dotnet run
```

### URLs de Acesso

- **UserService API**: http://localhost:5001
- **Swagger**: http://localhost:5001/swagger
- **Grafana**: http://localhost:3000 (admin/admin)
- **Prometheus**: http://localhost:9090
- **Jaeger**: http://localhost:16686
- **RabbitMQ Management**: http://localhost:15672 (admin/admin123)

## Testes

### Executar todos os testes
```bash
dotnet test
```

### Testes por categoria
```bash
# Testes unitários
dotnet test --filter "Category=Unit"

# Testes de integração
dotnet test --filter "Category=Integration"
```

### Coverage de código
```bash
dotnet test --collect:"XPlat Code Coverage"
reportgenerator -reports:"**/coverage.cobertura.xml" -targetdir:"coverage-report"
```

## Deploy

### Docker
```bash
cd docker
docker-compose up --build
```

### Kubernetes
```bash
kubectl apply -f k8s/
```

## Observabilidade

O projeto implementa observabilidade completa com:

- **Logs estruturados** com Serilog
- **Métricas** coletadas pelo Prometheus
- **Distributed tracing** com OpenTelemetry e Jaeger
- **Dashboards** no Grafana
- **Health checks** para monitoramento de saúde

### Monitoramento

- Health checks disponíveis em `/health` e `/health/ready`
- Métricas Prometheus em `/metrics`
- Traces enviados automaticamente para Jaeger

## Contribuição

1. Siga as convenções definidas em `.github/copilot-instructions.md`
2. Implemente testes para novas funcionalidades
3. Mantenha coverage mínimo de 80% para Domain e Application
4. Use conventional commits para mensagens de commit

## Licença

Este projeto está sob a licença MIT.
