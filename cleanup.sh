#!/bin/bash

if [[ "${2}" != "iSuck" ]] || [[ "${1}" == "" ]]; then
  echo "You don't know wtf you are doing, why would you ever run a script with
a name \"cleanup\" that is not documented anywhere, when dealing with IaC? You
are lucky I'm so stupid and bored, this saved your GCloud from being ANNIHILATED"
  exit 1
fi

project="$1"
service_account="terraform@$project.iam.gserviceaccount.com"

gcloud -q iam service-accounts delete $service_account
gsutil iam ch -d serviceAccount:$service_account gs://artifacts.$project.appspot.com
gsutil -m rm -r gs://${project}_terraform-state

for fwrule in $(gcloud compute firewall-rules list \
  | awk '$2~/demo-(staging|prod)/ {print $1}'); do
  gcloud -q compute firewall-rules delete $fwrule
done

for environ in prod staging; do
  for region in europe-west4 europe-west2; do
    gcloud config set -q compute/region "$region"
    gcloud config set -q compute/zone "${region}-a"

    gcloud -q compute routers delete $environ
    gcloud -q container clusters delete cluster-demo-$environ
    gcloud -q compute networks subnets delete demo-$environ
    gcloud -q compute networks delete demo-$environ
  done
done

for trigger in $(gcloud -q beta builds triggers list | awk '$0~/^id: / {print $2}' | tr '\n' ' '); do
  gcloud -q beta builds triggers delete $trigger
done

find -name ".terragrunt-cache" -exec rm -rf '{}' \;

gcloud -q config unset compute/region
gcloud -q config unset compute/zone
gcloud -q config unset container/cluster
