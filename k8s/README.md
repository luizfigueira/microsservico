# Deploy Kubernetes - Microsserviço UserService

Este diretório contém todos os manifestos Kubernetes necessários para deploy completo do microsserviço UserService com sua infraestrutura.

## 📁 Estrutura dos Manifestos

```
k8s/
├── userservice.yaml     # Deployment, Service e Secrets do UserService
├── sqlserver.yaml       # SQL Server com persistência
├── redis.yaml          # Redis com configuração otimizada
├── rabbitmq.yaml       # RabbitMQ com management e clustering
├── prometheus.yaml     # Prometheus com service discovery
├── grafana.yaml        # Grafana com dashboards pré-configurados
├── jaeger.yaml         # Jaeger para distributed tracing
└── README.md           # Este arquivo
```

## 🚀 Deploy Rápido

### Opção 1: Script Automatizado
```bash
# Deploy completo com script
./scripts/deploy-k8s.sh

# Cleanup completo
./scripts/cleanup-k8s.sh
```

### Opção 2: Deploy Manual
```bash
# 1. Aplicar na ordem de dependência
kubectl apply -f k8s/userservice.yaml    # Namespace + UserService
kubectl apply -f k8s/sqlserver.yaml      # SQL Server
kubectl apply -f k8s/redis.yaml          # Redis
kubectl apply -f k8s/rabbitmq.yaml       # RabbitMQ
kubectl apply -f k8s/prometheus.yaml     # Prometheus
kubectl apply -f k8s/grafana.yaml        # Grafana
kubectl apply -f k8s/jaeger.yaml         # Jaeger

# 2. Verificar status
kubectl get pods -n microservices

# 3. Port-forwards para acesso local
kubectl port-forward -n microservices service/userservice-service 5001:80 &
kubectl port-forward -n microservices service/prometheus-service 9090:9090 &
kubectl port-forward -n microservices service/grafana-service 3000:3000 &
kubectl port-forward -n microservices service/jaeger-service 16686:16686 &
kubectl port-forward -n microservices service/rabbitmq-management 15672:15672 &
```

## 🔧 Configurações Importantes

### SQL Server
- **Imagem**: `mcr.microsoft.com/mssql/server:2022-latest`
- **Porta**: 1433
- **Usuário**: `sa`
- **Senha**: `YourPassword123` (configurada em Secret)
- **Persistência**: PVC de 10Gi
- **Recursos**: 2-4Gi RAM, 0.5-1 CPU

### Redis
- **Imagem**: `redis:7-alpine`
- **Porta**: 6379
- **Configuração**: Otimizada para microserviços
- **Persistência**: PVC de 5Gi
- **Recursos**: 256Mi-1Gi RAM, 0.1-0.5 CPU

### RabbitMQ
- **Imagem**: `rabbitmq:3-management-alpine`
- **Portas**: 5672 (AMQP), 15672 (Management), 15692 (Prometheus)
- **Usuário**: `admin`
- **Senha**: `admin123`
- **Clustering**: Preparado para multi-replica
- **Persistência**: PVC de 5Gi
- **Recursos**: 512Mi-2Gi RAM, 0.2-1 CPU

### UserService
- **Imagem**: `userservice:latest` (build local)
- **Porta**: 8080
- **Replicas**: 3
- **Health Checks**: `/health` e `/health/ready`
- **Recursos**: 128Mi-512Mi RAM, 0.1-0.5 CPU

### Observabilidade

#### Prometheus
- **Porta**: 9090
- **Service Discovery**: Automático para pods com anotações
- **Retenção**: 200h
- **Persistência**: PVC de 10Gi

#### Grafana
- **Porta**: 3000
- **Usuário**: `admin`
- **Senha**: `admin`
- **Dashboards**: UserService pré-configurado
- **Datasource**: Prometheus automático

#### Jaeger
- **Porta UI**: 16686
- **Collector**: 14250 (gRPC), 14268 (HTTP)
- **Storage**: Memory (para desenvolvimento)

## 🌐 Acesso aos Serviços

Após o deploy com port-forwards:

| Serviço | URL | Credenciais |
|---------|-----|-------------|
| UserService API | http://localhost:5001 | - |
| Health Check | http://localhost:5001/health | - |
| Swagger | http://localhost:5001/swagger | - |
| Prometheus | http://localhost:9090 | - |
| Grafana | http://localhost:3000 | admin/admin |
| Jaeger | http://localhost:16686 | - |
| RabbitMQ Management | http://localhost:15672 | admin/admin123 |

## 🔍 Comandos Úteis

