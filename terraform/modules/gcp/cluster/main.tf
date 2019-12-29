module "gcp-network" {
  source       = "terraform-google-modules/network/google"
  project_id   = var.project_id
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
  project_id             = var.project_id
  name                   = var.cluster
  regional               = true
  region                 = var.region
  network                = module.gcp-network.network_name
  subnetwork             = module.gcp-network.subnets_names[0]
  ip_range_pods          = var.subnet_pods_ip_range_name
  ip_range_services      = var.subnet_services_ip_range_name
  create_service_account = false
  service_account = var.terraform_sa_fqdn
  # FIXME: delete this when upstream monitoring_service changed from `monitoring.googleapis.com`
  monitoring_service     = "monitoring.googleapis.com/kubernetes"
  # FIXME: delete this when upstream logging_service changed from `logging.googleapis.com`
  logging_service        = "logging.googleapis.com/kubernetes"
  istio                  = true
}

resource "kubernetes_namespace" "current" {
  metadata {
    name = var.namespace
    labels = {
      istio-injection = "enabled"
    }
  }
}

# FIXME: do we need this???
data "google_client_config" "default" {
}
