variable "aws_region" { type = string }
variable "environment" {
  type = string
  description = "e.g. staging or production"
}

variable create_route53_zone { default = false }
variable create_codecommit_repository { default = false }
variable create_certificate { default = false }
variable create_email_server { default = false }
variable create_dynamodb { default = false }
variable create_static_bucket { default = false }
variable create_files_bucket { default = false }
variable create_files_resizer { default = false }
variable create_files_resizer_cloudfront {
  default = true
  description = "if creating a files_resizer, create it in it's own Cloudfront. Otherwise, attach it to the Sinatra Cloudfront."
}
variable create_deployment_pipeline { default = false }
variable create_job_queue   { default = false }

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
variable email_address_domain {
  default = ""
  description = "emails are sent and received from this address"
}
variable email_address_sender {
  default = ""
  description = "emails are sent from this address, should NOT include @domain"
}
variable email_address_forward {
  default = ""
  description = "instead of imap, your inbound emails will be forwarded to this address"
}
variable redirect_host_names {
  default = []
  type = list
}
variable host_name_resizer {
  default = ""
}

variable service {
  type = string
  description = "name of this service"
}
variable namespace {
  default = ""
  description = "used when global naming is required e.g. for buckets, defaults to service if not present, hyphen delineated, no dots allowed, do not include environment"
}
variable host_name {
  type = string
  description = "app.mydomain.org or *.mydomain.org"
}
variable host_name_primary {
  default = ""
  description = "defaults to host_name if blank, needed by redirector if host_name has wildcard"
}
#variable host_name_resizer { default = "" } # resizer.mydomain.org
variable sinatra_environment {
  default = ""
  description = "e.g. production, uses environment if blank"
}
variable environment_variables {
  type = map(string)
  default = {}
}
variable additional_lambda_policy_arns{ default = [] }
#variable import_certificate_arn { default = "" }

variable static_paths {
  type = list(string)
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
variable task_names {
  type = list(string)
  default = []
}
variable dynamodb_additional_global_secondary_indexes {
  type = list(map(string))
  default = []
}

variable dynamodb_deletion_protection {
  default = true
}

variable files_bucket_public_path {
  default = ""
  description = "set this to 'files' or another path to expose that directory publicly through cloudfront"
}

variable deployment_s3_access_principals {
  default = []
  type = list(string)
}

variable job_queue_task_name {
  default = "job"
  description = "this value must exist in task_names, the jobs sqs calls a lambda based on this"
}

variable deployment_slack_webhook {
  default = ""
  description = "post deployment updates to this slack webhook"
}
