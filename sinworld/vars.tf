variable "aws_region" { type = string }
variable "environment" {
  type = string
  description = "e.g. staging or production"
}

variable create_route53_zone { default = false }
variable create_codecommit_repository { default = false }
variable create_certificate { default = false }
variable create_email_server { default = false }
variable create_dsql { default = false }
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
variable email_inbound_method {
  default = "lambda"
  description = "lambda, external or none. If lambda, a lambda is created to forward emails to email_address_forward"
}
variable email_external_mx_records {
  default = ["fwd1.porkbun.com", "fwd2.porkbun.com"]
  description = "if email_inbound_method is external then use these mx records"
}
variable email_identities {
  type = list(string)
  default = []
  description = "additional email addresses that we can send from"
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
variable additional_host_names {
  type = list(string)
  default = []
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
variable lambda_memory_size {
  default = 1024
}
variable additional_lambda_policy_arns{
  type = list(string)
  default = []
}
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
variable task_lambda_functions {
  type = list(object({
    function_name=string,
    handler=string,
    crons=optional(list(object({rule_name=string, schedule_expression=string, input=string})), [])
  }))
  default = []
  description = "additional lambda functions defined by their function_name and handler e.g. task_handler.TaskHandler.handle"
}

variable dynamodb_additional_global_secondary_indexes {
  type = list(map(string))
  default = []
}

variable dynamodb_deletion_protection {
  default = true
}

variable dsql_deletion_protection {
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

variable job_queue_function_name {
  default = "job"
  description = "this value must exist in task_names, the jobs sqs calls a lambda based on this"
}

variable deployment_slack_webhook {
  default = ""
  description = "post deployment updates to this slack webhook"
}

variable deployment_repository_id {
  default = ""
  description = "the id of the repository to use for deployment e.g. ckhsponge/my-repo-name"
}

variable deployment_branch {
  default = ""
  description = "the branch to use for deployment"
}

variable deployment_node_build_directory {
  default = "build"
}

variable deployment_node_asset_manifest_filename {
  default = "asset-manifest.json"
}

variable deploy_node {
  default = true
}

variable resizer_sizes_by_name {
  default = null
  type = map(object({
    width  = optional(number)
    height = optional(number)
    scale  = optional(bool)
  }))

}

variable generate_activerecord_encryption {
  default = false
}