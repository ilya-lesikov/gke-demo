terraform {
  source = "../../../..//modules/gcp/project/"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  github_microservices_owner = "ilya-lesikov"
  github_microservices_reponame = "google-microservices-demo"
  github_community_cloud_builders_owner = "ilya-lesikov"
  github_community_cloud_builders_reponame = "google-cloud-builders-community"
  microservices = [
    "adservice",
    "cartservice",
    "checkoutservice",
    "currencyservice",
    "emailservice",
    "frontend",
    "paymentservice",
    "productcatalogservice",
    "recommendationservice",
    "shippingservice",
  ]
}
