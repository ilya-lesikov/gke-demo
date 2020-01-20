Automation of microservices lifecycle done with Google Cloud Platform and Google Kubernetes Engine.

Cloud automation: Terraform + Terragrunt
Container orchestration: GKE/Kubernetes
CI: Google Cloud Build
CD: ArgoCD + Argo Rollouts
Monitoring, logging, tracing: Stackdriver
Other GCP goodies (Cloud KMS, ...), Kustomize

Application: 10 microservices from Google

## Features

* End-to-end automated cloud provisioning and CI/CD
* Multistage deployments (staging, prod)
* Canary deployments
* Horizontal pod/instance autoscaling
* Rollbacks, self-healing
* Distributed tracing, monitoring, logging

## Quick start

* You need GCP account with Free Trial activated
* You need GitHub account
* Fork this repo (we can't setup GCB triggers for repositories you don't own)

```bash
# Run container with all the tooling we need.
# Change "TF_VAR_project_id" here if you don't like the GCP project name that
# will be used (gke-demo-XXXXXXXXX), or if you already have GCP project created
# for this demo.
docker run -d --name gke-demo \
  -e TF_VAR_project_id=gke-demo-$(date +'%s') \
  ilyalesikov/gke-demo

# Attach to the container
docker exec -it gke-demo bash

# Clone the repo you forked (run this inside container)
git clone https://github.com/$YOUR_GITHUB_USERNAME/gke-demo

# Run this script and follow the instructions on your screen.
# This will authorize us to access your GCP account and the "gke-demo" repo you forked.
# Unfortunately, this can't be automated in a sane way.
./gke-demo/scripts/prepare.sh

# Preparations done, now provision your cloud infrastructure with Terraform/Terragrunt
cd gke-demo/terraform/environments
terragrunt apply-all --terragrunt-include-external-dependencies --terragrunt-non-interactive
```
