remote_state {
  backend = "gcs"
  config  = {
    location = "US"
    project = "${get_env("TF_VAR_project_id", "")}"
    bucket = "${get_env("TF_VAR_project_id", "")}_terraform-state"
    prefix = "${path_relative_to_include()}/"
  }
}

inputs = {
  project_id                               = "maestroio-development"
  github_demo_owner                        = "lessthan3"
  github_demo_reponame                     = "gke-demo"
  argocd_ver                               = "1.3.6"
  argo_rollouts_ver                        = "0.6.2"
  hipstershop_namespace                    = "maestro"
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

skip = true
