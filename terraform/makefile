NAMESPACE=theboss
PORT_FORWARD_PID_FILE=.port-forward.pid
include .env.postgres
export

.PHONY: start addons init validate plan apply-plan run test delete all

terraform: 
	sudo apt update && sudo apt install terraform

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


port-forward:
	@echo "🌐 Starting port-forward to frontend..."
	@kubectl port-forward svc/frontend 8080:80 -n $(NAMESPACE) >/dev/null 2>&1 & \
	echo $$! > $(PORT_FORWARD_PID_FILE)
	@echo "✅ Frontend available at http://localhost:8080"

db-setup:
	@echo "🚀 Running database migrations..."
	@BACKEND_POD=$$(kubectl get pod -l app=backend -n $(NAMESPACE) -o jsonpath="{.items[0].metadata.name}") && \
	kubectl exec $$BACKEND_POD -n $(NAMESPACE) -- \
	poetry run alembic -c ./backend/alembic.ini upgrade head
	@echo "✅ Database updated!"

	@echo "👤 Creating admin user..."
	@BACKEND_POD=$$(kubectl get pod -l app=backend -n $(NAMESPACE) -o jsonpath="{.items[0].metadata.name}") && \
	kubectl exec $$BACKEND_POD -n $(NAMESPACE) -- \
	poetry run python backend/src/initialize_admin.py
	@echo "✅ Admin user created!"

	@echo "🌱 Seeding database..."
	@BACKEND_POD=$$(kubectl get pod -l app=backend -n $(NAMESPACE) -o jsonpath='{.items[0].metadata.name}') && \
	kubectl exec $$BACKEND_POD -n $(NAMESPACE) -- \
	poetry run python backend/src/seed.py
	@echo "✅ Database populated!"


run: delete start addons init img validate plan apply-plan db-setup port-forward
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
