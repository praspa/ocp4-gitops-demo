#!/bin/sh

#PASS="$1"

PASS="EAyP49Z0Knm7Twh5DkHuMzXaoUdFWVxG"

argocd login openshift-gitops-server-openshift-gitops.apps.pwrocp4.lab.upshift.rdu2.redhat.com --username admin --password ${PASS} --insecure
