resource "kubernetes_namespace" "argo-rollouts" {
  metadata {
    name = "argo-rollouts"
  }
  count = var.argo_rollouts_install ? 1 : 0
}

data "http" "argo-rollouts-install-manifests" {
  url   = "https://raw.githubusercontent.com/argoproj/argo-rollouts/v${var.argo_rollouts_ver}/manifests/install.yaml"
  count = var.argo_rollouts_install ? 1 : 0
}

resource "k8s_manifest" "argo-rollouts" {
  # fuck my life
  for_each  = length(data.http.argo-rollouts-install-manifests.*.body) > 0 ? zipmap(range(length(split("---", join("", data.http.argo-rollouts-install-manifests.*.body)))), split("---", join("", data.http.argo-rollouts-install-manifests.*.body))) : {}
  content   = each.value
  namespace = element(concat(kubernetes_namespace.argo-rollouts.*.id, list("")), 0)
}
