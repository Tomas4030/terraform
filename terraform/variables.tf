variable "namespace" {
  type    = string
  default = "theboss"
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

variable "backend" {
  type = string
  default = "backend:latest"
  sensitive = true
}

variable "frontend" {
  type = string
  default = "frontend:latest"
  sensitive = true
}