#!/bin/sh

REPO="git@github.com:praspa/ocp4-gitops-demo.git"
KEY_PATH="/home/praspant/.ssh/id_ed25519"

argocd repo add "${REPO}" --insecure-ignore-host-key --ssh-private-key-path "${KEY_PATH}" --insecure 

