resource "kubernetes_namespace" "current" {
  metadata {
    name = var.namespace
    labels = {
      istio-injection = "enabled"
    }
  }
}
