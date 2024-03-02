
variable domain_name {
  type = string
}

variable domain_name_route53_zone {
  default = ""
  description = "optional - use if zone is different than domain_name"
}

variable alternate_names {
  default = []
  description = "alternate domain names to add to certificate"
}

variable include_wildcard {
  default = true
  description = "adds *. as an additional name"
}
