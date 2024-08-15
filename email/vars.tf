
variable "aws_region" { type = string }

variable "environment" {
  default = ""
}

variable "service" {
  type = string
}

variable name {
  default = "main"
}

variable "namespace" {
  default = ""
}

variable "domain" {
  type = string
}

variable email_identities {
  default = []
}

variable forward_to {
  default = ""
}

variable from {
  default = ""
  description = "this is used in the From: field"
}
variable bucket_object_key_prefix {
  default = "inbox"
}
variable sns_enabled {
  default = false
}

#variable smtp_user {
#  default = ""
#}

variable encrypt_bucket {
  default = false
}

variable lambda_runtime {
  default = "python3.12"
}
