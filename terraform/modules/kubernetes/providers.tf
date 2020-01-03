provider "kubernetes" {
  config_context = "gke_${var.project_id}_${var.zones[0]}_${var.cluster}"
}
