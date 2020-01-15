terraform {
  backend "gcs" {}
}

locals {
  terraform_sa = "serviceAccount:${google_service_account.terraform.email}"
  cloudbuild_sa = "serviceAccount:${data.google_project.main.number}@cloudbuild.gserviceaccount.com"
}

data "google_project" "main" {
  project_id = var.project_id
}

resource "google_project_service" "services" {
  for_each = toset(var.services)
  service = each.key

  # project = data.google_project.main.project_id
  disable_on_destroy = false   # disabling inconsistent and doesn't always work
}

resource "google_service_account" "terraform" {
  account_id   = "terraform"
  display_name = "Terraform Service Account"
  # project = data.google_project.main.project_id

  provisioner "local-exec" {
    command = "sleep 10"
  }
}

resource "google_project_iam_member" "terraform" {
  for_each = toset(var.terraform_sa_roles)
  role = each.key

  # project = google_project_service.services[var.services[0]].project
  member  = local.terraform_sa
  depends_on = [google_project_service.services]
}

resource "google_project_iam_member" "cloudbuild" {
  for_each = toset(var.cloudbuild_sa_roles)
  role = each.key

  # project = google_project_service.services[var.services[0]].project
  member = local.cloudbuild_sa
  depends_on = [google_project_service.services]
}

resource "google_storage_bucket_iam_binding" "artifacts-viewer" {
  bucket = "artifacts.${var.project_id}.appspot.com"
  role = "roles/storage.objectViewer"
  members = [
    local.terraform_sa,
  ]
}

# TODO: Cloudbuild SA needs pretty extensive permissions to run our
# Terraform automation, there has to be better way
resource "google_storage_bucket_iam_binding" "artifacts-admin" {
  bucket = "artifacts.${var.project_id}.appspot.com"
  role = "roles/storage.admin"
  members = [
    local.cloudbuild_sa,
  ]
}
