#!/bin/bash

# Script de deploy completo para Kubernetes
# Este script aplicará todos os manifestos na ordem correta

set -e

echo "🚀 Iniciando deploy do microsserviço no Kubernetes..."

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para log colorido
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
}

# Verificar se kubectl está disponível
if ! command -v kubectl &> /dev/null; then
    error "kubectl não está instalado ou não está no PATH"
    exit 1
fi

# Verificar conectividade com o cluster
if ! kubectl cluster-info &> /dev/null; then
    error "Não foi possível conectar ao cluster Kubernetes"
    exit 1
fi

log "Cluster Kubernetes conectado ✓"

# Ir para o diretório do projeto
cd "$(dirname "$0")/.."
PROJECT_ROOT=$(pwd)

log "Diretório do projeto: $PROJECT_ROOT"

# Função para aplicar manifesto e aguardar
apply_and_wait() {
    local file=$1
    local resource_type=$2
    local resource_name=$3
    
    log "Aplicando $file..."
    kubectl apply -f "k8s/$file"
    
    if [ -n "$resource_type" ] && [ -n "$resource_name" ]; then
        log "Aguardando $resource_type/$resource_name ficar pronto..."
        kubectl wait --for=condition=ready "$resource_type/$resource_name" -n microservices --timeout=300s || warn "$resource_type/$resource_name pode não estar pronto"
    fi
}

# Aplicar manifestos na ordem de dependência
log "1. Criando namespace e recursos base..."
kubectl apply -f k8s/userservice.yaml  # Inclui namespace

log "2. Deploying infraestrutura de dados..."
apply_and_wait "sqlserver.yaml" "pod" "-l app=sqlserver"
apply_and_wait "redis.yaml" "pod" "-l app=redis"

log "3. Deploying message broker..."
apply_and_wait "rabbitmq.yaml" "pod" "-l app=rabbitmq"

log "4. Deploying observabilidade..."
apply_and_wait "prometheus.yaml" "pod" "-l app=prometheus"
apply_and_wait "grafana.yaml" "pod" "-l app=grafana"
apply_and_wait "jaeger.yaml" "pod" "-l app=jaeger"

log "5. Aguardando serviços de infraestrutura..."
sleep 30

log "6. Rebuilding e deploying UserService..."
# Build da imagem Docker local (para desenvolvimento)
if command -v docker &> /dev/null; then
    log "Fazendo build da imagem Docker..."
    docker build -t userservice:latest -f src/services/UserService/Dockerfile .
    
    # Se usando kind ou minikube, carregar a imagem
    if command -v kind &> /dev/null; then
        log "Carregando imagem no kind..."
        kind load docker-image userservice:latest || warn "kind não disponível"
    elif command -v minikube &> /dev/null; then
        log "Carregando imagem no minikube..."
        minikube image load userservice:latest || warn "minikube não disponível"
    fi
fi

# Aplicar deployment do UserService
kubectl apply -f k8s/userservice.yaml
kubectl wait --for=condition=ready pod -l app=userservice -n microservices --timeout=300s || warn "UserService pode não estar pronto"

log "7. Verificando status dos deployments..."
kubectl get pods -n microservices

log "8. Configurando port-forwarding para acesso local..."

# Função para criar port-forward em background
create_port_forward() {
    local service=$1
    local local_port=$2
    local remote_port=$3
    local name=$4
    
    # Matar processos existentes na porta
    lsof -ti:$local_port | xargs kill -9 2>/dev/null || true
    
    log "Configurando port-forward para $name na porta $local_port..."
    kubectl port-forward -n microservices service/$service $local_port:$remote_port > /dev/null 2>&1 &
    sleep 2
}

# Port forwards para acesso local
create_port_forward "userservice-service" "5001" "80" "UserService"
create_port_forward "prometheus-service" "9090" "9090" "Prometheus"
create_port_forward "grafana-service" "3000" "3000" "Grafana"
create_port_forward "jaeger-service" "16686" "16686" "Jaeger"
create_port_forward "rabbitmq-management" "15672" "15672" "RabbitMQ Management"

log "Deploy concluído com sucesso! 🎉"
echo ""
echo -e "${BLUE}===============================================${NC}"
echo -e "${BLUE}          SERVIÇOS KUBERNETES                 ${NC}"
echo -e "${BLUE}===============================================${NC}"
echo -e "${GREEN}UserService API:${NC}     http://localhost:5001"
echo -e "${GREEN}Health Check:${NC}        http://localhost:5001/health"
echo -e "${GREEN}Metrics:${NC}             http://localhost:5001/metrics"
echo -e "${GREEN}Swagger:${NC}             http://localhost:5001/swagger"
echo ""
echo -e "${GREEN}Prometheus:${NC}          http://localhost:9090"
echo -e "${GREEN}Grafana:${NC}             http://localhost:3000 (admin/admin)"
echo -e "${GREEN}Jaeger:${NC}              http://localhost:16686"
echo -e "${GREEN}RabbitMQ:${NC}            http://localhost:15672 (admin/admin123)"
echo ""
echo -e "${BLUE}===============================================${NC}"
echo ""

log "Para ver os logs dos pods, use:"
echo "  kubectl logs -f deployment/userservice -n microservices"
echo ""
log "Para verificar status dos pods, use:"
echo "  kubectl get pods -n microservices"
echo ""
log "Para parar os port-forwards, use:"
echo "  pkill -f 'kubectl port-forward'"
echo ""
log "Para deletar todos os recursos, use:"
echo "  kubectl delete namespace microservices"
