#!/bin/bash -u

project="$1"
service_account="terraform@$project.iam.gserviceaccount.com"

gcloud -q iam service-accounts delete $service_account
gsutil iam ch -d serviceAccount:$service_account gs://artifacts.$project.appspot.com
gsutil -m rm -r gs://${project}_terraform-state

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

triggers=$(gcloud -q beta builds triggers list | awk '$0~/^id: / {print $2}' | tr '\n' ' ')
for trigger in $(printf $triggers); do
  gcloud -q beta builds triggers delete $trigger
done

find -name ".terragrunt-cache" -exec rm -rf '{}' \;

gcloud -q config unset compute/region
gcloud -q config unset compute/zone
gcloud -q config unset container/cluster
