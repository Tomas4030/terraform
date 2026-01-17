#!/bin/bash

GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

set -e

log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_step() { echo -e "${CYAN}🚀 $1${NC}"; }

clear   

if minikube status !| grep -q "Running"; then
    log_info "Minikube is already running."
    ./scripts/cleanup.sh
fi

clear

log_step "Starting Minikube..."
minikube start --driver=docker 

minikube addons enable ingress >/dev/null
minikube addons enable metrics-server >/dev/null
minikube addons enable default-storageclass >/dev/null

eval $(minikube docker-env)

log_step "Building Docker Images..."
docker build -t frontend:latest -f frontend/Dockerfile frontend/ --quiet
docker build -t backend:latest -f backend/ops/Dockerfile . --quiet
log_success "Images ready!"

log_step "Configuring Infrastructure and Secrets..."
kubectl create secret generic postgres-secret --from-env-file=.env.postgres --dry-run=client -o yaml | kubectl apply -f -
kubectl create secret generic app-secret --from-env-file=.env.app --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f ./infra/database/
kubectl apply -f ./infra/backend/
kubectl apply -f ./infra/frontend/
kubectl apply -f ./infra/ingress/

log_info "Waiting for Postgres..."
kubectl wait --for=condition=Ready pod -l app=postgres --timeout=120s

log_info "Waiting for Backend..."
kubectl wait --for=condition=Ready pod -l app=backend --timeout=120s

log_info "Waiting for Frontend..."
kubectl wait --for=condition=Ready pod -l app=frontend --timeout=120s

BACKEND_POD=$(kubectl get pod -l app=backend -o jsonpath="{.items[0].metadata.name}")

log_step "Running Database Migrations..."
kubectl exec "$BACKEND_POD" -- poetry run alembic -c ./backend/alembic.ini upgrade head
log_success "Database updated!"

log_step "Creating admin user..."
BACKEND_POD=$(kubectl get pod -l app=backend -o jsonpath="{.items[0].metadata.name}")
kubectl exec "$BACKEND_POD" -- poetry run python backend/src/initialize_admin.py
log_success "Admin user created!"

log_step "Populating database with seed data..."
kubectl exec "$BACKEND_POD" -- poetry run python ./backend/src/seed.py
log_success "Database populated!"

log_success "SYSTEM ONLINE"
log_info "URL: http://localhost:8080"
log_info "Admin Credentials - Email: admin@cstrader.com | Password: SuperSecureAdmin123!"

kubectl port-forward svc/frontend 8080:80 >/dev/null 2>&1 &


wait
