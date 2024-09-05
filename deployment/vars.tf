variable "aws_region" {
  type = string
}
variable environment {
  type = string
}
variable service { type = string } # name of this service
variable name { default = "main" }

variable "lambda_function_name" {
  description = "The name of the Lambda function"
  type        = string
}

variable directory {
  description = "Directory to deploy"
  default     = "app"
}

variable branch {
  default = "main"
}
variable namespace {
 type = string
  description = "used when global naming is required e.g. for buckets, defaults to service if not present, hyphen delineated, no dots allowed, do not include environment"
}

variable s3_access_principals {
  default = []
  type = list(string)
}

variable static_bucket_name {
  default = ""
}

variable static_bucket_path {
  default = "dist"
}
