module "cloudfront" {
  source = "../sinatra_cloudfront"

  aws_region              = var.aws_region
  service                 = var.service
  name                    = var.name
  origin_domain_name      = replace(replace(aws_apigatewayv2_stage.lambda.invoke_url, "https://", ""), "/", "")
  #aws_apigatewayv2_domain_name.main.domain_name_configuration[0].target_domain_name
  host_name               = var.host_name
  additional_host_names   = var.additional_host_names
  route53_domain_name     = var.route53_domain_name
  certificate_domain_name = var.certificate_domain_name
  default_ttl_main        = 0
  default_root_object     = ""
  allow_post              = true
  forward_cookies         = true
  forward_query_string    = true

  static_s3_origin_paths         = var.static_paths
  static_s3_regional_domain_name = var.static_bucket_regional_domain_name

  has_files_bucket              = var.has_files_bucket
  files_s3_regional_domain_name = var.files_bucket_regional_domain_name
  files_s3_path_pattern         = var.files_bucket_public_path
  has_files_failover            = var.has_files_failover
  files_failover_domain_name    = var.failover_lambda_invoke_domain_name
}
