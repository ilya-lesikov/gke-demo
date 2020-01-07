output "project_id" {
  value = var.project_id
}

output "region" {
  value = module.gke.region
}

output "zones" {
  value = var.zones
}

output "cluster" {
  value = module.gke.name
}

output "endpoint" {
  value = module.gke.endpoint
}

# output "cluster_ca_certificate" {
#   value = module.gke.ca_certificate
# }
