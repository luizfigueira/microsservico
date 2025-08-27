# UserService

Microsserviço responsável pelo gerenciamento de usuários seguindo Clean Architecture.

## Estrutura do Projeto

```
UserService/
├── UserService.API/           # Web API controllers
├── UserService.Application/   # Business logic, CQRS handlers
├── UserService.Domain/        # Domain entities, repositories interfaces
├── UserService.Infrastructure/ # Data access, external services
├── UserService.Tests.Unit/    # Unit tests
├── UserService.Tests.Integration/ # Integration tests
└── Dockerfile
```

## Tecnologias Utilizadas

- **.NET 8** - Framework principal
- **Entity Framework Core** - ORM para SQL Server
- **MediatR** - Implementação CQRS
- **Serilog** - Structured logging
- **OpenTelemetry** - Observabilidade e tracing
- **xUnit** - Framework de testes
- **FluentAssertions** - Assertions mais legíveis
- **Testcontainers** - Testes de integração com containers

## Como Executar

### Pré-requisitos
- .NET 8 SDK
- Docker e Docker Compose

### Desenvolvimento Local

1. **Subir infraestrutura:**
```bash
cd docker
docker-compose up -d sqlserver redis rabbitmq jaeger prometheus grafana
```

2. **Executar o serviço:**
```bash
cd src/services/UserService/UserService.API
dotnet run
```

3. **Acessar Swagger:**
```
http://localhost:5000/swagger
```

### Executar com Docker

```bash
cd docker
docker-compose up userservice
```

## Testes

### Testes Unitários
```bash
dotnet test UserService.Tests.Unit/
```

### Testes de Integração
```bash
dotnet test UserService.Tests.Integration/
```

### Coverage
```bash
dotnet test --collect:"XPlat Code Coverage"
```

## APIs

### Endpoints

- `GET /api/users/{id}` - Buscar usuário por ID
- `POST /api/users` - Criar novo usuário

### Health Checks

- `GET /health` - Health check básico
- `GET /health/ready` - Readiness probe
- `GET /metrics` - Métricas Prometheus

## Observabilidade

- **Logs**: Structured logging com Serilog
- **Metrics**: Prometheus endpoint em `/metrics`
- **Tracing**: OpenTelemetry com Jaeger
- **Dashboards**: Grafana (http://localhost:3000, admin/admin)

## Deploy Kubernetes

```bash
kubectl apply -f k8s/userservice.yaml
```

## Banco de Dados

O serviço utiliza Entity Framework Core com SQL Server. As migrations são aplicadas automaticamente no startup em ambiente de desenvolvimento.
