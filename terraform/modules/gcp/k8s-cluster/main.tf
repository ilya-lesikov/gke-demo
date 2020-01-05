terraform {
  backend "gcs" {}
}

locals {
  cluster = "cluster-demo-${var.environment}"
  net_name = "demo-${var.environment}"
  subnet_name = "demo-${var.environment}"
  subnet_pods_ip_range_name = "pods-${var.environment}"
  subnet_services_ip_range_name = "services-${var.environment}"
}

module "gcp-network" {
  source       = "terraform-google-modules/network/google"
  project_id   = var.project_id
  network_name = local.net_name

  subnets = [
    {
      subnet_name   = local.subnet_name
      subnet_ip     = var.subnet_primary_ip_range
      subnet_region = var.region
    },
  ]

  secondary_ranges = {
    "${local.subnet_name}" = [
      {
        range_name    = local.subnet_pods_ip_range_name
        ip_cidr_range = var.subnet_pods_ip_range
      },
      {
        range_name    = local.subnet_services_ip_range_name
        ip_cidr_range = var.subnet_services_ip_range
      },
    ]
  }
}

# Sleep after creating the network to fix "Network requires specifying a
# subnetwork., badRequest"
# resource "null_resource" "sleep30" {
#   provisioner "local-exec" {
#     # FIXME: looks like it doesn't help, remove it?
#     command = "sleep 300"
#   }
#   triggers = {
#     subnet_changed = join("", module.gcp-network.subnets_self_links)
#   }
#   depends_on = [module.gcp-network]
# }

# Reference outputs from this data source to make your module depend on
# "module.gcp-network" without "depends_on"
data "google_compute_subnetwork" "subnet" {
  # name       = local.subnet_name
  name             = reverse(split("/", module.gcp-network.subnets_names[0]))[0]
  # project    = var.project_id
  # region     = var.region
  # depends_on = [null_resource.sleep30]
  # depends_on = [module.gcp-network]
}

resource "google_compute_router" "main" {
  name    = var.environment
  # project = var.project_id
  # region  = module.gcp-network.subnets_regions[0]
  network = module.gcp-network.network_name
}

resource "google_compute_router_nat" "main" {
  name                               = "main"
  # project = var.project_id
  router                             = google_compute_router.main.name
  # region                             = google_compute_router.main.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/beta-private-cluster"
  project_id             = var.project_id
  name                   = local.cluster
  regional               = false
  zones                 = var.zones
  # This craziness gets a plain network name from the reference link which is the
  # only way to force cluster creation to wait on network creation without a
  # depends_on link (still not implemented in 0.12). Fucking terraform
  network = reverse(split("/", data.google_compute_subnetwork.subnet.network))[0]
  # network                = module.gcp-network.network_name
  # subnetwork             = module.gcp-network.subnets_names[0]
  subnetwork = data.google_compute_subnetwork.subnet.name
  ip_range_pods          = local.subnet_pods_ip_range_name
  ip_range_services      = local.subnet_services_ip_range_name
  create_service_account = false
  service_account = var.terraform_sa_fqdn
  enable_private_nodes    = true
  master_ipv4_cidr_block  = var.master_cidr
  remove_default_node_pool          = true
  # FIXME: delete this when upstream monitoring_service changed from `monitoring.googleapis.com`
  monitoring_service     = "monitoring.googleapis.com/kubernetes"
  # FIXME: delete this when upstream logging_service changed from `logging.googleapis.com`
  logging_service        = "logging.googleapis.com/kubernetes"
  # istio                  = true

  node_pools = [{
    name               = "main"
    machine_type       = var.machine_type
    min_count          = 1
    max_count          = var.max_nodes
    disk_size_gb       = 15
    disk_type          = "pd-ssd"
    auto_upgrade       = true
    service_account = var.terraform_sa_fqdn
  }]
}

resource "null_resource" "populate-kube-config" {
  provisioner "local-exec" {
    command = <<SCRIPT
      gcloud container clusters get-credentials --zone=${var.zones[0]} ${module.gke.name} \
      && sleep 10
    SCRIPT
  }
  triggers = {
    cluster_cert_changed = "${module.gke.ca_certificate}"
  }
}
