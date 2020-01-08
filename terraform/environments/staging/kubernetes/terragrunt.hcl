terraform {
  source = "../../..//modules/kubernetes/"
}

include {
  path = find_in_parent_folders()
}

dependency "gcp-k8s-cluster" {
  config_path = "../gcp/k8s-cluster"
}

dependency "kubernetes-prod" {
  config_path = "../../prod/kubernetes"
}

inputs = {
  environment = "staging"
  region = dependency.gcp-k8s-cluster.outputs.region
  zones = dependency.gcp-k8s-cluster.outputs.zones
  cluster = dependency.gcp-k8s-cluster.outputs.cluster
  endpoint = dependency.gcp-k8s-cluster.outputs.endpoint
  management_context = dependency.kubernetes-prod.outputs.context
  argo_rollouts_install = true
  argocd_manager_install = true
}
