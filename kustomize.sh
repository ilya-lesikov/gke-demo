#!/bin/bash -e

IMAGE_PREFIX=gcr.io/gke-demo-548855/
SERVICES=(
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

for service in "${SERVICES[@]}"; do
  kustomize edit set image "$service=${IMAGE_PREFIX}$service"
done
