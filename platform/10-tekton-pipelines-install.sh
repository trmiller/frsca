#!/usr/bin/env bash
set -euo pipefail

GIT_ROOT=$(git rev-parse --show-toplevel)

# Define variables.
C_GREEN='\033[32m'
C_RESET_ALL='\033[0m'

# Setup Tekton.
echo -e "${C_GREEN}Installing Tekton CD...${C_RESET_ALL}"
kubectl apply --filename "$GIT_ROOT"/platform/vendor/tekton/pipeline/release.yaml
kubectl apply --filename "$GIT_ROOT"/platform/vendor/tekton/triggers/release.yaml
kubectl apply --filename "$GIT_ROOT"/platform/vendor/tekton/triggers/interceptors.yaml

kubectl apply --filename "${GIT_ROOT}/platform/components/tekton/triggers/rbac.yaml"

# Setup the Dashboard.
#   Use `kubectl proxy --port=8080` and then
#   http://localhost:8080/api/v1/namespaces/tekton-pipelines/services/tekton-dashboard:http/proxy/
#   to access it.

echo -e "${C_GREEN}Installing up Tekton Dashboard...${C_RESET_ALL}"
kubectl apply --filename "$GIT_ROOT"/platform/vendor/tekton/dashboard/tekton-dashboard-release.yaml
kubectl rollout status -n tekton-pipelines deployment/tekton-dashboard

# Wait for tekton deployments to finish
for deployment in tekton-pipelines-webhook tekton-pipelines-controller tekton-triggers-controller tekton-triggers-core-interceptors tekton-triggers-webhook; do
  kubectl rollout status -n tekton-pipelines "deployment/${deployment}"
done
