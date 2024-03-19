variable "aws_region" { type = string }

variable "service" {
  type = string
}

variable "name" {
  default = "redirector"
}

variable "host_name" {
  default = ""
}

variable redirect_host_names {
  default = []
  type = list
}

variable response_code_404 {
  default = "404"
}
variable "response_page_path_404" {
  default = "/error.html"
}
variable "certificate_domain_name" {
  default = ""
}
variable "route53_domain_name" {
  default = ""
}

variable strict_transport_security_preload {
  default     = false
  description = "domain and subdomain always use https"
}
