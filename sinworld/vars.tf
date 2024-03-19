variable "aws_region" { type = string }

variable create_codecommit_repository { default = true }
variable create_certificate { default = true }
variable create_email_server { default = true }
variable create_dynamodb { default = true }
variable create_static_bucket { default = true }
variable create_files_bucket { default = true }
variable create_files_resizer { default = true }

variable domain_base {
  default = ""
  description = "the base domain name e.g. staging.myspace.com"
}
variable domain_certificate {
  default = ""
  description = "domain name used for certificate, uses domain_base if not specified"
}
variable domain_route53_zone {
  default = ""
  description = "domain name used for route53 zone, uses domain_base if not specified"
}
variable email_address_from {
  default = ""
  description = "emails are sent from this address"
}
variable email_address_forward {
  default = ""
  description = "instead of imap, your inbound emails will be forwarded to this address"
}
variable redirect_host_names {
  default = []
}
variable host_name_resizer {
  default = ""
}

variable service { type = string } # name of this service
#variable name { default = "main" }
variable host_name { type = string } # app.mydomain.org
#variable host_name_resizer { default = "" } # resizer.mydomain.org
variable environment_name { default = "production" }
variable environment_variables { default = {} }
variable additional_lambda_policy_arns{ default = [] }
#variable import_certificate_arn { default = "" }

variable static_paths {
  default = ["images","javascripts","stylesheets","static"]
}

variable resizer_original_directory {
  default = "original"
}

variable resizer_source_directory {
  default = "uploads/images"
}

variable resizer_destination_directory {
  default = "files/images"
}

variable encrypt_buckets {
  default = true
}
