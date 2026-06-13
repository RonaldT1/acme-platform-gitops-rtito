locals {
  common_tags = {
    Env = var.env
  }
}

module "rds" {
  source = "../../modules/aws-rds"

  identifier          = var.db_identifier
  instance_class      = var.db_instance_class
  allocated_storage   = var.db_allocated_storage
  engine_version      = var.db_engine_version
  username            = var.db_username
  password            = var.db_password
  deletion_protection = var.db_deletion_protection
  skip_final_snapshot = var.db_skip_final_snapshot
  tags = merge(local.common_tags, {
    ManagedBy = "manual-will-import"
  })
}
