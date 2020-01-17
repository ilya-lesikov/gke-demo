remote_state {
  backend = "gcs"
  config  = {
    bucket = "${get_env("TF_VAR_project_id", "")}_terraform-state"
    prefix = "${path_relative_to_include()}/"
  }
}

inputs = {
  project_id                               = "CHANGEME"
  github_demo_owner                        = "ilya-lesikov"
  github_demo_reponame                     = "gke-demo"
  argocd_ver                               = "1.3.6"
  argo_rollouts_ver                        = "0.6.2"
  hipstershop_namespace                    = "hipstershop"
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
