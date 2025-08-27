# Copilot Instructions - Microsserviços C#

## Visão Geral da Arquitetura

Este é um projeto de microsserviços .NET/C# com SQL Server, Redis, RabbitMQ, orquestrado com Kubernetes e monitorado com Prometheus, Grafana, OpenTelemetry e Jaeger.

## Stack Tecnológica

- **Backend**: .NET 8+ / C#
- **Database**: SQL Server
- **Cache**: Redis
- **Message Broker**: RabbitMQ
- **Orquestração**: Kubernetes
- **Observabilidade**: Prometheus, Grafana, OpenTelemetry, Jaeger

## Estrutura de Projeto

- `src/services/` - Microsserviços individuais (.NET)
- `src/shared/` - Bibliotecas compartilhadas (Common, Contracts, Infrastructure)
- `k8s/` - Manifestos Kubernetes (deployments, services, configmaps)
- `docker/` - Dockerfiles e docker-compose para desenvolvimento local
- `monitoring/` - Configurações de Prometheus, Grafana dashboards
- `docs/` - Documentação da arquitetura e APIs
- `scripts/` - Scripts PowerShell/bash para build e deploy

## Convenções de Desenvolvimento

### Estrutura de Microsserviços .NET
Cada serviço deve seguir a estrutura:
```
src/services/{ServiceName}/
├── {ServiceName}.API/           # Web API project
├── {ServiceName}.Application/   # Business logic, CQRS handlers
├── {ServiceName}.Domain/        # Domain entities, value objects
├── {ServiceName}.Infrastructure/ # Data access, external services
├── {ServiceName}.Tests/         # Unit and integration tests
├── Dockerfile
└── README.md
```

### Padrões Arquiteturais
- **Clean Architecture** com Domain, Application, Infrastructure layers
- **CQRS** com MediatR para separação de comandos/queries
- **Event Sourcing** onde apropriado
- **Repository Pattern** para acesso a dados
- **Unit of Work** para transações

### Comunicação Entre Serviços
- **APIs REST** para comunicação síncrona (HTTP/HTTPS)
- **RabbitMQ** para eventos assíncronos e mensageria
- **Redis** para cache distribuído e sessões
- **Service Discovery** via Kubernetes Services

### Convenções de Código C#
- Use **PascalCase** para classes, métodos, propriedades
- Use **camelCase** para variáveis locais e parâmetros
- Prefixe interfaces com `I` (ex: `IUserRepository`)
- Sufixe serviços com `Service` (ex: `UserService`)
- Use **async/await** para operações I/O
- Implemente **CancellationToken** em métodos async

### Testes
#### Estrutura de Testes
```
src/services/{ServiceName}/
├── {ServiceName}.Tests.Unit/     # Testes unitários
├── {ServiceName}.Tests.Integration/ # Testes de integração
└── {ServiceName}.Tests.EndToEnd/  # Testes E2E (opcional)
```

#### Frameworks e Ferramentas
- **xUnit** - Framework de testes principal
- **FluentAssertions** - Assertions mais legíveis
- **Moq** - Mocking para testes unitários
- **Testcontainers** - Containers para testes de integração
- **WebApplicationFactory** - Testes de integração de APIs
- **Bogus** - Geração de dados fake para testes

#### Convenções de Nomenclatura
- Classes de teste: `{ClassUnderTest}Tests`
- Métodos de teste: `{MethodUnderTest}_When{Condition}_Should{ExpectedResult}`
- Arrange/Act/Assert pattern
- Use `[Fact]` para testes simples, `[Theory]` com `[InlineData]` para testes parametrizados

#### Testes Unitários
- Teste cada classe/método em isolamento
- Mock todas as dependências externas
- Foque na lógica de negócio (Domain e Application layers)
- Coverage mínimo de 80% para Domain e Application

#### Testes de Integração
- Use Testcontainers para SQL Server, Redis, RabbitMQ
- Teste fluxos completos através das camadas
- Valide integração com bancos de dados reais
- Teste endpoints de API com `WebApplicationFactory`

## Comandos de Desenvolvimento

### .NET Development
- `dotnet build` - Build da solution
- `dotnet test` - Execução de todos os testes
- `dotnet test --filter "Category=Unit"` - Executar apenas testes unitários
- `dotnet test --filter "Category=Integration"` - Executar apenas testes de integração
- `dotnet test --collect:"XPlat Code Coverage"` - Executar testes com coverage
- `dotnet run --project src/services/{ServiceName}/{ServiceName}.API` - Executar serviço específico
- `dotnet ef migrations add {MigrationName} --project {ServiceName}.Infrastructure` - Criar migration

### Testes
- `dotnet test {ServiceName}.Tests.Unit/` - Executar testes unitários de um serviço
- `dotnet test {ServiceName}.Tests.Integration/` - Executar testes de integração de um serviço
- `reportgenerator -reports:"**/coverage.cobertura.xml" -targetdir:"coverage-report"` - Gerar relatório de coverage

### Docker
- `docker-compose up -d` - Subir infraestrutura (SQL Server, Redis, RabbitMQ)
- `docker-compose up {service-name}` - Subir serviço específico
- `docker-compose logs -f {service-name}` - Ver logs de um serviço

### Kubernetes
- `kubectl apply -f k8s/` - Deploy dos manifestos
- `kubectl get pods -n {namespace}` - Verificar status dos pods
- `kubectl logs -f deployment/{service-name}` - Ver logs do serviço

### Observabilidade
- **Health Checks**: `/health` e `/health/ready`
- **Metrics**: `/metrics` (Prometheus format)
- **Tracing**: OpenTelemetry com Jaeger
- **Logs**: Structured logging com Serilog

## Notas Importantes

- Sempre considere tolerância a falhas ao integrar serviços
- Cada serviço deve ter sua própria base de dados SQL Server
- Implemente observabilidade (logs, métricas, tracing) desde o início
- Use versionamento de APIs para backward compatibility
- Configure health checks para Kubernetes readiness/liveness probes
- Implemente retry policies e circuit breakers com Polly
- Use Redis para cache distribuído e sessões
- Configure RabbitMQ exchanges e queues por domínio de negócio

## Exemplos de Implementação

### Entidade Domain (UserService)
```csharp
public class User
{
    public Guid Id { get; private set; }
    public string Name { get; private set; }
    
    public User(string name, string email)
    {
        Id = Guid.NewGuid();
        Name = name ?? throw new ArgumentNullException(nameof(name));
        // Business logic in constructor
    }
}
```

### Command Handler CQRS
```csharp
public class CreateUserCommandHandler : IRequestHandler<CreateUserCommand, CreateUserResponse>
{
    public async Task<CreateUserResponse> Handle(CreateUserCommand request, CancellationToken cancellationToken)
    {
        // Business logic here
    }
}
```

### Controller com MediatR
```csharp
[ApiController]
[Route("api/[controller]")]
public class UsersController : ControllerBase
{
    private readonly IMediator _mediator;
    
    [HttpPost]
    public async Task<IActionResult> CreateUser(CreateUserCommand command, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(command, cancellationToken);
        return CreatedAtAction(nameof(GetUser), new { id = result.Id }, result);
    }
}
```

---

**Nota**: Este arquivo será atualizado conforme o projeto evolui. Por favor, mantenha as instruções atualizadas com as convenções reais do projeto.
