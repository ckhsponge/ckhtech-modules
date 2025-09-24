resource "random_string" "session_secret" {
  length  = 64
  special = false
  numeric = true
}

locals {
  app_env = coalesce([var.sinatra_environment, var.environment]...)
  rack_env = local.app_env
  # connect all the applicable services to the lambda environment
  lamda_environment_variables = merge(
    var.environment_variables,
    {
      APP_ENV        = local.app_env
      RACK_ENV       = local.rack_env
      SESSION_SECRET = random_string.session_secret.result
    },
      length(module.files_bucket) > 0 ? { FILES_BUCKET = module.files_bucket[0].bucket_name } : {},
      length(module.resizer) > 0 ? {
      RESIZER_ORIGINAL_DIRECTORY    = module.resizer[0].original_directory
      RESIZER_SOURCE_DIRECTORY      = module.resizer[0].source_directory
      RESIZER_DESTINATION_DIRECTORY = module.resizer[0].destination_directory
    } : {},
      var.create_files_resizer_cloudfront && length(module.resizer) > 0 ? {
      RESIZER_DOMAIN = module.resizer[0].host_name
    } : {},
      length(local.email_address_from) > 0 ? {
      EMAIL_ADDRESS_FROM   = local.email_address_from
      EMAIL_ADDRESS_SENDER = local.email_address_sender
      EMAIL_ADDRESS_DOMAIN = local.email_address_domain
    } : {},
      length(module.dsql) > 0 ? {
      DATABASE_URL  = module.dsql[0].url
      DATABASE_HOST = module.dsql[0].host
    } : {},
      length(module.dynamodb) > 0 ? {
      GSI_STRING_COUNT         = module.dynamodb[0].global_secondary_indexes_string_count
      GSI_NUMBER_COUNT         = module.dynamodb[0].global_secondary_indexes_number_count
      DYNAMODB_NAMESPACE       = module.dynamodb[0].table_name_namespace
      DYNAMODB_TABLE_NAME = module.dynamodb[0].table_name_without_namespace
      #       DYNAMODB_TABLE_NAME      = module.dynamodb[0].table_name
      DYNAMODB_REGION          = module.dynamodb[0].aws_region
      DYNAMODB_TYPE_INDEX_NAME = local.dynamodb_type_index_name
    } : {},
      length(aws_sqs_queue.job) > 0 ? {
      JOB_AWS_SQS_URL = aws_sqs_queue.job[0].url
    } : {}
  )
  additional_lambda_policy_arns = concat(
    var.additional_lambda_policy_arns,
      length(module.files_bucket) > 0 ? [module.files_bucket[0].writer_policy_arn] : [],
      length(module.dsql) > 0 ? [module.dsql[0].writer_policy_arn] : [],
      length(module.dynamodb) > 0 ? [module.dynamodb[0].writer_policy_arn] : [],
      length(module.email) > 0 ? [module.email[0].sender_policy_arn] : [],
      length(aws_iam_policy.job_sqs_policy) > 0 ? [aws_iam_policy.job_sqs_policy[0].arn] : [],
      [aws_iam_policy.cloudwatch_put_metric_data_policy.arn]
  )

  sinatra_expose_files = var.create_files_bucket && length(var.files_bucket_public_path) > 0
  # should a resizer be attached to the Sinatra Cloudfront
  sinatra_attach_resizer = local.sinatra_expose_files && length(module.resizer) > 0 && var.create_files_resizer && !var.create_files_resizer_cloudfront
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
  additional_host_names   = var.additional_host_names
  certificate_domain_name = local.domain_certificate
  route53_domain_name     = local.domain_route53_zone
  environment_variables = local.lamda_environment_variables
  #  additional_lambda_policy_json = data.aws_iam_policy_document.static.json

  lambda_filename    = data.archive_file.lambda_file.output_path
  source_code_hash   = data.archive_file.lambda_file.output_base64sha256
  lambda_memory_size = var.lambda_memory_size

  has_static_bucket                  = var.create_static_bucket
  static_bucket_regional_domain_name = (length(module.static_bucket) > 0 ? module.static_bucket[0].bucket_regional_domain_name : "")
  static_paths                      = var.static_paths
  has_files_bucket                  = local.sinatra_expose_files
  files_bucket_regional_domain_name = (local.sinatra_expose_files ? module.files_bucket[0].bucket_regional_domain_name : "")
  files_bucket_name                  = local.sinatra_expose_files ? module.files_bucket[0].bucket_name : ""
  files_bucket_public_path           = var.files_bucket_public_path
  has_files_failover                 = local.sinatra_attach_resizer
  failover_lambda_invoke_domain_name = local.sinatra_attach_resizer ? module.resizer[0].lambda_invoke_domain_name : ""

  additional_lambda_policy_arns = local.additional_lambda_policy_arns
  task_lambda_functions = var.task_lambda_functions
}
