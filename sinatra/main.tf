data "aws_caller_identity" "current" {}

locals {
  domain_split = split(".", var.host_name)
  domain_base = join(".", slice(local.domain_split, length(local.domain_split) - 2, length(local.domain_split)))
  canonical_name = "${var.service}-${var.name}-sinatra"
  function_name  = local.canonical_name
}
