#!/bin/bash -e

PROJECT=gke-demo-548855
BILLING_ID=013623-CC1414-7E748C
# TERRAFORM_SA=serviceAccount:924997815781-compute@developer.gserviceaccount.com
# CLOUDBUILD_SA=serviceAccount:924997815781@cloudbuild.gserviceaccount.com

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

# Create GCP project
set +e
out=$(gcloud projects create "$PROJECT" 2>&1)
ec=$?
set -e
if [[ "$out" == *"project ID you specified is already in use"* ]]; then
  echo "Project already exists, skipping creation."
elif [[ $ec -ne 0 ]]; then
  echo "Aborting, unexpected error occured: $out"
  exit 1
else
  echo "$out"
fi

# Attach billing account to the project
gcloud beta billing projects link "$PROJECT" --billing-account "$BILLING_ID"

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

# Download Kustomize
if [[ ! -f "./third-party/kustomize" ]]; then
  curl -sSL --output - "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv3.5.3/kustomize_v3.5.3_linux_amd64.tar.gz" | tar xz
  mv -v kustomize ./third-party/
fi
