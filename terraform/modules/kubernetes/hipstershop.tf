resource "kubernetes_namespace" "current" {
  metadata {
    name = var.namespace
    # labels = {
    #   istio-injection = "enabled"
    # }
  }
  # depends_on = [null_resource.use-context]
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

resource "k8s_manifest" "hipstershop-argo-app" {
  content   = data.template_file.hipstershop-argo-app.rendered
  namespace = element(concat(kubernetes_namespace.argocd.*.id, list("")), 0)
}
