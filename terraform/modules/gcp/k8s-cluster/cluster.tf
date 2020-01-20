module "gke" {
  source = "../../../third-party/modules/google-kubernetes-engine//modules/beta-private-cluster"
  project_id               = var.project_id
  name                     = local.cluster
  regional                 = false
  zones                    = var.zones
  # This craziness gets a plain network name from the reference link which is the
  # only way to force cluster creation to wait on network creation without a
  # depends_on link (still not implemented in 0.12)
  network                  = reverse(split("/", data.google_compute_subnetwork.subnet.network))[0]
  subnetwork               = data.google_compute_subnetwork.subnet.name
  master_ipv4_cidr_block   = var.master_cidr
  ip_range_pods            = local.subnet_pods_ip_range_name
  ip_range_services        = local.subnet_services_ip_range_name
  create_service_account   = false
  service_account          = var.terraform_sa_fqdn
  enable_private_nodes     = true
  remove_default_node_pool = true
  # TODO: delete this when upstream monitoring_service changed from `monitoring.googleapis.com`
  monitoring_service       = "monitoring.googleapis.com/kubernetes"
  # TODO: delete this when upstream logging_service changed from `logging.googleapis.com`
  logging_service          = "logging.googleapis.com/kubernetes"
  node_pools               = [
    {
      name            = "main"
      machine_type    = var.machine_type
      min_count       = 1
      max_count       = var.max_nodes
      disk_size_gb    = 15
      disk_type       = "pd-ssd"
      auto_upgrade    = true
      service_account = var.terraform_sa_fqdn
    },
  ]
}

resource "null_resource" "populate-kube-config" {
  provisioner "local-exec" {
    command = <<SCRIPT
      gcloud container clusters get-credentials --zone=${var.zones[0]} ${module.gke.name}
      sleep 10
    SCRIPT
  }
  triggers = {
    always = uuid()
  }
}
