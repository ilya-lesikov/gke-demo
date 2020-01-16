resource "null_resource" "ssh-config" {
  provisioner "local-exec" {
    command = <<SCRIPT
      echo "Hostname github.com" > /root/.ssh/config
      echo "  IdentityFile /root/.ssh/id_rsa" >> /root/.ssh/config
    SCRIPT
  }
  provisioner "local-exec" {
    command = "sleep 5"
  }
  triggers = {
    always_recreate = "${timestamp()}"
    # Workaround for https://github.com/hashicorp/terraform/issues/18303
    # before = "${data.google_project.main.project_id}"
  }
}

resource "null_resource" "git-config" {
  provisioner "local-exec" {
    command = <<SCRIPT
      git config --global user.name "Robot (beeEEeEEEEEEEEP)"
      git config --global user.email "robot@example.org"
    SCRIPT
  }
  provisioner "local-exec" {
    command = "sleep 5"
  }
  triggers = {
    always_recreate = "${timestamp()}"
    # Workaround for https://github.com/hashicorp/terraform/issues/18303
    # before = "${data.google_project.main.project_id}"
  }
}

resource "null_resource" "known-hosts-github" {
  provisioner "local-exec" {
    command = <<SCRIPT
      if (!(ssh-keygen -F github.com)); then
        ssh-keyscan -t rsa github.com >> /root/.ssh/known_hosts && sleep 5
      fi
    SCRIPT
  }
  triggers = {
    always_recreate = "${timestamp()}"
    # Workaround for https://github.com/hashicorp/terraform/issues/18303
    # before = "${data.google_project.main.project_id}"
  }
}

resource "gitfile_checkout" "repo-gke-demo" {
    repo = "git@github.com:${var.github_demo_owner}/${var.github_demo_reponame}"
    branch = "master"
    path = "./tmp/gke-demo"
    depends_on = [
      null_resource.ssh-config,
      null_resource.known-hosts-github,
      null_resource.git-config,
    ]
}
