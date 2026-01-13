#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHARTS_DIR="${SCRIPT_DIR}/charts"
ENVIRONMENTS_DIR="${SCRIPT_DIR}/environments"

ENVIRONMENT="${1:-dev}"
NAMESPACE="${2:-demo-platform}"
RELEASE_NAME="${3:-platform}"

usage() {
    echo "Usage: $0 <environment> [namespace] [release-name]"
    echo ""
    echo "Environments: dev, staging, prod"
    echo ""
    echo "Examples:"
    echo "  $0 dev"
    echo "  $0 staging demo-staging"
    echo "  $0 prod demo-prod platform-prod"
    exit 1
}

if [[ ! -f "${ENVIRONMENTS_DIR}/values-${ENVIRONMENT}.yaml" ]]; then
    echo "Error: Environment '${ENVIRONMENT}' not found"
    usage
fi

echo "Deploying to environment: ${ENVIRONMENT}"
echo "Namespace: ${NAMESPACE}"
echo "Release name: ${RELEASE_NAME}"
echo ""

cd "${CHARTS_DIR}/platform"

echo "Updating Helm dependencies..."
helm dependency update

echo ""
echo "Running Helm upgrade/install..."
helm upgrade --install "${RELEASE_NAME}" . \
    --namespace "${NAMESPACE}" \
    --create-namespace \
    --values "${ENVIRONMENTS_DIR}/values-${ENVIRONMENT}.yaml" \
    --wait \
    --timeout 10m

echo ""
echo "Deployment complete!"
echo ""
echo "To check status:"
echo "  kubectl get pods -n ${NAMESPACE}"
echo "  kubectl get svc -n ${NAMESPACE}"
echo "  kubectl get ingress -n ${NAMESPACE}"
