module deployment_pipeline {
  # ensure lambdas are created first by depending on arns exist
  depends_on = [module.sinatra.lambda_function_arn, module.sinatra.lambda_task_function_arns]
  count                = var.create_deployment_pipeline ? 1 : 0
  source               = "../deployment"
  aws_region = var.aws_region
  #   codecommit_repository_name = ""
  environment          = var.environment
  lambda_function_names = concat([module.sinatra.lambda_function_name], module.sinatra.lambda_task_function_names)
  s3_access_principals = var.deployment_s3_access_principals
  service              = var.service
  namespace            = var.namespace
  static_bucket_name   = length(module.static_bucket) > 0 ? module.static_bucket[0].bucket_name : ""
  slack_webhook        = var.deployment_slack_webhook
}
