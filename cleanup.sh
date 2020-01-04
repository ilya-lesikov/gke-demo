#!/bin/bash
set -u

project="$1"

gcloud -q iam service-accounts delete terraform@$project.iam.gserviceaccount.com

for environ in prod staging; do
  gcloud -q compute routers delete $environ
  gcloud -q container clusters delete cluster-demo-$environ
  gcloud -q compute networks subnets delete demo-$environ
  gcloud -q compute networks delete demo-$environ
done

find -name ".terragrunt-cache" -exec rm -rf '{}' \;
