NAMESPACE=three-tier-app

include .env.postgres
export

.PHONY: start addons init validate plan apply-plan run test delete all

start:
	@echo "🚀 Starting Minikube..."
	minikube start --driver=docker

addons:
	@echo "🔧 Enabling Minikube addons..."
	minikube addons enable ingress
	minikube addons enable default-storageclass

init:
	@echo "📦 Initializing Terraform..."
	terraform init

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

apply:
	@echo "⚡ Applying Terraform directly..."
	terraform apply -auto-approve \
		-var="postgres_user=$(POSTGRES_USER)" \
		-var="postgres_password=$(POSTGRES_PASSWORD)" \
		-var="postgres_db=$(POSTGRES_DB)"

run: start addons init validate apply
	@echo "✅ Infrastructure deployed!"

test:
	@echo "🧪 Testing deployment..."
	kubectl get pods -n $(NAMESPACE)
	kubectl get pvc -n $(NAMESPACE)

delete:
	@echo "💥 Deleting Minikube..."
	minikube delete --all

all: run test
