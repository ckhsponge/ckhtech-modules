variable "aws_region" {
  type = string
}
variable environment {
  type = string
}
variable service { type = string }
# name of this service
variable name { default = "main" }

variable "lambda_function_names" {
  description = "The names of the Lambda functions that get updated"
  type        = list(string)
}

variable branch {
  default = "main"
}
variable namespace {
  type        = string
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

variable build_commands_ruby {
  default = [
    "gem install bundler",
    "bundle config set --local path 'app/vendor/bundle'",
    "bundle config set --local without development",
    "bundle install"
  ]
}

variable build_commands_node {
  default = [
    "npm install -g npm@latest",
    "node --version",
    "npm --version",
    "npm install --omit=dev",
    "npm run build"
  ]
}

variable repository_zip_filename {
   default = "repository.zip"
}
