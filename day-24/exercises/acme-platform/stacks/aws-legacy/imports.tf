import {
  to = module.rds.aws_db_instance.this
  id = var.db_identifier
}

import {
  to = aws_instance.legacy_app
  id = var.legacy_app_instance_id
}
