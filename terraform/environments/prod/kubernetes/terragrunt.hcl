terraform {
  source = "../../..//modules/kubernetes/"
}

dependency "gcp-k8s-cluster" {
  config_path = "../gcp/k8s-cluster"
  # skip_outputs = true
}

inputs = {
  project_id = dependency.gcp-k8s-cluster.outputs.project_id
  region = dependency.gcp-k8s-cluster.outputs.region
  cluster = dependency.gcp-k8s-cluster.outputs.cluster
  # cluster_ca_certificate = dependency.gcp-k8s-cluster.outputs.cluster_ca_certificate
}
