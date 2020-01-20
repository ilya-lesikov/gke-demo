data "google_project" "main" {
  project_id = var.project_id
}

module "project-services" {
  source = "../../../third-party/modules/google-project-factory//modules/project_services"
  project_id                  = var.project_id
  activate_apis               = var.services
  disable_services_on_destroy = false
}
