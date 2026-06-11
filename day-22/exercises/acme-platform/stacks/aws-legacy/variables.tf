variable "region" {
  type    = string
  default = "us-east-1"
}

variable "env" {
  type = string
}

variable "vpc_cidr" {
  type    = string
  default = "10.20.0.0/16"
}
