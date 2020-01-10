resource "kubernetes_namespace" "current" {
  metadata {
    name = var.hipstershop_namespace
    # labels = {
    #   istio-injection = "enabled"
    # }
  }
  # depends_on = [null_resource.use-context]
}

data "template_file" "hipstershop-argo-app" {
  template = "${file("./hipstershop-argo-app.yml")}"

  vars = {
    app_name = "hipstershop-${var.environment}"
    github_infra_owner = var.github_infra_owner
    github_infra_reponame = var.github_infra_reponame
    project = var.project_id
    k8s_cluster_url = local.endpoint
    app_namespace = var.hipstershop_namespace
    manifests_dir = "kubernetes/overlays/${var.environment}"
  }
}

resource "k8s_manifest" "hipstershop-argo-app" {
  provider = k8s.management-cluster
  content   = data.template_file.hipstershop-argo-app.rendered
  namespace = var.argocd_install ? element(concat(kubernetes_namespace.argocd.*.id, list("")), 0) : "argocd"
}
