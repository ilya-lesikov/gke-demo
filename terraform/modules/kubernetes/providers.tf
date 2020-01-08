provider "kubernetes" {
  config_context = local.context
}

provider "kubernetes" {
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
