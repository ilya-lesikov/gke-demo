#!/bin/bash
set -euo pipefail

info() {
  echo "[[ INFO ]] $1"
}

abort() {
  echo "[[ ERROR ]] $1"
  exit 1
}

set +u
if [[ -z "$TF_VAR_project_id" ]]; then
  abort '$TF_VAR_project_id environment variable must be set. Aborting.'
fi
set -u

if (gcloud -q auth print-access-token 2>&1 1>/dev/null); then
  info "You are already authenticated in gcloud, skipping authenication"
else
  info "Authenticating in GCP with gcloud"
  echo
  echo "[Security notice] Here we are authenticating you in your GCP account"
  echo "for you to be able to use \"gcloud\" command:"
  echo
  gcloud -q auth login
fi

info "Setting up \$GOOGLE_CLOUD_KEYFILE_JSON environment variable"
export GOOGLE_CLOUD_KEYFILE_JSON="$HOME/.config/gcloud/application_default_credentials.json"
if ! (grep "GOOGLE_CLOUD_KEYFILE_JSON" "$HOME/.profile" 2>&1 1>/dev/null); then
  echo "export GOOGLE_CLOUD_KEYFILE_JSON=\"$GOOGLE_CLOUD_KEYFILE_JSON\"" >> "$HOME/.profile"
fi

if [[ ! -f "$GOOGLE_CLOUD_KEYFILE_JSON" ]]; then
  info "Setting up application-default service account for GCP"
  echo
  echo "[Security notice] And here we are getting your application-default"
  echo "key to access your GCP account with any program/SDK that is not"
  echo "\"gcloud\" command line utility:"
  echo
  gcloud auth application-default login --no-launch-browser
fi

if (gcloud projects describe -q --verbosity=none "$TF_VAR_project_id" 2>&1 1>/dev/null); then
  info "Project already exists, skipping creation"
else
  info "Creating GCP project"
  gcloud projects create -q "$TF_VAR_project_id"
fi
gcloud config set -q project "$TF_VAR_project_id"

info "Attaching billing account to the project"
billing_id="$(gcloud beta billing accounts list | awk 'NR == 2 {print $1}')"
gcloud beta billing projects link -q "$TF_VAR_project_id" --billing-account "$billing_id"

if (gsutil ls -b "gs://${TF_VAR_project_id}_terraform-state/" 2>&1 1>/dev/null); then
  info "Cloud Storage bucket for Terraform state already exists, skipping creation"
else
  info "Creating Cloud Storage bucket for Terraform state"
  gsutil mb -l eu "gs://${TF_VAR_project_id}_terraform-state"
  gsutil versioning set on "gs://${TF_VAR_project_id}_terraform-state"
fi

if [[ -f "$HOME/.ssh/id_rsa" ]]; then
  info "SSH key already exists, skipping"
else
  info "Creating new SSH key"
  ssh-keygen -N '' -t rsa -b 4096 -f "$HOME/.ssh/id_rsa"
fi

echo "[[ USER ACTION REQUIRED ]]"
echo
echo "Go to https://github.com/\${YOUR_GITHUB_USERNAME}/gke-demo/settings/keys/new,"
echo "check \"Allow write access\" and put this public key in \"Key\" textbox:"
echo
echo "$(cat $HOME/.ssh/id_rsa.pub)"
echo
echo "If you already added this key as a Deploy key, just ignore this."
echo "[Security note] Adding this key as \"Deploy key\" will only give"
echo "write/read access to this particular repo. We will use this in"
echo "Google Cloud Build to Kustomize, commit and push apps manifests."
echo
echo "[[ USER ACTION REQUIRED (see above)]]"
