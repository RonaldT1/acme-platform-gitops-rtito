output "vpc_id"             { value = aws_vpc.main.id }
output "public_subnet_ids"  { value = aws_subnet.public[*].id }
output "private_subnet_ids" { value = aws_subnet.private[*].id }

output "ecr_url" { value = aws_ecr_repository.app.repository_url }
output "alb_dns" { value = aws_lb.main.dns_name }

output "cloudfront_url"     { value = "https://${aws_cloudfront_distribution.frontend.domain_name}" }
output "s3_bucket_name"     { value = aws_s3_bucket.frontend.id }
output "cloudfront_dist_id" { value = aws_cloudfront_distribution.frontend.id }
