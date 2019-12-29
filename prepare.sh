#!/bin/bash
set -euo pipefail

PROJECT="$1"
REGION="$2"
TERRAFORM_VER=0.12.18
TERRAGRUNT_VER=0.21.10
KUSTOMIZE_VER=3.5.3

MICROSERVICES=(
  adservice
  cartservice
  checkoutservice
  currencyservice
  emailservice
  frontend
  loadgenerator
  paymentservice
  productcatalogservice
  recommendationservice
  shippingservice
)

info() {
  echo "[[ INFO ]] $1"
}

if (gcloud projects describe -q --verbosity=none "$PROJECT"); then
  info "Project already exists, skipping creation"
else
  info "Creating GCP project"
  gcloud projects create -q "$PROJECT"
fi

info "Attaching billing account to the project"
billing_id="$(gcloud beta billing accounts list | awk 'NR == 2 {print $1}')"
gcloud beta billing projects link -q "$PROJECT" --billing-account "$billing_id"

if [[ ! -f "./third-party/terraform" ]]; then
  info "Downloading Terraform"
  cd ./third-party
  wget -O terraform.zip "https://releases.hashicorp.com/terraform/$TERRAFORM_VER/terraform_${TERRAFORM_VER}_linux_amd64.zip"
  unzip terraform.zip
  rm terraform.zip
  cd -
fi

if [[ ! -f "./third-party/terragrunt" ]]; then
  info "Downloading Terragrunt"
  cd ./third-party/
  wget -O terragrunt https://github.com/gruntwork-io/terragrunt/releases/download/v$TERRAGRUNT_VER/terragrunt_linux_amd64
  cd -
fi

if [[ ! -f "./third-party/kustomize" ]]; then
  info "Downloading Kustomize"
  cd ./third-party/
  curl -sSL --output - "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv$KUSTOMIZE_VER/kustomize_v${KUSTOMIZE_VER}_linux_amd64.tar.gz" | tar xz
  cd -
fi

info "Kustomizing image tags in k8s manifests"
for microservice in "${MICROSERVICES[@]}"; do
  ./third-party/kustomize edit set image \
    "$microservice=gcr.io/$PROJECT/$microservice"
done

# FIXME: uncomment
# info "Setting up \$GOOGLE_CLOUD_KEYFILE_JSON environment variable"
# export GOOGLE_CLOUD_KEYFILE_JSON="$HOME/.config/gcloud/application_default_credentials.json"
# for profile in "$HOME/.profile" "$HOME/.bash_profile" "$HOME/.zprofile"; do
#   sed -i '/GOOGLE_CLOUD_KEYFILE_JSON=/d' "$profile"
#   printf "export GOOGLE_CLOUD_KEYFILE_JSON=\"$GOOGLE_CLOUD_KEYFILE_JSON\"\n" \
#     >> "$profile"
# done

if [[ ! -f "$GOOGLE_CLOUD_KEYFILE_JSON" ]]; then
  info "Setting up application-default service account for GCP"
  gcloud auth application-default login --no-launch-browser
fi

info "Setting up gcloud configuration"
gcloud config set -q project $PROJECT
gcloud config set -q compute/region $2
gcloud config set -q compute/zone $2
