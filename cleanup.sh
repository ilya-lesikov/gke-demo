#!/bin/bash
set -u

project="$1"

gcloud -q iam service-accounts delete terraform@$project.iam.gserviceaccount.com
gcloud -q compute routers delete main

for environ in prod staging; do
  gcloud -q container clusters delete cluster-demo-$environ
  gcloud -q compute networks subnets delete subnet-demo-$environ
  gcloud -q compute networks delete net-demo-$environ
done

find -name ".terragrunt-cache" -exec rm -rf '{}' \;
