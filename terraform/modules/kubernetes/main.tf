resource "kubernetes_namespace" "current" {
  metadata {
    name = var.namespace
    # labels = {
    #   istio-injection = "enabled"
    # }
  }
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
    # labels = {
    #   istio-injection = "enabled"
    # }
  }
}

# data "local_file" "argocd" {
#     filename = "${path.module}/argocd-install.yml"
# }

data "http" "argocd-install-manifests" {
  url = "https://raw.githubusercontent.com/argoproj/argo-cd/v${argocd_ver}/manifests/install.yaml"
}

resource "k8s_manifest" "argocd" {
  for_each = toset(split("---", data.http.argocd-install-manifests.body))
  content   = each.key

  namespace = kubernetes_namespace.argocd.id
}

resource "kubernetes_namespace" "argo-rollouts" {
  metadata {
    name = "argo-rollouts"
    # labels = {
    #   istio-injection = "enabled"
    # }
  }
}

# data "local_file" "argo-rollouts" {
#     filename = "${path.module}/argo-rollouts-install.yml"
# }

data "http" "argo-rollouts-install-manifests" {
  url = "https://raw.githubusercontent.com/argoproj/argo-rollouts/v${argo_rollouts_ver}/manifests/install.yaml"
}

resource "k8s_manifest" "argo-rollouts" {
  for_each = toset(split("---", data.http.argo-rollouts-install-manifests.body))
  content   = each.key

  namespace = kubernetes_namespace.argo-rollouts.id
}
