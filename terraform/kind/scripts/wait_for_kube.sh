#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <kubeconfig> <context>" >&2
  exit 2
fi

KUBECONFIG_PATH="$1"
KUBE_CONTEXT="$2"
TIMEOUT=${WAIT_FOR_KUBE_TIMEOUT:-60}
SLEEP=${WAIT_FOR_KUBE_SLEEP:-2}

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl not found in PATH" >&2
  exit 3
fi

echo "Waiting for Kubernetes API at context '$KUBE_CONTEXT' (kubeconfig: $KUBECONFIG_PATH)"
# If kubeconfig path is inside the module, wait for the file to appear (kind writes it)
for i in $(seq 1 "$TIMEOUT"); do
  if [ -f "$KUBECONFIG_PATH" ]; then
    break
  fi
  echo "kubeconfig not present yet, waiting..." >&2
  sleep "$SLEEP"
done

if [ ! -f "$KUBECONFIG_PATH" ]; then
  echo "kubeconfig file did not appear: $KUBECONFIG_PATH" >&2
  exit 5
fi
for i in $(seq 1 "$TIMEOUT"); do
  if kubectl --kubeconfig="$KUBECONFIG_PATH" --context="$KUBE_CONTEXT" get --raw=/readyz >/dev/null 2>&1; then
    echo "Kubernetes API is ready"
    exit 0
  fi
  sleep "$SLEEP"
done

echo "Timed out waiting for Kubernetes API after $((TIMEOUT * SLEEP)) seconds" >&2
exit 4
