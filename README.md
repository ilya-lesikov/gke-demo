>Complete cloud automation and CI/CD for microservices, done with GCP/GKE

## Features

* Multistage deployments (staging, prod)
* Canary deployments
* Horizontal pod/instance autoscaling
* Rollbacks, self-healing
* Distributed tracing, monitoring, logging, profiling, debugging

Setup/deployment is heavily automated so it will be easy for you to deploy it by yourself using [GCP account with Free Trial](https://cloud.google.com/free)

## Software used

|                                                                     | |
|---------------------------------------------------------------------|-------------------------------------------------------|
| `Terraform, Terragrunt`                                             | Cloud automation                                      |
| `Kubernetes (GKE), Kustomize`                                       | Container orchestration                               |
| `Google Cloud Build`                                                | CI                                                    |
| `ArgoCD, Argo Rollouts`                                             | CD                                                    |
| `Google Stackdriver`                                                | Monitoring, logging, tracing,<br>profiling, debugging |
| `Cloud KMS, Container Registry,`<br>`Storage and other GCP goodies` |                                                       |

Also we are using [10 microservices from Google](./third-party/microservices) with built-in instrumentation for `Stackdriver`

## Quick start

1. You need [GCP account with Free Trial](https://cloud.google.com/free) activated
1. You need [GitHub account](https://github.com/join)
1. Fork this repo (we can't setup `GCB` triggers for repositories you don't own)
1. You need `Docker` installed (any OS)

1. Run and attach to the docker container:
  ```bash
  # Change this to the owner of the forked "gke-demo" repo, don't leave it like this
  GITHUB_USERNAME=ilya-lesikov

  # Run container with all the tooling we need:
  # NOTE: you can change "TF_VAR_project_id" in this command to point to the existing GCP project
  docker run -d --name gke-demo \
    -e TF_VAR_project_id=gke-demo-$GITHUB_USERNAME \
    -e TF_VAR_github_demo_owner=$GITHUB_USERNAME \
    ilyalesikov/gke-demo

  # Attach to the container
  docker exec -it gke-demo bash
  ```

1. Prepare for cloud provisioning (this is run from the inside of the container):
  ```bash
  # Clone the repo you forked
  git clone https://github.com/${TF_VAR_github_demo_owner}/gke-demo

  # Run this and follow the instructions on your screen.
  # This will authorize us to access your GCP account and the "gke-demo" repo you forked.
  ./gke-demo/scripts/prepare.sh && source /root/.bashrc
  ```

1. Provision our cloud infrastructure with Terraform/Terragrunt:
  > On any transient errors (e.g. SSL/TLS errors or `remote server closed connection`) just rerun the `terragrunt` command. `Terragrunt` handles _most_ of these automatically, but `Terraform` sucks so much it'll need 10 wrappers to be truly reliable
  ```bash
  cd gke-demo/terraform/environments
  terragrunt apply-all --terragrunt-include-external-dependencies --terragrunt-non-interactive
  ```

1. Build and deploy **all** of our applications:
  ```bash
  git tag -d release_all
  git push --delete origin release_all
  git tag release_all
  git push origin release_all   # This will trigger our CI/CD
  ```

1. Wait for the build to complete here: https://console.cloud.google.com/cloud-build/builds

1. Works now!

## Looking around

First, switch to our production cluster:
```bash
kubectl config use-context "gke_${TF_VAR_project_id}_europe-west2-a_cluster-demo-prod"
```

Check if our app is synced and healthy:
```bash
argocd app get hipstershop-prod
```

List our canary rollouts:
```bash
kubectl argo rollouts list rollouts
```

Check out details for some particular rollout/microservice:
```bash
kubectl argo rollouts get rollout adservice
```

We even have a neat web-interface to manage our applications lifecycle, do rollbacks, etc:
```bash
IP="$(argocd context | awk 'NR==2 {print $3}')"
PASS="$(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f2)"
printf '\nThe web-interface is here: https://%s, username is "admin", password is "%s"\n\n' "$IP" "$PASS"
```

And here is the application itself:
```bash
IP="$(kubectl get service frontend-external | awk 'NR==2 {print $4}')"
printf '\nApplication is here: http://%s\n\n' "$IP"
```

TODO: explain about Stackdriver capabilites and maybe showcase updating the app
source code with broken and non-broken functionality. Images can help in "Poking
around" section for sure.
