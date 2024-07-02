output "aws_cloudfront_distribution_arn" {
  value = aws_cloudfront_distribution.main.arn
}

output "aws_cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.main.id
}

output "aws_cloudfront_distribution_domain_name" {
  value = aws_cloudfront_distribution.main.domain_name
}

output "aws_cloudfront_distribution_aliases" {
  value = aws_cloudfront_distribution.main.aliases
}

output host_name {
  value = var.host_name
}

output static_s3_origin_path_root {
  value = var.static_s3_origin_path_root
}

#output aws_cloudfront_origin_access_identity_iam_arn {
#  value = aws_cloudfront_origin_access_identity.main.iam_arn
#}

#output access_control {
#  value = aws_cloudfront_origin_access_control.main.id
#}
