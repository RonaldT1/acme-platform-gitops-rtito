output "legacy_app_id" {
  value = aws_instance.legacy_app.id
}

output "legacy_app_private_ip" {
  value = aws_instance.legacy_app.private_ip
}

output "rds_arn" {
  value = module.rds.arn
}

output "rds_endpoint" {
  value = module.rds.endpoint
}
