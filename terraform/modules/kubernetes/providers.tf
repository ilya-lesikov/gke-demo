provider "kubernetes" {
  # Almost none configuration in this provider ACTUALLY consistently works.
  # Who knows why, maybe they'll fix this upstream some day, for now we are
  # switching context with terragrunt hooks.
  # config_context = "gke_${var.project_id}_${var.zones[0]}_${var.cluster}"
}
