terraform {
  backend "gcs" {}
}

locals {
  terraform_sa  = "serviceAccount:${google_service_account.terraform.email}"
  cloudbuild_sa = "serviceAccount:${data.google_project.main.number}@cloudbuild.gserviceaccount.com"
}
