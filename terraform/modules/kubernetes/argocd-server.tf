resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
  count = var.argocd_install ? 1 : 0
}

data "http" "argocd-install-manifests" {
  url   = "https://raw.githubusercontent.com/argoproj/argo-cd/v${var.argocd_ver}/manifests/install.yaml"
  count = var.argocd_install ? 1 : 0
}

resource "k8s_manifest" "argocd" {
  # Don't even ask wtf is this. We need it this way to reference variables from
  # resources with possible "count = 0", i.e. resources that might not exist.
  # Also we are using maps for for_each to provide sane names for resource
  # instances. Instances are accessible like k8s_manifest.argocd["3"] (note
  # "" around "index" since this is a key of map, not an index of list)
  for_each  = length(data.http.argocd-install-manifests.*.body) > 0 ? zipmap(range(length(split("---", join("", data.http.argocd-install-manifests.*.body)))), split("---", join("", data.http.argocd-install-manifests.*.body))) : {}
  content   = each.value
  namespace = element(concat(kubernetes_namespace.argocd.*.id, list("")), 0)
}

data "kubernetes_service" "argocd-server" {
  metadata {
    name      = "argocd-server"
    namespace = element(concat(kubernetes_namespace.argocd.*.id, list("")), 0)
  }
  depends_on = [k8s_manifest.argocd]
  count      = var.argocd_install ? 1 : 0
}

resource "null_resource" "expose-argocd" {
  provisioner "local-exec" {
    command = <<SCRIPT
      kubectl patch service argocd-server \
        -n "${element(concat(kubernetes_namespace.argocd.*.id, list("")), 0)}" \
        --context "${local.context}" --patch '{"spec": {"type": "LoadBalancer"}}'
    SCRIPT
  }
  triggers = {
    service_changed = data.kubernetes_service.argocd-server[0].metadata[0].resource_version
  }
  count = var.argocd_install ? 1 : 0
}

# TODO: change password from default one and store it in Google KMS
resource "null_resource" "argocd-login" {
  provisioner "local-exec" {
    command = <<SCRIPT
      sleep 15

      IP="$(kubectl get services argocd-server --context "${local.context}" -n argocd \
      --no-headers -o "custom-columns=IP:.status.loadBalancer.ingress[0].ip")"

      PASS="$(kubectl get pods --context "${local.context}" -n argocd \
      -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2)"

      argocd login "$IP" --username admin --password "$PASS" --insecure
    SCRIPT
  }
  triggers = {
    service_changed = data.kubernetes_service.argocd-server[0].metadata[0].resource_version
  }
  depends_on = [
    null_resource.expose-argocd,
    k8s_manifest.argo-rollouts,
  ]
  count = var.argocd_install ? 1 : 0
}
