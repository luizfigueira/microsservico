#!/bin/bash

# Script de deploy para microsserviço UserService
# Este script faz o build e deploy completo usando Docker Compose

set -e

echo "🚀 Iniciando deploy do microsserviço UserService..."

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

# Verificar se Docker está rodando
if ! docker info >/dev/null 2>&1; then
    error "Docker não está rodando. Por favor, inicie o Docker e tente novamente."
    exit 1
fi

log "Docker está rodando ✓"

# Ir para o diretório do projeto
cd "$(dirname "$0")/.."
PROJECT_ROOT=$(pwd)

log "Diretório do projeto: $PROJECT_ROOT"

# Limpar containers e volumes antigos se existirem
log "Limpando containers e volumes antigos..."
docker-compose -f docker/docker-compose.yml down --volumes --remove-orphans 2>/dev/null || true

# Build da aplicação .NET
log "Fazendo build da aplicação .NET..."
dotnet build src/services/UserService/UserService.API/UserService.API.csproj -c Release

# Executar testes unitários
log "Executando testes unitários..."
dotnet test src/services/UserService/UserService.Tests.Unit/ --no-build --verbosity minimal

# Build e start dos containers
log "Fazendo build e iniciando containers Docker..."
docker-compose -f docker/docker-compose.yml up --build -d

# Aguardar serviços ficarem prontos
log "Aguardando serviços ficarem prontos..."

# Função para verificar se um serviço está healthy
wait_for_service() {
    local service_name=$1
    local url=$2
    local timeout=${3:-60}
    
    echo -n "Aguardando $service_name "
    for i in $(seq 1 $timeout); do
        if curl -s "$url" >/dev/null 2>&1; then
            echo " ✓"
            return 0
        fi
        echo -n "."
        sleep 1
    done
    echo " ✗"
    warn "$service_name não ficou pronto em ${timeout}s"
    return 1
}

# Verificar serviços
wait_for_service "SQL Server" "localhost:1433" 30 || true
wait_for_service "Redis" "localhost:6379" 30 || true
wait_for_service "RabbitMQ" "localhost:15672" 30 || true
wait_for_service "UserService Health" "http://localhost:5001/health" 60
wait_for_service "Prometheus" "http://localhost:9090" 30 || true
wait_for_service "Grafana" "http://localhost:3000" 30 || true
wait_for_service "Jaeger" "http://localhost:16686" 30 || true

log "Deploy concluído com sucesso! 🎉"
echo ""
echo -e "${BLUE}===============================================${NC}"
echo -e "${BLUE}          SERVIÇOS DISPONÍVEIS                ${NC}"
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

# Testar endpoint básico
log "Testando endpoint da API..."
if curl -s "http://localhost:5001/health" | grep -q "Healthy"; then
    log "API está respondendo corretamente ✓"
else
    warn "API pode não estar respondendo corretamente"
fi

log "Para ver os logs dos serviços, use:"
echo "  docker-compose -f docker/docker-compose.yml logs -f"
echo ""
log "Para parar todos os serviços, use:"
echo "  docker-compose -f docker/docker-compose.yml down"
