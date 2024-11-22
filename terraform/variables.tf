variable "POSTGRES_USER" {
  description = "PostgreSQL User"
  type        = string
}

variable "POSTGRES_PASSWORD" {
  description = "PostgreSQL Password"
  type        = string
}

variable "POSTGRES_DB" {
  description = "PostgreSQL Database Name"
  type        = string
}

variable "DATABASE_ADMIN_PASSWORD" {
  description = "Database Admin Password"
  type        = string
}

variable "DOCKER_HOST" {
  type = string
  description = "Docker Host Based on OS"
}
