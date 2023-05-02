// var.pkr.hcl - Variables are retrieved from GitHub action secrets
variable "client_id" {
  type      = string
  sensitive = true
}

variable "client_secret" {
  type      = string
  sensitive = true
}

variable "subscription_id" {
  type      = string
  sensitive = true
}

variable "tenant_id" {
  type      = string
  sensitive = true
}

variable "location" {
  type      = string
}

variable "rg" {
  type    = string
}
