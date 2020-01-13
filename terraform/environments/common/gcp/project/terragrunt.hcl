terraform {
  source = "../../../..//modules/gcp/project/"
  before_hook "create-kms-keyring-main" {
    commands     = ["apply", "plan"]
    execute      = [
      "bash", "-c",
      "gcloud kms keyrings create --location global keyring-main || true",
    ]
  }
  before_hook "create-kms-key-github" {
    commands     = ["apply", "plan"]
    execute      = [
      "bash", "-c",
      "gcloud kms keys create key-github --purpose=encryption --location global --keyring keyring-main || true",
    ]
  }
}

include {
  path = find_in_parent_folders()
}
