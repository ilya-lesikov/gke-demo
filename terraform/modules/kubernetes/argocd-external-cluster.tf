resource "kubernetes_service_account" "argocd-manager" {
  metadata {
    name      = "argocd-manager"
    namespace = "kube-system"
  }
  count = var.argocd_manager_install ? 1 : 0
}

data "kubernetes_secret" "argocd-manager-sa-secret" {
  metadata {
    name      = element(concat(kubernetes_service_account.argocd-manager.*.default_secret_name, list("")), 0)
    namespace = "kube-system"
  }
  count = var.argocd_manager_install ? 1 : 0
}

resource "kubernetes_cluster_role" "argocd-manager" {
  metadata {
    name = "argocd-manager-role"
  }
  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["*"]
  }
  rule {
    non_resource_urls = ["*"]
    verbs             = ["*"]
  }
  count = var.argocd_manager_install ? 1 : 0
}

resource "kubernetes_cluster_role_binding" "argocd-manager" {
  metadata {
    name      = "argocd-manager-role-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "argocd-manager-role"
  }
  subject {
    namespace = "kube-system"
    kind      = "ServiceAccount"
    name      = "argocd-manager"
  }
  depends_on = [
    kubernetes_service_account.argocd-manager,
    kubernetes_cluster_role.argocd-manager,
  ]
  count = var.argocd_manager_install ? 1 : 0
}

resource "kubernetes_secret" "argocd-cluster-secret" {
  provider = kubernetes.management-cluster
  metadata {
    name   = "cluster-${var.endpoint}-${substr(uuid(), 0, 10)}"
    labels = {
      "argocd.argoproj.io/secret-type" = "cluster"
    }
    namespace = "argocd"
  }
  data = {
    name   = var.cluster
    server = "https://${var.endpoint}"
    config = <<CONFIG
      {
        "bearerToken": "${element(concat(data.kubernetes_secret.argocd-manager-sa-secret.*.data.token, list("")), 0)}",
        "tlsClientConfig": {
          "insecure": false,
          "caData": "${base64encode(lookup(data.kubernetes_secret.argocd-manager-sa-secret[0].data, "ca.crt", ""))}"
        }
      }
    CONFIG
  }
  count = var.argocd_manager_install ? 1 : 0
}
