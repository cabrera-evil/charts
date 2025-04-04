#!/usr/bin/env bash

set -euo pipefail

# -------------------------
# Config
# -------------------------
DEFAULT_NAMESPACE="production"
DEFAULT_RELEASE_NAME="deploy-chart"
DEFAULT_HELM_DIR="."
DEFAULT_VALUES_FILE="values.yaml"

# -------------------------
# Helper Functions
# -------------------------
function usage() {
    cat <<EOF
Usage: $(basename "$0") [command] [options]

Commands:
  install       Install the Helm chart
  upgrade       Upgrade the Helm release
  uninstall     Uninstall the Helm release
  logs          Tail logs from the release pod
  describe      Describe the main pod in the release
  status        Show status of Helm release
  help          Show this help message

Options:
  -n, --namespace    Kubernetes namespace (default: $DEFAULT_NAMESPACE)
  -r, --release      Helm release name (default: $DEFAULT_RELEASE_NAME)
  -d, --dir          Helm chart directory (default: $DEFAULT_HELM_DIR)
  -f, --values       Custom values file (default: $DEFAULT_VALUES_FILE)
  -s, --stage        Deployment stage (uses values.<stage>.yaml)

Examples:
  $0 install --stage dev
  $0 upgrade --values values.production.yaml
  $0 logs -r deploy-chart
EOF
}

function parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
        -n | --namespace)
            NAMESPACE="$2"
            shift
            ;;
        -r | --release)
            RELEASE_NAME="$2"
            shift
            ;;
        -d | --dir)
            HELM_DIR="$2"
            shift
            ;;
        -f | --values)
            VALUES_FILE="$2"
            shift
            ;;
        -s | --stage)
            STAGE="$2"
            shift
            ;;
        install | upgrade | uninstall | logs | describe | status | help)
            COMMAND="$1"
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage
            exit 1
            ;;
        esac
        shift
    done

    # Set defaults if not defined
    RELEASE_NAME="${RELEASE_NAME:-$DEFAULT_RELEASE_NAME}"
    NAMESPACE="${NAMESPACE:-$DEFAULT_NAMESPACE}"
    HELM_DIR="${HELM_DIR:-$DEFAULT_HELM_DIR}"

    if [[ -n "${STAGE:-}" ]]; then
        VALUES_FILE="values.${STAGE}.yaml"
    else
        VALUES_FILE="${VALUES_FILE:-$DEFAULT_VALUES_FILE}"
    fi
}

# -------------------------
# Command Implementations
# -------------------------
function helm_install() {
    helm install "$RELEASE_NAME" "$HELM_DIR" \
        --namespace "$NAMESPACE" \
        --create-namespace \
        -f "$VALUES_FILE" \
        --debug
}

function helm_upgrade() {
    helm upgrade --install "$RELEASE_NAME" "$HELM_DIR" \
        --namespace "$NAMESPACE" \
        --create-namespace \
        -f "$VALUES_FILE" \
        --debug
}

function helm_uninstall() {
    helm uninstall "$RELEASE_NAME" --namespace "$NAMESPACE"
}

function helm_logs() {
    POD=$(kubectl get pods -n "$NAMESPACE" -l "app.kubernetes.io/instance=$RELEASE_NAME" -o jsonpath="{.items[0].metadata.name}")
    kubectl logs -f -n "$NAMESPACE" "$POD"
}

function helm_describe() {
    POD=$(kubectl get pods -n "$NAMESPACE" -l "app.kubernetes.io/instance=$RELEASE_NAME" -o jsonpath="{.items[0].metadata.name}")
    kubectl describe pod "$POD" -n "$NAMESPACE"
}

function helm_status() {
    helm status "$RELEASE_NAME" -n "$NAMESPACE"
}

# -------------------------
# Main Execution
# -------------------------
COMMAND="${1:-help}"
shift || true
parse_args "$@"

case "$COMMAND" in
install) helm_install ;;
upgrade) helm_upgrade ;;
uninstall) helm_uninstall ;;
logs) helm_logs ;;
describe) helm_describe ;;
status) helm_status ;;
help | *) usage ;;
esac
