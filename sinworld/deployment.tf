module deployment_pipeline {
  count                = var.create_deployment_pipeline ? 1 : 0
  source               = "../deployment"
  aws_region = var.aws_region
  #   codecommit_repository_name = ""
  environment          = var.environment
  lambda_function_name = module.sinatra.lambda_function_name
  s3_access_principals = var.deployment_s3_access_principals
  service              = var.service
  namespace            = var.namespace
  static_bucket_name   = length(module.static_bucket) > 0 ? module.static_bucket[0].bucket_name : ""
}
