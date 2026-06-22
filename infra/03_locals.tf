# locals.tf

locals {
  # ##############################
  # Metadata
  # ##############################
  project  = "demo-storage-web-host"
  location = "canadacentral"

  name = "${local.project}-${var.env}"
  storage_sa_name = "demostoragewebhost"
  default_tags = {
    project     = local.project
    environment = var.env
    region      = local.location
    managed_by  = "terraform"
  }
}
