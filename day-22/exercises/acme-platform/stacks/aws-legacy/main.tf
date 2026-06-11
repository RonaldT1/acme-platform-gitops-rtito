module "vpc" {
  source = "../../modules/aws-vpc"

  name = "rtito-${var.env}"
  cidr = var.vpc_cidr
  azs  = ["us-east-1a", "us-east-1b"]
  tags = {
    Env       = var.env
    Owner     = "platform"
    ManagedBy = "terraform"
  }
}
