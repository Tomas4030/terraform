set -e

echo "🧹 Deleting database resources..."
kubectl delete -f ./infra/database/ --ignore-not-found

echo "🧹 Deleting backend resources..."
kubectl delete -f ./infra/backend/ --ignore-not-found

echo "🧹 Deleting frontend resources..."
kubectl delete -f ./infra/frontend/ --ignore-not-found

echo "🧹 Resetting Minikube..."
minikube delete

echo "✅ Cleanup complete"
 