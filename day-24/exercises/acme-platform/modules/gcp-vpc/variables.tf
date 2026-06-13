variable "name" {
  type = string
}

variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "enable_cloud_nat" {
  type    = bool
  default = true
}

variable "subnets" {
  type = list(object({
    name = string
    cidr = string
    tier = string
  }))
}
