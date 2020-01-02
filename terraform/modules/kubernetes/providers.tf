provider "kubernetes" {
  config_context = "gke_${project_id}_${region}_${cluster}"
}
