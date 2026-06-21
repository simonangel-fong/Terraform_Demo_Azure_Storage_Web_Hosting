# variables.tf

variable "env" {
  description = "Deployment environment (dev, stg, prod)."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "stg", "prod"], var.env)
    error_message = "env must be one of: dev, stg, prod."
  }
}
