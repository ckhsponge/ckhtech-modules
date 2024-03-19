resource "aws_codecommit_repository" "main" {
  count = var.create_codecommit_repository ? 1 : 0
  repository_name = var.service
  description     = "${var.service} and associated resources"
}

module certificate {
  count = var.create_certificate ? 1 : 0
  source = "../certificate"
  domain_name = var.domain_root
}

resource "random_string" "session_secret" {
  length = 64
  special = false
  numeric = true
}

locals {
  from_email_address = var.email_address_from
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
#  host_name = var.domain_root
#  additional_host_names = var.redirect_host_names
#  redirect_to_host = var.host_name_primary
#}
#
#module email {
#  count = var.create_email_server ? 1 : 0
#  source = "../../modules/email"
#  aws_region = var.aws_region
#  service = var.service
#  domain = var.domain_root
#  email_sender = local.from_email_address
#  email_recipient = var.email_address_forward
#  sns_enabled = true
#  smtp_user = "${var.service}-smtp"
#  encrypt_bucket = var.encrypt_buckets
#}
#
