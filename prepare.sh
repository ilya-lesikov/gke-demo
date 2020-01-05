#!/bin/bash
set -euo pipefail

project="$1"
# region="$2"
# zone="$3"

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
  paymentservice
  productcatalogservice
  recommendationservice
  shippingservice
)

info() {
  echo "[[ INFO ]] $1"
}

if (gcloud projects describe -q --verbosity=none "$project"); then
  info "Project already exists, skipping creation"
else
  info "Creating GCP project"
  gcloud projects create -q "$project"
fi

info "Attaching billing account to the project"
billing_id="$(gcloud beta billing accounts list | awk 'NR == 2 {print $1}')"
gcloud beta billing projects link -q "$project" --billing-account "$billing_id"

if (gsutil ls -b "gs://${project}_terraform-state/"); then
  info "Cloud Storage bucket for Terraform state already exists, skipping creation"
else
  info "Creating Cloud Storage bucket for Terraform state"
  gsutil mb -l eu "gs://${project}_terraform-state"
  gsutil versioning set on "gs://${project}_terraform-state"
fi

if [[ ! -f "./bin/terraform" ]]; then
  info "Downloading Terraform"
  cd ./bin
  wget -O terraform.zip "https://releases.hashicorp.com/terraform/$TERRAFORM_VER/terraform_${TERRAFORM_VER}_linux_amd64.zip"
  unzip terraform.zip
  chmod +x terraform
  rm terraform.zip
  cd -
fi

if [[ ! -f "./bin/terragrunt" ]]; then
  info "Downloading Terragrunt"
  cd ./bin/
  wget -O terragrunt "https://github.com/gruntwork-io/terragrunt/releases/download/v$TERRAGRUNT_VER/terragrunt_linux_amd64"
  chmod +x terragrunt
  cd -
fi

if [[ ! -f "./bin/kustomize" ]]; then
  info "Downloading Kustomize"
  cd ./bin/
  curl -sSL --output - "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv$KUSTOMIZE_VER/kustomize_v${KUSTOMIZE_VER}_linux_amd64.tar.gz" | tar xz
  chmod +x kustomize
  cd -
fi

info "Kustomizing image tags in k8s manifests"
cd ./kubernetes/
for microservice in "${MICROSERVICES[@]}"; do
  ../bin/kustomize edit set image "$microservice=gcr.io/$project/$microservice"
done
cd -

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
gcloud config set -q project $project
# gcloud config set -q compute/region $region
# gcloud config set -q compute/zone $zone
