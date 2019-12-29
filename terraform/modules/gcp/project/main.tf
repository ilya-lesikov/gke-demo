# TODO: pin versions in every module

resource "null_resource" "delay10" {
  provisioner "local-exec" {
    command = "sleep 10"
  }
}

resource "google_service_account" "terraform" {
  account_id   = "terraform"
  display_name = "Terraform Service Account"
  project = data.google_project.main.project_id
  depends_on = [ null_resource.delay10 ]
}

resource "google_project_iam_member" "terraform" {
  for_each = toset(var.terraform_sa_roles)
  role = each.key

  project = data.google_project.main.project_id
  member  = "serviceAccount:${google_service_account.terraform.email}"
}

# data "google_service_account" "cloudbuild" {
#   account_id = data.google_project.main.number
#   project = data.google_project.main.project_id
# }

resource "google_project_iam_member" "cloudbuild" {
  for_each = toset(var.cloudbuild_sa_roles)
  role = each.key

  project = data.google_project.main.project_id
  member = "serviceAccount:${data.google_project.main.number}@cloudbuild.gserviceaccount.com"
}

data "google_project" "main" {
  project_id = var.project_id
}

resource "google_project_service" "services" {
  for_each = toset(var.services)
  service = each.key

  project = data.google_project.main.project_id
}
