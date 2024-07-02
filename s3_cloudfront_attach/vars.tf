

variable "aws_region" {
  default = ""
}

variable "bucket_name" {
  default = ""
}

variable "bucket_arn" {
  default = ""
}

variable "cloudfront_distribution_arn" {
  type = string
}

variable encrypt_bucket {
  default = true
}

variable encrypt_with_custom_kms {
  default = false
}
