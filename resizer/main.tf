# the lambda layer lacks HEIC unless you use
# https://github.com/provenancetech/imagemagick-aws-lambda-2
# or https://github.com/ckhsponge/imagemagick-aws-lambda-2
# $ make install
# $ make deploy DEPLOYMENT_BUCKET=<YOUR BUCKET NAME>
# then update the layer that is used

locals {
  canonical_name = "${var.service}-${var.name}"
  all_host_names = [var.host_name]
}

locals {
  domain_split = split(".",var.host_name)
  domain_split_length = length(local.domain_split)
  domain_name = local.domain_split_length > 1 ? join(".",slice(local.domain_split, 1, local.domain_split_length)) : ""
  certificate_domain = length(var.certificate_domain_name) > 0 ? var.certificate_domain_name : local.domain_name
}

data aws_acm_certificate main {
  count = length(local.certificate_domain) > 0 ? 1 : 0
  domain = local.certificate_domain
}
