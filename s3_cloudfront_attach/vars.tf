

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

variable "extra_path_arns" {
  description = "Additional path/CloudFront ARN pairs that get read access to a specific path prefix in the bucket."
  default     = []
  type = list(object({
    path             = string
    cloudfront_arn   = string
  }))
}
