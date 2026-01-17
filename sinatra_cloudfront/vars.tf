
variable "aws_region" {
  type = string
}

variable origin_domain_name {
  default = "putyourrealdomainhere.com"
  description = "where cloudfront loads files from"
}

variable origin_is_s3 {
  default = false
}

#variable host_prefix {
#  type = string
#}

variable host_name {
  type = string
  description = "public host name serving the files"
}

variable additional_host_names {
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

//variable "vpc_id" {
//  default = ""
//}

#variable "vpc_name" {
#  default = "main"
#}
#
variable "service" {
  default = ""
}

variable "name" {
  default = ""
}
#
#variable "host_prefix" {
#  default = ""
#}
#
#variable "bucket_prefix" {
#  default = ""
#}
#
#variable "bucket_domain_base" {
#  default = ""
#}
#
#variable "domain_base" {
#  default = ""
#}

variable response_code_404 {
  default = "404"
}

variable response_page_path_404 {
  default = "/error.html"
}

#variable "additional_s3_policy_principals" {
#  default = []
#}

variable versioning_enabled {
  default = true
}

variable origin_path {
  default = ""
}

variable function_path_pattern {
  default = ""
}
variable function_code {
  default = ""
}
variable compress {
  default = true
}
variable default_root_object {
  default = "index.html"
}
variable allow_post {
  default = false
}
variable static_s3_origin_path_root {
  default = "/dist"
}
variable static_s3_origin_paths {
  default = []
}
variable static_s3_regional_domain_name {
  default = ""
}
variable files_s3_path_pattern {
  default = "files"
}
variable files_s3_origin_path {
  default = ""
}
variable has_files_bucket {
  default = false
}
variable files_s3_regional_domain_name {
  default = ""
}
variable has_files_failover {
  default = false
}
variable files_failover_domain_name {
  default = ""
}
variable cache_cookies {
  default = false
}
variable cache_query_string {
  default = false
}
variable forward_cookies {
  default = false
}
variable forward_query_string {
  default = false
}
variable "cors_origins" {
  default = ["*"]
}
variable default_ttl_main {
  default = 0
  description = "The ttl used by the default behavior"
}
variable default_ttl_static {
  default = 2592000 // 30 days
  description = "The ttl used by the static bucket"
}
variable default_ttl_files {
  default = 0 // is there a reason to cache files bucket ever?
  description = "The ttl used by the files bucket"
}
variable default_ttl_function {
  default = 0
  description = "The ttl used by functions"
}
variable max_ttl {
  default = 2592000 // 30 days
}
variable strict_transport_security_preload {
  default = true
  description = "domain and subdomain always use https"
}
variable additional_headers {
  default = []
}
variable has_websocket {
  default = false
}
variable websocket_domain_name {
  default = ""
}
