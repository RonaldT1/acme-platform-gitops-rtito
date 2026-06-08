locals {
  lab_owner = "rtito"
  lab_day   = "day-20"

  common_tags = {
    Owner       = local.lab_owner
    Environment = var.environment
    Service     = "bootcamp"
    CostCenter  = "bootcamp"
    ManagedBy   = "terraform"
    LabDay      = local.lab_day
  }

  cluster_name = "${var.project}-eks"
}
