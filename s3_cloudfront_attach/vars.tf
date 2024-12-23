

variable "aws_region" {
  default = ""
}

variable "bucket_name" {
  default = ""
}

variable "cloudfront_distribution_arns" {
  default = []
  type = list(string)
}

variable encrypt_bucket {
  default = true
}

variable encrypt_with_custom_kms {
  default = false
}
