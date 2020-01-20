data "google_project" "main" {
  project_id = var.project_id
}

module "project-services" {
  source = "../../../third-party/modules/google-project-factory//modules/project_services"
  project_id                  = var.project_id
  activate_apis               = var.services
  disable_services_on_destroy = false
}

# resource "google_storage_bucket" "cloudbuild-bucket" {
#   name          = "artifacts.${var.project_id}.appspot.com"
#   storage_class = "MULTI_REGIONAL"
#   location      = "EU"
#   force_destroy = true
#   depends_on = [module.project-services]
# }
