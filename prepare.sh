#!/bin/bash
set -euo pipefail

PROJECT="$1"
# TERRAFORM_SA=serviceAccount:924997815781-compute@developer.gserviceaccount.com
# CLOUDBUILD_SA=serviceAccount:924997815781@cloudbuild.gserviceaccount.com

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

# TERRAFORM_SA_ROLES=(
#   roles/compute.viewer
#   roles/container.clusterAdmin
#   roles/container.developer
#   roles/iam.serviceAccountAdmin
#   # roles/iam.serviceAccountUser
#   roles/resourcemanager.projectIamAdmin
#   roles/compute.networkAdmin
#   roles/iam.securityAdmin   # ability to make itself member of a role
#   roles/billing.projectManager    # attach billing account to the project
# )

# CLOUDBUILD_SA_ROLES=(
#   roles/container.developer   # push containers to registry
# )

# SERVICES=(
#   compute.googleapis.com
#   container.googleapis.com
#   cloudresourcemanager.googleapis.com
#   containerregistry.googleapis.com
#   cloudbuild.googleapis.com
# )

info() {
  echo "[[ INFO ]] $1"
}

info "Creating GCP project"
if (gcloud projects describe -q --verbosity=none "$PROJECT"); then
  echo "Project already exists, skipping creation."
else
  gcloud projects create -q "$PROJECT"
fi

info "Attaching billing account to the project"
billing_id="$(gcloud beta billing accounts list | awk 'NR == 2 {print $1}')"
gcloud beta billing projects link -q "$PROJECT" --billing-account "$billing_id"

# # Activate required services for the project
# for service in "${SERVICES[@]}"; do
#   gcloud services enable $service --project "$PROJECT"
# done

# # Give required permissions to Terraform service account
# for role in "${TERRAFORM_SA_ROLES[@]}"; do
#   gcloud projects add-iam-policy-binding "$PROJECT" \
#     --member "$TERRAFORM_SA" --role="$role"
# done

# # Give required permissions to Cloud Build service account
# for role in "${CLOUDBUILD_SA_ROLES[@]}"; do
#   gcloud projects add-iam-policy-binding "$PROJECT" \
#     --member "$CLOUDBUILD_SA" --role="$role"
# done

info "Downloading Kustomize"
if [[ ! -f "./third-party/kustomize" ]]; then
  curl -sSL --output - "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv3.5.3/kustomize_v3.5.3_linux_amd64.tar.gz" | tar xz
  mv -v kustomize ./third-party/
fi

info "Kustomizing image tags in k8s manifests"
for microservice in "${MICROSERVICES[@]}"; do
  ./third-party/kustomize edit set image "$microservice=gcr.io/$PROJECT/$microservice"
done
