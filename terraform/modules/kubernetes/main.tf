terraform {
  backend "gcs" {}
}

locals {
  timestamp = timestamp()
}

# TODO: Context from k8s provider configuration not respected. Wait until fixed
# upstream (if ever) and remove this resource. "depends_on" with this resource has
# to be added to every k8s provider-dependent resource
# resource "null_resource" "use-context" {
#   provisioner "local-exec" {
#     command = <<SCRIPT
#       kubectl config use-context "gke_${var.project_id}_${var.zones[0]}_${var.cluster}"
#     SCRIPT
#   }
#   triggers = {
#     every_time = local.timestamp
#   }
# }

resource "kubernetes_namespace" "current" {
  metadata {
    name = var.namespace
    # labels = {
    #   istio-injection = "enabled"
    # }
  }
  # depends_on = [null_resource.use-context]
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
    # labels = {
    #   istio-injection = "enabled"
    # }
  }
  # depends_on = [null_resource.use-context]
  count = var.argo_install ? 1 : 0
}

# data "local_file" "argocd" {
#     filename = "${path.module}/argocd-install.yml"
# }

data "http" "argocd-install-manifests" {
  url = "https://raw.githubusercontent.com/argoproj/argo-cd/v${var.argocd_ver}/manifests/install.yaml"
  count = var.argo_install ? 1 : 0
}

resource "k8s_manifest" "argocd" {
  # Don't even ask wtf is this. We need it this way to reference variables from
  # resources with possible "count = 0", i.e. resources that might not exist
  for_each = length(data.http.argocd-install-manifests.*.body) > 0 ? toset(split("---", join("", data.http.argocd-install-manifests.*.body))) : toset([])
  content   = each.key

  namespace = element(concat(kubernetes_namespace.argocd.*.id, list("")), 0)
}

resource "kubernetes_namespace" "argo-rollouts" {
  metadata {
    name = "argo-rollouts"
    # labels = {
    #   istio-injection = "enabled"
    # }
  }
  # depends_on = [null_resource.use-context]
  count = var.argo_install ? 1 : 0
}

# data "local_file" "argo-rollouts" {
#     filename = "${path.module}/argo-rollouts-install.yml"
# }

data "http" "argo-rollouts-install-manifests" {
  url = "https://raw.githubusercontent.com/argoproj/argo-rollouts/v${var.argo_rollouts_ver}/manifests/install.yaml"
  count = var.argo_install ? 1 : 0
}

resource "k8s_manifest" "argo-rollouts" {
  for_each = length(data.http.argo-rollouts-install-manifests.*.body) > 0 ? toset(split("---", join("", data.http.argo-rollouts-install-manifests.*.body))) : toset([])
  content   = each.key

  namespace = element(concat(kubernetes_namespace.argo-rollouts.*.id, list("")), 0)
}
