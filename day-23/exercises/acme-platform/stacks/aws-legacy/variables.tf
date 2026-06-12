variable "region" {
  type    = string
  default = "us-east-1"
}

variable "env" {
  type = string
}

variable "db_identifier" {
  type    = string
  default = "rtito-legacy-db"
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_allocated_storage" {
  type    = number
  default = 20
}

variable "db_engine_version" {
  type    = string
  default = "16.3"
}

variable "db_username" {
  type    = string
  default = "acme"
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_deletion_protection" {
  type    = bool
  default = false
}

variable "db_skip_final_snapshot" {
  type    = bool
  default = true
}

variable "legacy_app_instance_id" {
  type        = string
  description = "Real EC2 instance ID created manually before import."
}
