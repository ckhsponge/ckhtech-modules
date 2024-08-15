



locals {
  namespace = coalesce(var.namespace, var.service)
}

#resource local_file asset_manifest {
#  content = file("${path.module}/../../../build/asset-manifest.json")
#  filename = "${path.module}/../../../app/asset-manifest.json"
#}

#module cloudfront_redirect {
#  count = length(var.redirect_host_names) > 0 ? 1 : 0
#  depends_on = [module.certificate]
#  source = "../../modules/cloudfront_redirect"
#
#  aws_region = var.aws_region
#  service = var.service
#  redirect_host_names = var.redirect_host_names
#  redirect_to_host = var.host_name
#}
#
#module email {
#  count = var.create_email_server ? 1 : 0
#  source = "../../modules/email"
#  aws_region = var.aws_region
#  service = var.service
#  domain = var.domain_base
#  email_sender = local.from_email_address
#  email_recipient = var.email_address_forward
#  sns_enabled = true
#  smtp_user = "${var.service}-smtp"
#  encrypt_bucket = var.encrypt_buckets
#}
#
