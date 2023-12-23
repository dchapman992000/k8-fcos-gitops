#!/bin/bash

flux install --export > ./clusters/cluster1/flux-system/gotk-components.yaml
# git add -A && git commit -m "Update $(flux -v) on my-cluster"

# git push
