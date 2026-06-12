resource "aws_db_instance" "this" {
  identifier                = var.identifier
  engine                    = "postgres"
  engine_version            = var.engine_version
  instance_class            = var.instance_class
  allocated_storage         = var.allocated_storage
  username                  = var.username
  password                  = var.password
  storage_encrypted         = true
  publicly_accessible       = false
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.identifier}-final-${formatdate("YYYYMMDD", timestamp())}"
  deletion_protection       = var.deletion_protection
  tags                      = var.tags

  lifecycle {
    prevent_destroy = false
    ignore_changes  = [password, final_snapshot_identifier]
  }
}
