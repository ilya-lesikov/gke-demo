resource "google_service_account" "terraform" {
  account_id   = "terraform"
  display_name = "Terraform Service Account"

  provisioner "local-exec" {
    command = "sleep 10"
  }
}

resource "google_project_iam_member" "terraform" {
  for_each   = toset(var.terraform_sa_roles)
  role       = each.key
  member     = local.terraform_sa
  depends_on = [module.project-services]
}

resource "google_project_iam_member" "cloudbuild" {
  for_each   = toset(var.cloudbuild_sa_roles)
  role       = each.key
  member     = local.cloudbuild_sa
  depends_on = [module.project-services]
}
