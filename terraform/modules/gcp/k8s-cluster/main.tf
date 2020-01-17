terraform {
  backend "gcs" {}
}

locals {
  cluster                       = "cluster-demo-${var.environment}"
  net_name                      = "net-demo-${var.environment}"
  subnet_name                   = "subnet-demo-${var.environment}"
  subnet_pods_ip_range_name     = "ip-range-pods-${var.environment}"
  subnet_services_ip_range_name = "ip-range-services-${var.environment}"
}
