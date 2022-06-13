#  Argocd Login Script

## Install

RHEL7 install steps

~~~
$ sudo yum install rh-python36

$ scl enable rh-python36 bash
$ pip install urllib3 --user --proxy <web proxy url if needed> 
$ pip install requests --user --proxy <web proxy url if needed>
~~~

## Usage

usage:

Get argocd session token

~~~
$ export token=$(python3 argocd-login.py -u <LDAP user name> -a <OpenShift GitOps Server URL>)
<enter LDAP Password When Prompted>
~~~

Perform argo cd operations as user with session token usint `--auth-token <token>`
For example create an application:

~~~
$  argocd app create <appname> -f path/to/application-manifest.yaml --auth-token "$token" --server <openshift gitops server> --insecure
~~~
