#!/usr/bin/python3


import warnings
import urllib3
import requests
from urllib.parse import urlparse
import argparse
import getpass

parser = argparse.ArgumentParser(description='Tool to get argocd session token after logging into OCP IDP')
parser.add_argument('-u', action='store', dest='myusername', help='OCP username')
parser.add_argument('-a', action='store', dest='myhost', help='argo cd server')

results = parser.parse_args()

myhost = results.myhost
myusername = results.myusername
mypassword = getpass.getpass(prompt='password: ', stream=None)

def argocd_login(host, username, password):
    # temporarily disable ssl verification warnings
    with warnings.catch_warnings():
        urllib3.disable_warnings()
        # create session to keep cookies
        session = requests.session()
        # call initial login endpoint, will redirect to openshift oauth
        response = session.get("https://" + host + "/auth/login", allow_redirects=True, verify=False)
        # parse response to get openshift host
        parsed = urlparse(response.url)
        openshift_url = parsed.scheme + '://' + parsed.netloc
        # setup oauth and idp urls
        authorize_endpoint = '/oauth/authorize?' + parsed.query
        idp_url = openshift_url + "/login/ldapidp"
        # do an initial request to idp endpoint get to the idp endpoint to get the csrf cookie
        session.get(idp_url, allow_redirects=False, verify=False, params={
            'then': authorize_endpoint
        })
        # post csrf,username, and password to idp endpoint
        session.post(idp_url, data={
            'username': username,
            'password': password,
            'csrf': session.cookies['csrf'],
            'then': authorize_endpoint
        }, allow_redirects=True, verify=False)
        # return arocd.token from cookies
        return session.cookies['argocd.token']



mytoken = argocd_login(myhost, myusername, mypassword)

print(mytoken)
