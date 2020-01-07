provider "kubernetes" {
  config_context = local.context
}

# https://github.com/banzaicloud/terraform-provider-k8s
provider "k8s" {
  kubeconfig_context = local.context
}
