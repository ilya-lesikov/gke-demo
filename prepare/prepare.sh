#!/bin/bash

gcloud projects create gke-demo-548855
gcloud beta billing projects link gke-demo-548855 --billing-account 013623-CC1414-7E748C
gcloud projects add-iam-policy-binding gke-demo-548855 --member "serviceAccount:924997815781-compute@developer.gserviceaccount.com" --role=roles/iam.securityAdmin
for service in compute.googleapis.com container.googleapis.com cloudresourcemanager.googleapis.com containerregistry.googleapis.com cloudbuild.googleapis.com; do
  gcloud services enable $service --project gke-demo-548855
done
