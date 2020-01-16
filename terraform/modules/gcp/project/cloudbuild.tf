resource "google_cloudbuild_trigger" "release-microservices" {
  provider = google-beta

  # for_each = toset(var.microservices)

  name = "release-microservices"
  description = "Build, test, deploy apps to prod"
  github {
    owner = var.github_demo_owner
    name = var.github_demo_reponame
    push {
      tag = "release_*"
    }
  }
  substitutions = {
    # _APPS = join(" ", var.microservices)
    # _GITHUB_DEMO_OWNER = var.github_demo_owner
    # _GITHUB_DEMO_REPONAME = var.github_demo_reponame
    _KMS_KEYRING_NAME = data.google_kms_key_ring.keyring-main.name
    _KMS_KEY_NAME_GITHUB = data.google_kms_crypto_key.key-github.name
    # _SSH_PK_ENC = google_kms_secret_ciphertext.ssh-pk.ciphertext
  }
  # included_files = [
  #   "third-party/microservices/src/**",
  #   "third-party/microservices/protocol-buffers/**",
  # ]
  # ignored_files = [
  #   "**/README.md",
  # ]
  filename = "cloudbuild.yml"

  # provisioner "local-exec" {
  #   command = <<SCRIPT
  #     gcloud beta builds triggers run build-${each.key} \
  #     --branch master --project "${var.project_id}"
  #   SCRIPT
  # }
}

# resource "google_cloudbuild_trigger" "build-all-microservices" {
#   provider = google-beta

#   name = "build-all-microservices"
#   description = "Build and push all microservices"
#   github {
#     owner = var.github_demo_owner
#     name = var.github_demo_reponame
#     push {
#       branch = "master"
#     }
#   }
#   disabled = true
#   filename = "gcb-build-all.yml"

#   provisioner "local-exec" {
#     command = <<SCRIPT
#       gcloud beta builds triggers run build-all-microservices \
#       --branch master --project "${var.project_id}"
#     SCRIPT
#   }
# }

# resource "google_cloudbuild_trigger" "build-terragrunt-builder" {
#   provider = google-beta

#   name = "build-terragrunt-builder"
#   description = "Build and push GCB Terragrunt builder"
#   github {
#     owner = var.github_community_cloud_builders_owner
#     name = var.github_community_cloud_builders_reponame
#     push {
#       branch = "master"
#     }
#   }
#   included_files = [
#     "terragrunt/**",
#   ]
#   ignored_files = [
#     "terragrunt/README.markdown",
#     "terragrunt/examples",
#   ]
#   filename = "terragrunt/cloudbuild.yaml"

#   provisioner "local-exec" {
#     command = <<SCRIPT
#       gcloud beta builds triggers run build-terragrunt-builder \
#       --branch master --project "${var.project_id}"
#     SCRIPT
#   }
# }
