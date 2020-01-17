data "google_project" "main" {
  project_id = var.project_id
}

resource "google_project_service" "services" {
  for_each           = toset(var.services)
  service            = each.key
  disable_on_destroy = false    # Disabling inconsistent and doesn't always work
}
