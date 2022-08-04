#!/bin/sh
# Adds a spoke 'cluster' object to hub argocd instance

HUB_ARGO_SERVER="$1"
HUB_ARGO_NAMESPACE="$2"
HUB_KUBECONFIG="$3"
SPOKE_KUBECONFIG="$4"

ADMIN_USER="admin"

export KUBECONFIG="$HUB_KUBECONFIG"

HUB_ARGO_ADMIN_PASS=$(oc get secret $HUB_ARGO_NAMESPACE-cluster -n $HUB_ARGO_NAMESPACE -o=jsonpath='{ .data.admin\.password }' | base64 -d)

# Login to hub argocd instance
argocd login ${HUB_ARGO_SERVER} --username ${ADMIN_USER} --password ${HUB_ARGO_ADMIN_PASS} --insecure

# Switch kube client contents to spoke cluster
export KUBECONFIG="$SPOKE_KUBECONFIG"

# Adds the spoke admin credential to the Hub
argocd cluster add admin --insecure