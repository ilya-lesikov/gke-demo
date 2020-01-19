variable "project_id"           {}
variable "github_demo_owner"    {}
variable "github_demo_reponame" {}
variable "microservices"        {
  type = list(string)
}

variable "ssh_dir_path" {
  default = "/root/.ssh"
}

variable "services" {
  default = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "containerregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudbilling.googleapis.com",
    "dns.googleapis.com",   # for pulling images from GCR from private cluster
    "cloudkms.googleapis.com",
    "cloudprofiler.googleapis.com",
    "stackdriver.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com",
    "cloudtrace.googleapis.com",
    "clouddebugger.googleapis.com",
    "clouderrorreporting.googleapis.com",
  ]
  type = list(string)
}

variable "terraform_sa_roles" {
  default = [
    "roles/compute.viewer",
    "roles/container.clusterAdmin",
    "roles/container.developer",
    "roles/iam.serviceAccountAdmin",
    "roles/resourcemanager.projectIamAdmin",
    "roles/compute.networkAdmin",
    "roles/storage.objectViewer",   # for pulling images from GCR
    "roles/monitoring.metricWriter",
    "roles/logging.logWriter",
    "roles/cloudtrace.agent",
    "roles/cloudprofiler.agent",
    "roles/errorreporting.writer",
    "roles/clouddebugger.agent",
  ]
  type = list(string)
}

variable "cloudbuild_sa_roles" {
  # TODO: Cloudbuild SA needs pretty extensive permissions to run our
  # Terraform automation, there has to be better way
  default = [
    "roles/compute.admin",
    "roles/container.admin",
    "roles/iam.securityAdmin",
    "roles/storage.admin",
    "roles/monitoring.admin",
    "roles/cloudkms.admin",
    "roles/cloudkms.cryptoKeyEncrypterDecrypter",
  ]
  type = list(string)
}
