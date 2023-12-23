#!/bin/bash

flux create source git k8-fos-gitops \
    --url=https://https://github.com/dcatwoohoo/k8-fcos-gitops \
    --branch=main \
    --interval=3m \
    --export > ./clusters/cluster1/flux-system/gotk-sync.yaml

flux create kustomization k8-fos-gitops \
    --source=k8-fos-gitops \
    --path="./clusters/cluster1/" \
    --prune=true \
    --interval=5m \
    --export >> ./clusters/cluster1/flux-system/gotk-sync.yaml
