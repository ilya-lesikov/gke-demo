terraform {
  source = "../../../..//modules/gcp/cluster/"
}

dependency "project" {
  config_path = "../project"
}

inputs = {
  terraform_sa_fqdn = dependency.project.outputs.terraform_sa_fqdn
}
