#!/bin/bash

# Script para remover todos os recursos do Kubernetes
set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
}

cd "$(dirname "$0")/.."

log "Removendo recursos do Kubernetes..."

# Parar port-forwards
log "Parando port-forwards..."
pkill -f 'kubectl port-forward' 2>/dev/null || true

# Deletar namespace (remove todos os recursos)
log "Deletando namespace microservices..."
kubectl delete namespace microservices --ignore-not-found=true

# Aguardar namespace ser removido
log "Aguardando namespace ser removido..."
kubectl wait --for=delete namespace/microservices --timeout=120s 2>/dev/null || warn "Timeout aguardando remoção do namespace"

log "Recursos removidos com sucesso! 🗑️"
