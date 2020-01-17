provider "google" {
  version = "= 3.4.0"
  project = var.project_id
}

provider "google-beta" {
  version = "= 3.4.0"
  project = var.project_id
}

provider "null"     { version = "= 2.1.2" }
provider "random"   { version = "= 2.2.1" }
provider "template" { version = "= 2.1.2" }
provider "http"     { version = "= 1.1.1" }
