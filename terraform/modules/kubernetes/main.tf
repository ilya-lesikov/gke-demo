terraform {
  backend "gcs" {}
}

locals {
  context = "gke_${var.project_id}_${var.zones[0]}_${var.cluster}"
  management_context = var.management_context == null ? local.context : var.management_context
  endpoint = var.argocd_install ? "https://kubernetes.default.svc" : "https://${var.endpoint}"
}
