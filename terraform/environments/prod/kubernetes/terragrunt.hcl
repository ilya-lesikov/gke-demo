terraform {
  source = "../../..//modules/kubernetes/"
}

dependency "cluster" {
  config_path = "../gcp/cluster"
}

inputs = {
  namespace = "prod"
  cluster = dependency.cluster.outputs.cluster
  cluster_ca_certificate = dependency.cluster.outputs.cluster_ca_certificate
}
