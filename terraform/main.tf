locals {
  common_tags = {
    environment = var.environment
    owner       = var.owner
    version     = var.release_version
  }
}