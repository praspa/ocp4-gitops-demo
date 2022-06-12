=== Argocd Login Script

usage:

Get argocd session token

~~~
export token=$(python3 argocd-login.py -u <LDAP user name> -a <OpenShift GitOps Server URL>)
<enter LDAP Password When Prompted>
~~~

Perform argo cd operations as user with session token usint `--auth-token <token>`
For example create an application:

~~~
$  argocd app create <appname> -f path/to/application-manifest.yaml --auth-token "$token" --server <openshift gitops server> --insecure
~~~
