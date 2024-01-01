#!/bin/sh

export KUBECONFIG=/etc/kubernetes/admin.conf
FLUX_SYSTEM_DIR="./clusters/cluster2/flux-system"

echo "Applying gotk-components"
kubectl apply -f $FLUX_SYSTEM_DIR/gotk-components.yaml

echo "Sleeping 5 seconds"
sleep 5

echo "Applying gotk-sync"
kubectl apply -f $FLUX_SYSTEM_DIR/gotk-sync.yaml