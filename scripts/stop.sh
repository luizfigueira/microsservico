#!/bin/bash

# Script para parar todos os serviços do microsserviço
set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
}

cd "$(dirname "$0")/.."

log "Parando todos os serviços..."
docker-compose -f docker/docker-compose.yml down

log "Removendo volumes (opcional - descomente se necessário)..."
# docker-compose -f docker/docker-compose.yml down --volumes

log "Serviços parados com sucesso! 🛑"
