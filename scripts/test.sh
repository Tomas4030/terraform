GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' 

log_header() { echo -e "\n${CYAN}=== $1 ===${NC}"; }

log_header "POD STATUS"
kubectl get pods -o wide

log_header "SERVICES AND ENDPOINTS"
kubectl get svc,endpoints

log_header "INGRESS CONFIGURATION"
kubectl get ingress

log_header "HEALTH CHECKS"

if ! lsof -i :8080 > /dev/null; then
    echo -e "${YELLOW}⚠️  Port-forward not detected. Attempting to reactivate...${NC}"
    kubectl port-forward svc/frontend 8080:80 >/dev/null 2>&1 &
    sleep 2
fi

if curl -s --head --request GET http://localhost:8080 | grep "200 OK" > /dev/null; then
   echo -e "${GREEN}✅ Frontend accessible at http://localhost:8080${NC}"
else
   echo -e "${RED}❌ Failed to access Frontend even after port-forward attempt.${NC}"
   echo -e "Tip: Check if the pod is in 'CrashLoopBackOff' status using 'kubectl get pods'"
fi

log_header "BACKEND LOGS (Last 5 lines)"
BACKEND_POD=$(kubectl get pod -l app=backend -o jsonpath="{.items[0].metadata.name}" 2>/dev/null)

if [ -z "$BACKEND_POD" ]; then
    echo -e "${RED}❌ Backend pod not found.${NC}"
else
    echo -e "Logs for: $BACKEND_POD"
    kubectl logs "$BACKEND_POD" --tail=5
fi

echo -e "\n${GREEN}Verification complete!${NC}"