terraform {
  source = "../../../..//modules/gcp/k8s-cluster/"
}

include {
  path = find_in_parent_folders()
}

dependency "gcp-project" {
  config_path = "../../../common/gcp/project"
}

inputs = {
  environment              = "prod"
  master_cidr              = "172.16.0.0/28"
  subnet_primary_ip_range  = "172.20.0.0/20"
  subnet_services_ip_range = "172.20.16.0/20"
  subnet_pods_ip_range     = "10.8.0.0/14"
  region                   = "us-central1"
  zones                    = ["us-central1-a"]
  machine_type             = "n1-standard-2"
  max_nodes                = 3
  terraform_sa_fqdn        = dependency.gcp-project.outputs.terraform_sa_fqdn
}
