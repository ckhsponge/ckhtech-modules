variable "aws_region" {
  type = string
}
variable service { type = string } # name of this service
variable name { default = "main" }
variable host_name { type = string } # app.mydomain.org
variable host_name_resizer { default = "" } # resizer.mydomain.org
variable environment_name { default = "production" }
variable environment_variables { default = {} }
variable additional_lambda_policy_arns{ default = [] }
variable lambda_filename { default = "" }
variable source_code_hash { default = "" }
#variable import_certificate_arn { default = "" }


#variable resizer_original_directory {
#  default = "original"
#}
#
#variable resizer_source_directory {
#  default = "uploads/images"
#}
#
#variable resizer_destination_directory {
#  default = "files/images"
#}

variable static_bucket_regional_domain_name {
  default = ""
}
variable has_files_bucket {
  default = false
}
variable files_bucket_name {
  default = ""
}
variable files_bucket_regional_domain_name {
  default = ""
}
variable has_files_failover {
  default = false
}
variable failover_lambda_invoke_domain_name {
  default = ""
}
variable has_static_bucket {
  default = false
}
variable static_paths {
  default = []
}
variable route53_domain_name {
  default = ""
  description = "needed if route53 zone is different from root of host name"
}
variable certificate_domain_name {
  default = ""
  description = "needed if certificate is different from root of host name"
}
