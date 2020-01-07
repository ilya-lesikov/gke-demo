terraform {
  source = "../../..//modules/kubernetes/"
}

include {
  path = find_in_parent_folders()
}

dependency "gcp-k8s-cluster" {
  config_path = "../gcp/k8s-cluster"
  # skip_outputs = true
}

inputs = {
  project_id = dependency.gcp-k8s-cluster.outputs.project_id
  region = dependency.gcp-k8s-cluster.outputs.region
  zones = dependency.gcp-k8s-cluster.outputs.zones
  cluster = dependency.gcp-k8s-cluster.outputs.cluster
  endpoint = dependency.gcp-k8s-cluster.outputs.endpoint
  argo_install = true
  # cluster_ca_certificate = dependency.gcp-k8s-cluster.outputs.cluster_ca_certificate
}
