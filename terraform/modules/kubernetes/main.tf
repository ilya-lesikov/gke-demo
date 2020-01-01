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

data "local_file" "argocd" {
    filename = "${path.module}/argocd-install.yml"
}

resource "k8s_manifest" "argocd" {
  for_each = toset(split("---", data.local_file.argocd.content))
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

data "local_file" "argo-rollouts" {
    filename = "${path.module}/argo-rollouts-install.yml"
}

resource "k8s_manifest" "argo-rollouts" {
  for_each = toset(split("---", data.local_file.argo-rollouts.content))
  content   = each.key

  namespace = kubernetes_namespace.argo-rollouts.id
}
