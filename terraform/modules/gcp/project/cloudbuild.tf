resource "google_cloudbuild_trigger" "build-microservice" {
  provider = google-beta

  for_each = toset(var.microservices)

  name = "build-${each.key}"
  description = "Build and push ${each.key}"
  github {
    owner = var.github_microservices_owner
    name = var.github_microservices_reponame
    push {
      branch = "master"
    }
  }
  substitutions = {
    _APP = each.key
  }
  included_files = [
    "src/${each.key}/**",
    "protocol-buffers/**",
  ]
  ignored_files = [
    "**/README.md",
  ]
  filename = "cloudbuild.yml"

  provisioner "local-exec" {
    command = <<SCRIPT
      gcloud beta builds triggers run build-${each.key} \
      --branch master --project "${var.project_id}"
    SCRIPT
  }
}

resource "google_cloudbuild_trigger" "build-terragrunt-builder" {
  provider = google-beta

  name = "build-terragrunt-builder"
  description = "Build and push GCB Terragrunt builder"
  github {
    owner = var.github_community_cloud_builders_owner
    name = var.github_community_cloud_builders_reponame
    push {
      branch = "master"
    }
  }
  included_files = [
    "terragrunt/**",
  ]
  ignored_files = [
    "terragrunt/README.markdown",
    "terragrunt/examples",
  ]
  filename = "terragrunt/cloudbuild.yaml"

  provisioner "local-exec" {
    command = <<SCRIPT
      gcloud beta builds triggers run build-terragrunt-builder \
      --branch master --project "${var.project_id}"
    SCRIPT
  }
}
