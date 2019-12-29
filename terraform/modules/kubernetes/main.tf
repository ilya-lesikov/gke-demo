resource "null_resource" "populate-kube-config" {
  triggers = {
    "before" = "${var.cluster_ca_certificate}"
  }
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${var.cluster} && sleep 10"
  }
}

resource "kubernetes_namespace" "current" {
  metadata {
    name = var.namespace
    labels = {
      istio-injection = "enabled"
    }
  }
  depends_on = [ null_resource.populate-kube-config ]
}
