module resizer {
  count = var.create_files_resizer ? 1 : 0
  depends_on = [module.files_bucket, module.certificate]
  source = "../resizer"
  aws_region = var.aws_region
  service = var.service
  host_name = length(var.host_name_resizer) > 0 ? var.host_name_resizer : "resizer.${var.domain_base}"
  files_bucket = module.files_bucket[0].bucket_name
  create_cloudfront = false
  original_directory = var.resizer_original_directory
  source_directory = var.resizer_source_directory
  destination_directory = var.resizer_destination_directory
}
