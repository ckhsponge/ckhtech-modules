resource "random_string" "session_secret" {
  length  = 64
  special = false
  numeric = true
}

locals {
  # connect all the applicable services to the lambda environment
  lamda_environment_variables = merge(
    var.environment_variables,
    {
      APP_ENV        = var.environment_name,
      RACK_ENV       = var.environment_name
      SESSION_SECRET = random_string.session_secret.result
    },
    length(local.from_email_address) > 0 ? { FROM_EMAIL_ADDRESS = local.from_email_address } : {},
    length(module.files_bucket) > 0 ? { FILES_BUCKET = module.files_bucket[0].bucket_name } : {},
    length(module.resizer) > 0 ? {
      RESIZER_ORIGINAL_DIRECTORY    = module.resizer[0].original_directory
      RESIZER_SOURCE_DIRECTORY      = module.resizer[0].source_directory
      RESIZER_DESTINATION_DIRECTORY = module.resizer[0].destination_directory
    } : {},
    length(module.dynamodb) > 0 ? {
      GSI_STRING_COUNT         = module.dynamodb[0].global_secondary_indexes_string_count
      GSI_NUMBER_COUNT         = module.dynamodb[0].global_secondary_indexes_number_count
      DYNAMODB_TABLE_NAME      = module.dynamodb[0].table_name
      DYNAMODB_REGION          = module.dynamodb[0].aws_region
      DYNAMODB_TYPE_INDEX_NAME = local.dynamodb_type_index_name
    } : {}
  )
  additional_lambda_policy_arns = concat(
    var.additional_lambda_policy_arns,
    length(module.files_bucket) > 0 ? [module.files_bucket[0].writer_policy_arn] : [],
    length(module.dynamodb) > 0 ? [module.dynamodb[0].writer_policy_arn] : [],
    #    length(module.email) > 0 ? [module.email[0].sender_policy_arn] : []
  )
}

module sinatra {
  depends_on = [
    module.certificate,
    #    local_file.asset_manifest
  ]
  source                  = "../sinatra"
  aws_region              = var.aws_region
  service                 = var.service
  host_name               = var.host_name
  certificate_domain_name = local.domain_certificate
  route53_domain_name     = compact([var.domain_route53_zone,var.domain_base])[0]
  environment_variables   = local.lamda_environment_variables
  #  additional_lambda_policy_json = data.aws_iam_policy_document.static.json

  lambda_filename  = data.archive_file.lambda_file.output_path
  source_code_hash = data.archive_file.lambda_file.output_base64sha256

  has_static_bucket                  = var.create_static_bucket
  static_bucket_regional_domain_name = length(module.static_bucket) > 0 ? module.static_bucket[0].bucket_regional_domain_name : ""
  static_paths                       = var.static_paths
  has_files_bucket                   = var.create_files_bucket
  files_bucket_regional_domain_name  = length(module.files_bucket) > 0 ? module.files_bucket[0].bucket_regional_domain_name : ""
  files_bucket_name                  = length(module.files_bucket) > 0 ? module.files_bucket[0].bucket_name : ""
  has_files_failover                 = var.create_files_resizer
  failover_lambda_invoke_domain_name = length(module.resizer) > 0 ? module.resizer[0].lambda_invoke_domain_name : ""

  additional_lambda_policy_arns = local.additional_lambda_policy_arns
}
