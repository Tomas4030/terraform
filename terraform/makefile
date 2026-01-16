NAMESPACE=theboss

include .env.postgres
export

.PHONY: start addons init validate plan apply-plan run test delete all

start:
	clear	
	@echo "🚀 Starting Minikube..."
	minikube start --driver=docker

addons:
	@echo "🔧 Enabling Minikube addons..."
	minikube addons enable ingress
	minikube addons enable default-storageclass

init:
	@echo "📦 Initializing Terraform..."
	terraform init

img:
	@echo "🚧 Building backend and frontend images in Minikube..."
	eval $$(minikube docker-env) && \
	docker build -t backend:latest -f ../backend/ops/Dockerfile .. && \
	docker build -t frontend:latest ../frontend/


validate:
	@echo "🔍 Validating Terraform..."
	terraform validate

plan:
	@echo "⚡ Generating Terraform plan..."
	terraform plan -out=k8s.plan \
		-var="postgres_user=$(POSTGRES_USER)" \
		-var="postgres_password=$(POSTGRES_PASSWORD)" \
		-var="postgres_db=$(POSTGRES_DB)"

apply-plan:
	terraform apply k8s.plan


run: delete start addons init img validate plan apply-plan
	@echo "✅ Infrastructure deployed!"

test:
	@echo "🧪 Testing deployment..."
	kubectl get pods -n $(NAMESPACE)
	kubectl wait --for=condition=Ready pod -l app=backend -n $(NAMESPACE) --timeout=120s
	kubectl get svc -n $(NAMESPACE)


delete:
	@echo "💥 Deleting Minikube..."
	minikube delete --all

all: run test
