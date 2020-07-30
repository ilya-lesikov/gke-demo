terraform {
  source = "../../..//modules/kubernetes/"
}

include {
  path = find_in_parent_folders()
}

dependency "gcp-k8s-cluster" {
  config_path = "../gcp/k8s-cluster"
}

inputs = {
  environment           = "prod"
  region                = dependency.gcp-k8s-cluster.outputs.region
  zones                 = dependency.gcp-k8s-cluster.outputs.zones
  cluster               = dependency.gcp-k8s-cluster.outputs.cluster
  endpoint              = dependency.gcp-k8s-cluster.outputs.endpoint
  argocd_install        = true
  argo_rollouts_install = true
}
