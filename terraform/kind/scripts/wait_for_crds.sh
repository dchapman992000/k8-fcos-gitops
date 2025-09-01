#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <kubeconfig> <context> [timeout_seconds]" >&2
  exit 2
fi

KUBECONFIG="$1"
CONTEXT="$2"
TIMEOUT=${3:-60}
SLEEP=${WAIT_FOR_CRDS_SLEEP:-2}

CRDS=(
  "gitrepositories.source.toolkit.fluxcd.io"
  "kustomizations.kustomize.toolkit.fluxcd.io"
)

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl not found in PATH" >&2
  exit 3
fi

echo "Waiting for CRDs: ${CRDS[*]}"
for i in $(seq 1 "$TIMEOUT"); do
  ALL_OK=true
  for crd in "${CRDS[@]}"; do
    if ! kubectl --kubeconfig="$KUBECONFIG" --context="$CONTEXT" get crd "$crd" >/dev/null 2>&1; then
      ALL_OK=false
      break
    fi
  done
  if [ "$ALL_OK" = true ]; then
    echo "Required CRDs are present"
    exit 0
  fi
  sleep "$SLEEP"
done

echo "Timed out waiting for CRDs after $((TIMEOUT * SLEEP)) seconds" >&2
exit 4
