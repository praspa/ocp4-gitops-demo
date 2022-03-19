#!/bin/sh

#PASS="$1"

ARGO_SERVER="openshift-gitops-server-openshift-gitops.apps.cluster-zgd5c.zgd5c.sandbox1350.opentlc.com"
ADMIN_USER="admin"
PASS=$(oc get secret openshift-gitops-cluster -n openshift-gitops -o=jsonpath='{ .data.admin\.password }' | base64 -d)

argocd login ${ARGO_SERVER} --username ${ADMIN_USER} --password ${PASS} --insecure
