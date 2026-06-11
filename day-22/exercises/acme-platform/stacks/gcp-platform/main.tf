module "vpc" {
  source = "../../modules/gcp-vpc"

  name       = "rtito-${var.env}"
  project_id = var.project_id
  region     = var.region
  subnets = [
    { name = "nodes", cidr = "10.30.0.0/20", tier = "private" },
    { name = "services", cidr = "10.30.16.0/20", tier = "private" },
  ]
}
