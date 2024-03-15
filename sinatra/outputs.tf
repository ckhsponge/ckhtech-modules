#output excludes {
#  value = data.archive_file.lambda_file.excludes
#}

#output resizer_writer_policy_arn {
#  value = length(module.resizer) > 0 ? module.resizer[0].bucket_writer_policy_arn : ""
#}

output cloudfront_distribution_arn {
  value = module.cloudfront.aws_cloudfront_distribution_arn
}
