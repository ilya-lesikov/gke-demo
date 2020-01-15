resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
    # labels = {
    #   istio-injection = "enabled"
    # }
  }
  # depends_on = [null_resource.use-context]
  count = var.argocd_install ? 1 : 0
}

# data "local_file" "argocd" {
#     filename = "${path.module}/argocd-install.yml"
# }

data "http" "argocd-install-manifests" {
  url = "https://raw.githubusercontent.com/argoproj/argo-cd/v${var.argocd_ver}/manifests/install.yaml"
  count = var.argocd_install ? 1 : 0
}

resource "k8s_manifest" "argocd" {
  # Don't even ask wtf is this. We need it this way to reference variables from
  # resources with possible "count = 0", i.e. resources that might not exist.
  # Also we are using maps for for_each to provide sane names for resource
  # instances. Instances are accessible like k8s_manifest.argocd["3"] (note
  # "" around "index" since this is a key of map, not an index of list)
  for_each = length(data.http.argocd-install-manifests.*.body) > 0 ? zipmap(range(length(split("---", join("", data.http.argocd-install-manifests.*.body)))), split("---", join("", data.http.argocd-install-manifests.*.body))) : {}
  content   = each.value
  namespace = element(concat(kubernetes_namespace.argocd.*.id, list("")), 0)
}

data "kubernetes_service" "argocd-server" {
  metadata {
    name = "argocd-server"
    namespace = element(concat(kubernetes_namespace.argocd.*.id, list("")), 0)
  }
  depends_on = [k8s_manifest.argocd]
  count = var.argocd_install ? 1 : 0
}

resource "null_resource" "expose-argocd" {
  provisioner "local-exec" {
    command = <<SCRIPT
      kubectl patch service argocd-server \
      --namespace "${element(concat(kubernetes_namespace.argocd.*.id, list("")), 0)}" \
      --context "${local.context}" --patch '{"spec": {"type": "LoadBalancer"}}'
    SCRIPT
  }
  triggers = {
    service_changed = data.kubernetes_service.argocd-server[0].metadata[0].resource_version
  }
  count = var.argocd_install ? 1 : 0
}

resource "kubernetes_service_account" "argocd-manager" {
  metadata {
    name = "argocd-manager"
    namespace = "kube-system"
  }
  count = var.argocd_manager_install ? 1 : 0
}

data "kubernetes_secret" "argocd-manager-sa-secret" {
  metadata {
    name = element(concat(kubernetes_service_account.argocd-manager.*.default_secret_name, list("")), 0)
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
    verbs      = ["*"]
  }
  count = var.argocd_manager_install ? 1 : 0
}

resource "kubernetes_cluster_role_binding" "argocd-manager" {
  metadata {
    name = "argocd-manager-role-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name = "argocd-manager-role"
  }
  subject {
    kind      = "ServiceAccount"
    name = "argocd-manager"
    namespace = "kube-system"
  }
  depends_on = [kubernetes_service_account.argocd-manager, kubernetes_cluster_role.argocd-manager]
  count = var.argocd_manager_install ? 1 : 0
}

# resource "kubernetes_secret" "argocd-manager-sa-token" {
#   metadata {
#     annotations = {
#       "kubernetes.io/service-account.name" = "argocd-manager"
#     }
#   }
#   type = "kubernetes.io/service-account-token"
#   depends_on = [kubernetes_service_account.argocd-manager]
#   count = var.argocd_manager_install ? 1 : 0
# }

resource "kubernetes_secret" "argocd-cluster-secret" {
  provider = kubernetes.management-cluster
  metadata {
    name = "cluster-${var.endpoint}-${substr(uuid(), 0, 10)}"
    labels = {
      "argocd.argoproj.io/secret-type" = "cluster"
    }
    namespace = "argocd"
  }

  data = {
    name = var.cluster
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

resource "kubernetes_namespace" "argo-rollouts" {
  metadata {
    name = "argo-rollouts"
    # labels = {
    #   istio-injection = "enabled"
    # }
  }
  # depends_on = [null_resource.use-context]
  count = var.argo_rollouts_install ? 1 : 0
}

# data "local_file" "argo-rollouts" {
#     filename = "${path.module}/argo-rollouts-install.yml"
# }

data "http" "argo-rollouts-install-manifests" {
  url = "https://raw.githubusercontent.com/argoproj/argo-rollouts/v${var.argo_rollouts_ver}/manifests/install.yaml"
  count = var.argo_rollouts_install ? 1 : 0
}

resource "k8s_manifest" "argo-rollouts" {
  # fuck my life
  for_each = length(data.http.argo-rollouts-install-manifests.*.body) > 0 ? zipmap(range(length(split("---", join("", data.http.argo-rollouts-install-manifests.*.body)))), split("---", join("", data.http.argo-rollouts-install-manifests.*.body))) : {}
  content   = each.value
  namespace = element(concat(kubernetes_namespace.argo-rollouts.*.id, list("")), 0)
}

# TODO: change password from default one and store it in Google KMS
resource "null_resource" "argocd-login" {
  provisioner "local-exec" {
    command = <<SCRIPT
      IP="$(kubectl get services argocd-server --context "${local.context}" -n argocd \
      --no-headers -o "custom-columns=OUT:.status.loadBalancer.ingress[0].ip")"

      PASS="$(kubectl get pods --context "${local.context}" -n argocd \
      -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2)"

      argocd login "$IP" --username admin --password "$PASS" --insecure
    SCRIPT
  }
  triggers = {
    service_changed = data.kubernetes_service.argocd-server[0].metadata[0].resource_version
  }
  count = var.argocd_install ? 1 : 0
  depends_on = [null_resource.expose-argocd]
}
