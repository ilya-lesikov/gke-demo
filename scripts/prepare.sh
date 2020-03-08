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

keyfile="$HOME/.config/gcloud/application_default_credentials.json"
for var in GOOGLE_CLOUD_KEYFILE_JSON GOOGLE_APPLICATION_CREDENTIALS; do
  for file in "$HOME/.profile" "$HOME/.bashrc"; do
    if ! (grep "$var" "$file" 2>&1 1>/dev/null); then
      info "Adding \$$var environment variable to $file"
      echo "export $var=\"$keyfile\"" >> "$file"
    fi
  done
done

if [[ ! -f "$keyfile" ]]; then
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
billing_id="$(gcloud beta billing accounts list --filter=open=true | awk 'NR == 2 {print $1}')"
gcloud -q --verbosity=error beta billing projects link \
  "$TF_VAR_project_id" --billing-account "$billing_id"

if [[ -f "$HOME/.ssh/id_rsa" ]]; then
  info "SSH key already exists, skipping"
else
  info "Creating new SSH key"
  ssh-keygen -q -N '' -t rsa -b 4096 -f "$HOME/.ssh/id_rsa"
fi

if (gcloud -q services list | grep cloudkms.googleapis.com 1>/dev/null); then
  info "Cloud KMS API already enabled, skipping"
else
  info "Enabling Cloud KMS"
  gcloud -q --verbosity=error services enable "cloudkms.googleapis.com"
  sleep 60
fi

echo
echo "[[ USER ACTION REQUIRED ]]"
echo
echo "Go to"
echo "https://github.com/${TF_VAR_github_demo_owner}/gke-demo/settings/keys/new"
echo "then check \"Allow write access\" and put this public key in \"Key\" textbox:"
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
echo "Go to..."
echo "https://console.cloud.google.com/cloud-build/triggers/connect?project=$TF_VAR_project_id&provider=github_app"
echo "and follow instructions to install GoogleCloudBuild Github app."
echo "NOTE: Access required only to the forked \"gke-demo\" repository, we don't need"
echo "access to other repositories on your account."
echo
echo "After installing GCB Github App, connect \"gke-demo\" repo from the GCP"
echo "Web Console that we opened, but don't create Push Trigger for this repo,"
echo "just press \"Skip for now\" on \"Create a push trigger\" step. Triggers"
echo "will be set up by Terraform."
echo
read -p "[[ USER ACTION REQUIRED (see above)]]. Press ENTER afterwards "

echo
echo "DONE! Follow further instructions from the README"
echo
