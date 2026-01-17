variable "aws_region" {
  type = string
}
variable service { type = string } # name of this service
variable name { default = "main" }
variable host_name { type = string } # app.mydomain.org
variable additional_host_names { default = [] }
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
variable files_bucket_public_path {
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
variable sinatra_handler {
  default = "sinatra_handler.SinatraHandler.handle"
}
variable lambda_memory_size {
  default = 1024
}
variable "lambda_runtime" {
  default = "ruby3.4"
}
variable task_lambda_functions {
  type = list(object({
    function_name=string,
    handler=string,
    crons=optional(list(object({rule_name=string, schedule_expression=string, input=string})), [])
  }))
  default = []
  description = "additional lambda functions defined by their handler e.g. task_handler.TaskHandler.handle"
}
variable cloudfront_additional_headers {
  description = "Hyphenated headers e.g. X-SLACK-SIGNATURE"
  default = []
}
variable create_websocket {
  default = false
}
variable websocket_handler {
  default = "sinatra_handler.SinatraHandler.handle"
}