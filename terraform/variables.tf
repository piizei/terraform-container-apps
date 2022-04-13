variable "location" {
  description = "Azure location of the resource"
  type        = string
  default     = "westeurope"
}
variable "environment" {
  description = "Name of the environment."
  type        = string
  default     = "dev"
}
variable "owner" {
  description = "Owner of the resource"
  type        = string
  default     = "n/a"
}

variable "release_version" {
  description = "Version of the infrastructure automation"
  type        = string
  default     = "latest"
}