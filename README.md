# Ansible based OpenShift 4 playbooks

requirements install multiple ocp environments...
including infra nodes

## Prerequisites

Python3 and make.  

## Dependencies

kubernetes and openshift python modules. See `requirements.txt`.

## Install

$ export LOGITAG=${example}  

$ make  

## Manual install

$ oc login https://api.cluster.example.net:6443 --token=${token}

$ ansible-playbook site.yaml -v --extra-vars "logitag=${example}"

## Notes

* Any http_proxy configuration will have to be done manually, either for pip configuration or access to an internal registry.

The following env vars can be exported while testing the playbooks manually.  

```bash
K8S_AUTH_VERIFY_SSL=False
K8S_AUTH_API_KEY={{ openshift_token }}
K8S_AUTH_HOST={{ https://openshift_api_url:6443 }}
```
