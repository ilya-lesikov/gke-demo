terraform {
  source = "../../..//modules/kubernetes/"
}

dependency "cluster" {
  config_path = "../gcp/cluster"
  skip_outputs = true
}

# inputs = {
#   cluster = dependency.cluster.outputs.cluster
#   cluster_ca_certificate = dependency.cluster.outputs.cluster_ca_certificate
# }
