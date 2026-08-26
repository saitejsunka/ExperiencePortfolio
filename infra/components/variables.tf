variable "db_name" {
  description = "The name of the logical database"
  type        = string
}

variable "db_password" {
  description = "The password for the expo_admin database user"
  type        = string
  sensitive   = true
}
