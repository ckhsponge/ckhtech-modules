output "bucket_domain_name" {
  value = aws_s3_bucket.main.bucket_domain_name
}

output "bucket_name" {
  value = aws_s3_bucket.main.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.main.arn
}

// use this with cloudfront
output "bucket_regional_domain_name" {
  value = aws_s3_bucket.main.bucket_regional_domain_name
}

#output kms_key_arn {
#  value = length(aws_kms_key.main) > 0 ? aws_kms_key.main[0].arn : var.kms_key_arn
#}
#
#output writer_policy_arn {
#  value = length(aws_iam_policy.writer) > 0 ? aws_iam_policy.writer[0].arn : ""
#}
#
#output reader_policy_arn {
#  value = length(aws_iam_policy.reader) > 0 ? aws_iam_policy.reader[0].arn : ""
#}
