variable "db_name" {
  description = "The name of the logical database"
  type        = string
}

variable "db_password" {
  description = "The password for the database user"
  type        = string
  sensitive   = true
}

variable "db_user" {
  description = "The database user"
  type        = string
  sensitive   = true
}
