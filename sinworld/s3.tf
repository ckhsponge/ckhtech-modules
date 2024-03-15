locals {
  bucket_prefix = join("-",reverse(split(".",var.host_name)))
#  public_bucket_name = "${var.service}-public-${local.bucket_suffix}"
#  files_bucket_name = "${var.service}-files-${local.bucket_suffix}"
  #  private_bucket_regional_domain_name = "${local.private_bucket_name}.s3.amazonaws.com"
}

module static_bucket {
  count = var.create_static_bucket ? 1 : 0
  source = "../s3"
  aws_region = var.aws_region
  bucket_name = "${local.bucket_prefix}-static"
}

module static_bucket_encryption {
  count = length(module.static_bucket)
  source = "../s3_cloudfront_attach"
  bucket_name = module.static_bucket[count.index].bucket_name
  bucket_arn = module.static_bucket[count.index].bucket_arn
  cloudfront_distribution_arn = module.sinatra.cloudfront_distribution_arn
  encrypt_bucket = var.encrypt_buckets
}

module files_bucket {
  count = var.create_files_bucket || var.create_files_resizer ? 1 : 0
  source = "../s3"

  bucket_name = "${local.bucket_prefix}-files"
  create_writer_policy = true
}

module files_bucket_encryption {
  count = length(module.files_bucket)
  source = "../s3_cloudfront_attach"
  bucket_name = module.files_bucket[count.index].bucket_name
  bucket_arn = module.files_bucket[count.index].bucket_arn
  cloudfront_distribution_arn = module.sinatra.cloudfront_distribution_arn
  encrypt_bucket = var.encrypt_buckets
}
