# resource "google_kms_key_ring" "keyring-main" {
#   name     = "keyring-main"
#   location = "global"
# }

data "google_kms_key_ring" "keyring-main" {
  name     = "keyring-main"
  location = "global"
}

# resource "google_kms_crypto_key" "key-github" {
#   name            = "key-github"
#   key_ring        = google_kms_key_ring.keyring-main.self_link
#   purpose = "ENCRYPT_DECRYPT"
# }

data "google_kms_crypto_key" "key-github" {
  name     = "key-github"
  key_ring = data.google_kms_key_ring.keyring-main.self_link
}

resource "google_kms_secret_ciphertext" "ssh-pk" {
  crypto_key = data.google_kms_crypto_key.key-github.id
  plaintext  = file("${var.ssh_dir_path}/id_rsa")
}

resource "gitfile_file" "ssh-pk" {
    checkout_dir = gitfile_checkout.repo-gke-demo.path
    path = "id_rsa.enc"
    contents = google_kms_secret_ciphertext.ssh-pk.ciphertext
}

resource "gitfile_commit" "commit-ssh-pk" {
    checkout_dir = gitfile_checkout.repo-gke-demo.path
    commit_message = "[TF] Add encrypted SSH private key"
    handle = gitfile_file.ssh-pk.id
}

# resource "null_resource" "known-host-github" {
# }

# resource "local_file" "foo" {
#   content     = "foo!"
#   filename = "${path.module}/foo.bar"
#   provisioner "local-exec" {
#     command = <<SCRIPT
#       ssh-keyscan -t rsa github.com > ${ssh_dir_path}/known_hosts
#   }
# }
