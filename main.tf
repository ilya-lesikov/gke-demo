resource "null_resource" "delay10" {
  provisioner "local-exec" {
    command = "sleep 10"
  }
}

resource "google_service_account" "terraform" {
  account_id   = "terraform"
  display_name = "Terraform Service Account"
  project = data.google_project.main.project_id
  depends_on = ["null_resource.delay10"]
}

resource "google_project_iam_member" "terraform" {
  for_each = toset(var.terraform_sa_roles)
  role = each.key

  project = data.google_project.main.project_id
  member  = resource.google_service_account.terraform.unique_id
}

data "google_service_account" "cloudbuild" {
  account_id = data.google_project.main.number
}

resource "google_project_iam_member" "cloudbuild" {
  for_each = toset(var.cloudbuild_sa_roles)
  role = each.key

  project = data.google_project.main.project_id
  member  = resource.google_service_account.cloudbuild.unique_id
}

data "google_project" "main" {
  project_id = var.project_id
}

resource "google_project_service" "services" {
  for_each = toset(var.services)
  service = each.key

  project = data.google_project.main.project_id
}

module "gcp-network" {
  source       = "terraform-google-modules/network/google"
  project_id   = data.google_project.main.project_id
  network_name = var.net_name

  subnets = [
    {
      subnet_name   = var.subnet_name
      subnet_ip     = var.subnet_primary_ip_range
      subnet_region = var.region
    },
  ]

  secondary_ranges = {
    demo-subnet = [
      {
        range_name    = var.subnet_pods_ip_range_name
        ip_cidr_range = var.subnet_pods_ip_range
      },
      {
        range_name    = var.subnet_services_ip_range_name
        ip_cidr_range = var.subnet_services_ip_range
      },
    ]
  }
}

module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/beta-public-cluster"
  project_id             = data.google_project.main.project_id
  name                   = var.cluster
  regional               = true
  region                 = var.region
  network                = module.gcp-network.network_name
  subnetwork             = module.gcp-network.subnets_names[0]
  ip_range_pods          = module.gcp-network.subnets_secondary_ranges[0]
  ip_range_services      = module.gcp-network.subnets_secondary_ranges[1]
  create_service_account = false
  service_account = resource.google_service_account.terraform.unique_id
  # FIXME: delete this when upstream monitoring_service changed from `monitoring.googleapis.com`
  monitoring_service     = "monitoring.googleapis.com/kubernetes"
  # FIXME: delete this when upstream logging_service changed from `logging.googleapis.com`
  logging_service        = "logging.googleapis.com/kubernetes"
  istio                  = true
}

resource "kubernetes_namespace" "prod" {
  metadata {
    name = var.namespace_prod
    labels = {
      istio-injection = "enabled"
    }
  }
}

resource "kubernetes_namespace" "staging" {
  metadata {
    name = var.namespace_staging
    labels = {
      istio-injection = "enabled"
    }
  }
}

# FIXME: do we need this???
data "google_client_config" "default" {
}
