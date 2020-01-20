>Complete cloud automation and CI/CD, done with GCP/GKE

## Features

* Multistage deployments (staging, prod)
* Canary deployments
* Horizontal pod/instance autoscaling
* Rollbacks, self-healing
* Distributed tracing, monitoring, logging, profiling, debugging

Setup/deployment is heavily automated so it will be easy for you to deploy it yourself using [GCP account with Free Trial](https://cloud.google.com/free).

## Software used

* Cloud automation: `Terraform` + `Terragrunt`
* Container orchestration: `Kubernetes` (`GKE`) + `Kustomize`
* CI: `Google Cloud Build`
* CD: `ArgoCD` + `Argo Rollouts`
* Monitoring, logging, tracing, profiling, debugging: `Google Stackdriver`
* `Cloud KMS`, `Cloud Container Registry` and other `GCP` goodies


* Example applications: [10 microservices from Google](./third-party/microservices)

## Quick start

1. You need [GCP account with Free Trial](https://cloud.google.com/free) activated
1. You need [GitHub account](https://github.com/join)
1. Fork this repo (we can't setup `GCB` triggers for repositories you don't own)

Then prepare for cloud provisioning:
```bash
# Change this to the owner of the forked "gke-demo" repo, don't leave it like that
export GITHUB_USERNAME=ilya-lesikov

# NOTE: you can change "TF_VAR_project_id" in this command to point to the
# existing project...
# Run container with all the tooling we need:
docker run -d --name gke-demo \
  -e TF_VAR_project_id=gke-demo-$GITHUB_USERNAME \
  -e TF_VAR_github_demo_owner=$GITHUB_USERNAME \
  ilyalesikov/gke-demo

# Attach to the container
docker exec -it gke-demo bash

# Clone the repo you forked (run this inside container)
git clone https://github.com/${TF_VAR_github_demo_owner}/gke-demo

# Run this script and follow the instructions on your screen.
# This will authorize us to access your GCP account and the "gke-demo" repo you forked.
# Unfortunately, this can't be automated in a sane way.
./gke-demo/scripts/prepare.sh
```

Provision our cloud infrastructure with Terraform/Terragrunt:
```bash
cd gke-demo/terraform/environments
terragrunt apply-all --terragrunt-include-external-dependencies --terragrunt-non-interactive
```

Build and deploy **all** of our applications:
```bash
git tag release_all         # This tag will trigger our CI/CD
git push origin release_all
```

Wait for the build to complete here:
https://console.cloud.google.com/cloud-build/builds

## Poking around

First switch to our production cluster:
```bash
kubectl config use-context "gke_${TF_VAR_project_id}_europe-west2-a_cluster-demo-prod"
```

Check if our app is synced and healthy:
```bash
argocd app get hipstershop-prod
```

List all of our canary rollouts:
```bash
kubectl argo rollouts list rollouts
```

Check out details of some particular rollout/microservice:
```bash
kubectl argo rollouts get rollout adservice
```

We even have neat web-interface to manage our applications lifecycle, do rollbacks, etc:
```bash
IP="$(argocd context | awk 'NR==2 {print $3}')"
PASS="$(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f2)"
printf '\nThe web-interface is here: https://%s, username is "admin", password is "%s"\n\n' "$IP" "$PASS"
```

And, of course, the application itself:
```bash
IP="$(kubectl get service frontend-external | awk 'NR==2 {print $4}')"
printf '\nApplication is here: http://%s\n\n' "$IP"
```

TODO: explain about Stackdriver capabilites and maybe showcase updating the app
source code with broken and non-broken functionality. Images can help in "Poking
around" section for sure.
