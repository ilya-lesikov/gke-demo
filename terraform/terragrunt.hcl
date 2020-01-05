remote_state {
  backend = "gcs"
  config = {
    bucket         = "${get_env("TF_VAR_project_id", "")}_terraform-state"
    prefix = "${path_relative_to_include()}/"
  }
}

skip = true
