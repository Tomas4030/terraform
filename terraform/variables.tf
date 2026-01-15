variable "namespace" {
  type    = string
  default = "three-tier-app"
}

variable "postgres_user" {
  type      = string
  sensitive = true
}

variable "postgres_password" {
  type      = string
  sensitive = true
}

variable "postgres_db" {
  type      = string
  sensitive = true
}
