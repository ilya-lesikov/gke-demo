resource "google_cloudbuild_trigger" "release-microservices" {
  provider    = google-beta
  name        = "release-microservices"
  filename    = "cloudbuild.yml"
  description = "Build, test, deploy apps to prod"
  github {
    owner = var.github_demo_owner
    name  = var.github_demo_reponame
    push {
      tag = "release_*"
    }
  }
  substitutions = {
    _GITHUB_DEMO_OWNER    = var.github_demo_owner
    _GITHUB_DEMO_REPONAME = var.github_demo_reponame
    _KMS_KEYRING_NAME     = data.google_kms_key_ring.keyring-main.name
    _KMS_KEY_NAME_GITHUB  = data.google_kms_crypto_key.key-github.name
  }
}
