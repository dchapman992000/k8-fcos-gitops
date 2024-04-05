#!/bin/sh

kubectl version >/dev/null 2>&1

if [ $? -ne 0 ] 
then 
  export KUBECONFIG=/etc/kubernetes/admin.conf
  echo "Exporting KUBECONFIG - $KUBECONFIG" 
fi

FLUX_SYSTEM_DIR="./clusters/cluster3/flux-system"

echo "Applying gotk-components"
kubectl apply -f $FLUX_SYSTEM_DIR/gotk-components.yaml

echo "Sleeping 5 seconds"
sleep 5

echo "Applying gotk-sync"
kubectl apply -f $FLUX_SYSTEM_DIR/gotk-sync.yaml
