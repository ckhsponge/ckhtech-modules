
locals {
  email_address_from = join("@",compact([var.email_address_sender,var.email_address_domain]))
  email_address_sender = var.email_address_sender
  email_address_domain = var.email_address_domain
}

module email {
  source = "../email"
  count = var.create_email_server ? 1 : 0

  aws_region = var.aws_region
  environment = var.environment
  service    = var.service
  namespace = var.namespace
  domain     = var.email_address_domain
  from = local.email_address_from
  forward_to = var.email_address_forward
}
