terraform {
  backend "gcs" {}
}

locals {
  context = "gke_${var.project_id}_${var.zones[0]}_${var.cluster}"
  endpoint = var.argo_install ? "https://kubernetes.default.svc" : "https://${var.endpoint}"
}

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

data "kubernetes_service" "argocd-server" {
  metadata {
    name = "argocd-server"
    namespace = element(concat(kubernetes_namespace.argocd.*.id, list("")), 0)
  }
  depends_on = [k8s_manifest.argocd]
  count = var.argo_install ? 1 : 0
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
  count = var.argo_install ? 1 : 0
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

data "template_file" "hipstershop-argo-app" {
  template = "${file("./hipstershop-argo-app.yml")}"

  vars = {
    github_infra_owner = var.github_infra_owner
    github_infra_reponame = var.github_infra_reponame
    project = var.project_id
    k8s_cluster_url = local.endpoint
    app_namespace = var.namespace
  }
}

# creating a second resource in the nginx namespace
resource "k8s_manifest" "hipstershop-argo-app" {
  content   = data.template_file.hipstershop-argo-app.rendered
  namespace = element(concat(kubernetes_namespace.argocd.*.id, list("")), 0)
}
