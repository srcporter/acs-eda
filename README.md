# acs-eda

Experiments with Event-driven ansible (EDA) triggered by ACS webhook notifications

Setup and usage:

1. Build the image and push to a suitable registry

`podman build -t quay.io/example/acs-eda:0.1 -f ./Dockerfile`
`podman push quay.io/example/acs-eda:0.1`

2. Modify the deployment YAML to use your image
3. Create a namespace and deploy acs-eda.yaml

`kubectl create ns eda`
`kubectl -n eda create -f acs-eda.yaml`

4. Create a secret with your kubeconfig

`kubectl -n eda create secret generic kubeconfig --from-file=kubeconfig=./kubeconfig`

5. Integrate the EDA webhook into ACS using the "generic webhook" integration

If the ACS-EDA deployment is in the same cluster as ACS Central, use the local endpoint http://edasvc.eda.svc:5000/endpoint

If the ACS-EDA deployment is in another cluster, use the route host from

`oc get route edaroute`

append `/endpoint` to the route host
