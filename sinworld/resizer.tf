module resizer {
  count = var.create_files_resizer ? 1 : 0
  depends_on = [module.files_bucket, module.certificate]
  source = "../resizer"
  aws_region = var.aws_region
  service = var.service
  name = "resizer"
  host_name = coalesce([var.host_name_resizer,"resizer.${var.domain_base}"]...)
  files_bucket = module.files_bucket[0].bucket_name
  create_files_bucket = false # it's already been created (hopefully)
  create_cloudfront = var.create_files_resizer_cloudfront
  create_bucket_policy = false # this is done in s3_cloudfront_attach
  original_directory = var.resizer_original_directory
  source_directory = var.resizer_source_directory
  destination_directory = var.resizer_destination_directory
}
