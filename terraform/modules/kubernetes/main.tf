terraform {
  backend "gcs" {}
}

locals {
  context = "gke_${var.project_id}_${var.zones[0]}_${var.cluster}"
  endpoint = var.argo_install ? "https://kubernetes.default.svc" : "https://${var.endpoint}"
}
