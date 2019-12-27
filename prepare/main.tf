variable "roles_list" {
  type    = list(string)
  default = ["roles/compute.viewer", "roles/container.clusterAdmin", "roles/container.developer", "roles/iam.serviceAccountAdmin", "roles/iam.serviceAccountAdmin", "roles/iam.serviceAccountUser", "roles/resourcemanager.projectIamAdmin", "roles/compute.networkAdmin"]
}

resource "google_project_iam_member" "project" {
  for_each = toset(var.roles_list)

  role = each.key
  project = "gke-demo-548855"
  member  = "serviceAccount:924997815781-compute@developer.gserviceaccount.com"
}