### Monitoramento
```bash
# Status dos pods
kubectl get pods -n microservices

# Logs do UserService
kubectl logs -f deployment/userservice -n microservices

# Logs de todos os pods
kubectl logs -f -l app=userservice -n microservices

# Describe de um pod com problemas
kubectl describe pod <pod-name> -n microservices

# Events do namespace
kubectl get events -n microservices --sort-by='.lastTimestamp'
```

### Debug
```bash
# Entrar em um pod para debug
kubectl exec -it deployment/userservice -n microservices -- /bin/bash

# Port-forward para serviços específicos
kubectl port-forward -n microservices service/sqlserver-service 1433:1433
kubectl port-forward -n microservices service/redis-service 6379:6379

# Verificar conectividade entre pods
kubectl exec -it deployment/userservice -n microservices -- nslookup sqlserver-service
```

### Scaling
```bash
# Escalar UserService
kubectl scale deployment userservice --replicas=5 -n microservices

# Escalar RabbitMQ (StatefulSet)
kubectl scale statefulset rabbitmq --replicas=3 -n microservices
```

## 📊 Métricas e Observabilidade

### Prometheus Targets
- UserService: `userservice:8080/metrics`
- RabbitMQ: `rabbitmq:15692/metrics`
- Kubernetes API: Automático
- Pods anotados: `prometheus.io/scrape: "true"`

### Grafana Dashboards
- **UserService Metrics**: Request rate, response time, error rate
- **Infrastructure**: CPU, memory, network por pod
- **RabbitMQ**: Queues, messages, connections

### Jaeger Tracing
- **Automatic**: OpenTelemetry configurado no UserService
- **Manual**: Use OpenTelemetry SDK para spans customizados

## 🔒 Segurança

### Secrets Configurados
- `userservice-secrets`: Connection string do SQL Server
- `sqlserver-secrets`: Senha do SA
- `rabbitmq-secrets`: Credenciais do RabbitMQ
- `grafana-secrets`: Senha do admin

### RBAC
- **prometheus-sa**: Acesso para service discovery
- **rabbitmq-sa**: Acesso para clustering

### Network Policies (Opcional)
```bash
# Para implementar isolamento de rede
kubectl apply -f k8s/network-policies.yaml
```

## 🚨 Troubleshooting

### Problemas Comuns

1. **Pods em CrashLoopBackOff**
   ```bash
   kubectl logs <pod-name> -n microservices --previous
   kubectl describe pod <pod-name> -n microservices
   ```

2. **Conectividade entre serviços**
   ```bash
   kubectl exec -it deployment/userservice -n microservices -- nslookup sqlserver-service
   ```

3. **Persistência de dados**
   ```bash
   kubectl get pvc -n microservices
   kubectl describe pvc <pvc-name> -n microservices
   ```

4. **Resources insuficientes**
   ```bash
   kubectl top pods -n microservices
   kubectl describe nodes
   ```

### Logs Importantes
```bash
# UserService
kubectl logs -f deployment/userservice -n microservices

# SQL Server
kubectl logs -f deployment/sqlserver -n microservices

# RabbitMQ
kubectl logs -f statefulset/rabbitmq -n microservices
```

## 🔄 CI/CD Integration

### Build e Push da Imagem
```bash
# Build local
docker build -t userservice:v1.0.0 -f src/services/UserService/Dockerfile .

# Tag para registry
docker tag userservice:v1.0.0 your-registry/userservice:v1.0.0

# Push para registry
docker push your-registry/userservice:v1.0.0

# Update deployment
kubectl set image deployment/userservice userservice=your-registry/userservice:v1.0.0 -n microservices
```

### Rolling Update
```bash
# Update com nova imagem
kubectl set image deployment/userservice userservice=userservice:v1.0.1 -n microservices

# Verificar status do rollout
kubectl rollout status deployment/userservice -n microservices

# Rollback se necessário
kubectl rollout undo deployment/userservice -n microservices
```

## 📈 Próximos Passos

1. **Implementar Ingress Controller** para acesso externo
2. **Configurar Network Policies** para segurança
3. **Adicionar HPA** (Horizontal Pod Autoscaler)
4. **Implementar Service Mesh** (Istio/Linkerd)
5. **Configurar backup** dos volumes persistentes
6. **Implementar monitoring avançado** com alertas
7. **Configurar logging centralizado** (ELK Stack)

## 🔗 Referências

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [.NET on Kubernetes](https://docs.microsoft.com/en-us/dotnet/architecture/containerized-lifecycle/design-develop-containerized-apps/deploy-containers-kubernetes)
- [Prometheus Kubernetes](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#kubernetes_sd_config)
- [Grafana Kubernetes](https://grafana.com/docs/grafana/latest/administration/provisioning/)
- [OpenTelemetry .NET](https://opentelemetry.io/docs/instrumentation/net/)
