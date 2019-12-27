module "gcp-network" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 2.0.1"
  project_id   = "gke-demo-548855"
  network_name = "demo-net"

  subnets = [
    {
      subnet_name   = "demo-subnet"
      subnet_ip     = "10.0.0.0/17"
      subnet_region = "europe-west4"
    },
  ]

  secondary_ranges = {
    demo-subnet = [
      {
        range_name    = "ip-range-pods"
        ip_cidr_range = "192.168.0.0/18"
      },
      {
        range_name    = "ip-range-scv"
        ip_cidr_range = "192.168.64.0/18"
      },
    ]
  }
}

module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/beta-public-cluster"
  project_id             = "gke-demo-548855"
  name                   = "demo-cluster"
  regional               = true
  region                 = "europe-west4"
  network                = module.gcp-network.network_name
  subnetwork             = module.gcp-network.subnets_names[0]
  ip_range_pods          = "ip-range-pods"
  ip_range_services      = "ip-range-scv"
  create_service_account = true
  # FIXME: delete this when upstream monitoring_service changed from `monitoring.googleapis.com`
  monitoring_service     = "monitoring.googleapis.com/kubernetes"
  # FIXME: delete this when upstream logging_service changed from `logging.googleapis.com`
  logging_service        = "logging.googleapis.com/kubernetes"
  istio                  = true
  grant_registry_access  = true
}

resource "kubernetes_namespace" "apps" {
  metadata {
    name = "apps"
    labels = {
      istio-injection = "enabled"
    }
  }
}

data "google_client_config" "default" {
}

# resource "kubernetes_service_account" "tiller_service_account" {
#   metadata {
#     name = "tiller"
#     namespace = "kube-system"
#   }
# }

# resource "kubernetes_cluster_role_binding" "tiller_cluster_role_binding" {
#   metadata {
#     name = "tiller"
#   }
#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "ClusterRole"
#     name      = "cluster-admin"
#   }
#   subject {
#     kind      = "ServiceAccount"
#     name      = "tiller"
#     namespace = "kube-system"
#   }
# }

# provider "helm" {
#   service_account = "tiller"
# }

# resource "helm_release" "mydatabase" {
#   name  = "mydatabase"
#   chart = "stable/mariadb"
#   # namespace = "apps"

#   set {
#     name  = "mariadbUser"
#     value = "foo"
#   }

#   set {
#     name  = "mariadbPassword"
#     value = "qux"
#   }
# }
