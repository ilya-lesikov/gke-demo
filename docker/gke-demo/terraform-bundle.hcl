terraform {
  version = "0.12.19"
}

providers {
  google      = ["= 3.4.0"]
  google-beta = ["= 3.4.0"]
  kubernetes  = ["= 1.10.0"]

  null        = ["= 2.1.2"]
  random      = ["= 2.2.1"]
  template    = ["= 2.1.2"]
  http        = ["= 1.1.1"]
}
