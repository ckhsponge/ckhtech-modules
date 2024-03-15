
locals {
  domain_split = split(".",var.host_name)
  domain_name = join(".", slice(local.domain_split, length(local.domain_split) - 2, length(local.domain_split)))
  canonical_name = "${var.service}-${var.name}-sinatra"
}
