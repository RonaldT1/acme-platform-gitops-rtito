variable "name" {
  type = string
}

variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "subnets" {
  type = list(object({
    name = string
    cidr = string
    tier = string
  }))
}
