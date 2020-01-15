provider "kubernetes" {
  version = "= 1.10.0"
  config_context = local.context
}

provider "kubernetes" {
  version = "= 1.10.0"
  alias = "management-cluster"
  config_context = local.management_context
}

# https://github.com/banzaicloud/terraform-provider-k8s
provider "k8s" {
  kubeconfig_context = local.context
}

provider "k8s" {
  alias = "management-cluster"
  kubeconfig_context = local.management_context
}

provider "null" { version = "= 2.1.2"; }
provider "random" { version = "= 2.2.1"; }
provider "template" { version = "= 2.1.2"; }
provider "http" { version = "= 1.1.1"; }
