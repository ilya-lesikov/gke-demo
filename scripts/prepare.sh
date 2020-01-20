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

if (gcloud -q --verbosity=none auth print-access-token 2>&1 1>/dev/null); then
  info "You are already authenticated in gcloud, skipping authenication"
else
  info "Authenticating in GCP with gcloud"
  echo
  echo "[Security notice] Here we are authenticating you in your GCP account"
  echo "for you to be able to use \"gcloud\" command:"
  echo
  gcloud -q --verbosity=error auth login
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
  gcloud -q --verbosity=error auth application-default login --no-launch-browser
fi

if (gcloud projects describe -q --verbosity=none "$TF_VAR_project_id" 2>&1 1>/dev/null); then
  info "Project already exists, skipping creation"
else
  info "Creating GCP project"
  gcloud -q --verbosity=error projects create "$TF_VAR_project_id"
fi
gcloud -q --verbosity=error config set project "$TF_VAR_project_id"

info "Attaching billing account to the project"
billing_id="$(gcloud beta billing accounts list | awk 'NR == 2 {print $1}')"
gcloud -q --verbosity=error beta billing projects link \
  "$TF_VAR_project_id" --billing-account "$billing_id"

if (gsutil -q ls -b "gs://${TF_VAR_project_id}_terraform-state/" 2>&1 1>/dev/null); then
  info "Cloud Storage bucket for Terraform state already exists, skipping creation"
else
  info "Creating Cloud Storage bucket for Terraform state"
  # If we try to do something just after billing account attached sometimes we get
  # "The project to be billed is associated with an absent billing account" error.
  sleep 90
  gsutil -q mb -l eu "gs://${TF_VAR_project_id}_terraform-state"
  gsutil -q versioning set on "gs://${TF_VAR_project_id}_terraform-state"
fi

if [[ -f "$HOME/.ssh/id_rsa" ]]; then
  info "SSH key already exists, skipping"
else
  info "Creating new SSH key"
  ssh-keygen -q -N '' -t rsa -b 4096 -f "$HOME/.ssh/id_rsa"
fi

if (gcloud -q services list | grep cloudkms.googleapis.com); then
  info "Cloud KMS API already enabled, skipping"
else
  info "Enabling Cloud KMS"
  gcloud -q --verbosity=error services enable "cloudkms.googleapis.com"
  sleep 60
fi

echo
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
read -p "[[ USER ACTION REQUIRED (see above)]]. Press ENTER afterwards "

echo
echo "[[ USER ACTION REQUIRED ]]"
echo
echo "Go to https://console.cloud.google.com/cloud-build/triggers/connect?project=$TF_VAR_project_id&provider=github_app"
echo "and follow instructions to install GoogleCloudBuild Github app."
echo "Access required only to the forked \"gke-demo\" repository, we don't need"
echo "access to other repositories on your account."
echo "After installing GCB Github App, connect \"gke-demo\" repo from the GCP"
echo "Web Console that we opened, but don't create Push Trigger for this repo,"
echo "just press \"Skip for now\" on \"Create a push trigger\" step. Triggers"
echo "will be set up by Terraform."
echo
read -p "[[ USER ACTION REQUIRED (see above)]]. Press ENTER afterwards "

echo
echo "DONE!"
echo
