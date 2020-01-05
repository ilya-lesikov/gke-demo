terraform {
  source = "../../../..//modules/gcp/project/"
}

include {
  path = find_in_parent_folders()
}

prevent_destroy = true
