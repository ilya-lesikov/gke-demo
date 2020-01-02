terraform {
  source = "../../../..//modules/gcp/k8s-cluster/"
}

dependency "gcp-project" {
  config_path = "../../../common/gcp/project"
}

inputs = {
  terraform_sa_fqdn = dependency.gcp-project.outputs.terraform_sa_fqdn
  environment = "prod"
}
