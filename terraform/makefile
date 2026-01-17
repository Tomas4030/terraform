NAMESPACE=theboss
PORT_FORWARD_PID_FILE=.port-forward.pid
include .env.postgres


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


port-forward:
	@echo "🌐 Starting port-forward to frontend..."
	@kubectl port-forward svc/frontend 8080:80 -n $(NAMESPACE) >/dev/null 2>&1 & \
	echo $$! > $(PORT_FORWARD_PID_FILE)
	@echo "✅ Frontend available at http://localhost:8080"


db-setup:
	@BACKEND_POD=$$(kubectl get pod -l app=backend -n $(NAMESPACE) -o jsonpath='{.items[0].metadata.name}'); \
	kubectl exec $$BACKEND_POD -n $(NAMESPACE) -- poetry run alembic -c ./backend/alembic.ini upgrade head; \
	kubectl exec $$BACKEND_POD -n $(NAMESPACE) -- poetry run python backend/src/initialize_admin.py; \
	kubectl exec $$BACKEND_POD -n $(NAMESPACE) -- poetry run python backend/src/seed.py; \
	echo "✅ Database migrated, admin created, seed populated!"

run: delete start addons init img validate plan apply-plan db-setup port-forward
	@echo "✅ SYSTEM ONLINE"
	@echo "URL: http://localhost:8080"
	@echo "Admin Credentials - Email: admin@cstrader.com | Password: SuperSecureAdmin123!"

test:
	@echo "\n=== POD STATUS ==="
	@kubectl get pods -n $(NAMESPACE) -o wide

	@echo "\n=== SERVICES AND ENDPOINTS ==="
	@kubectl get svc,endpoints -n $(NAMESPACE)

	@echo "\n=== INGRESS CONFIGURATION ==="
	@kubectl get ingress -n $(NAMESPACE)

	@echo "\n=== HEALTH CHECKS ==="
	@if ! lsof -i :8080 > /dev/null; then \
		echo "Port-forward not detected. Attempting to start..."; \
		kubectl port-forward svc/frontend 8080:80 -n $(NAMESPACE) >/dev/null 2>&1 & \
		sleep 2; \
	fi

	@if curl -s --head --request GET http://localhost:8080 | grep "200 OK" > /dev/null; then \
		echo "✅ Frontend accessible at http://localhost:8080"; \
	else \
		echo "❌ Failed to access Frontend even after port-forward attempt."; \
		echo "Tip: Check if the pod is in 'CrashLoopBackOff' using 'kubectl get pods -n $(NAMESPACE)'"; \
	fi

	@echo "\n=== BACKEND LOGS (Last 5 lines) ==="
	@BACKEND_POD=$$(kubectl get pod -l app=backend -n $(NAMESPACE) -o jsonpath='{.items[0].metadata.name}' 2>/dev/null); \
	if [ -z "$$BACKEND_POD" ]; then \
		echo "❌ Backend pod not found."; \
	else \
		echo "Logs for: $$BACKEND_POD"; \
		kubectl logs "$$BACKEND_POD" -n $(NAMESPACE) --tail=5; \
	fi


delete:
	@echo "💥 Deleting Minikube..."
	minikube delete --all


all: run test
