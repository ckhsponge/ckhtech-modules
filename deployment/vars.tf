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
    "rbenv versions",
    "ruby -v",
    "gem install bundler",
    "bundle config set --local path 'app/vendor/bundle'",
    "bundle config set --local without development",
    "bundle install"
  ]
}

variable npm_version {
  default = "10.9.2"
}

variable build_commands_node {
  default = []
}

variable repository_zip_filename {
   default = "repository.zip"
}

variable slack_webhook {
  default = ""
}

variable detect_changes {
  default = true
}

variable github_repository_id {
  default = ""
}

variable github_branch {
  default = ""
}

variable node_build_directory {
  default = "build"
}

variable node_asset_manifest_filename {
  default = "asset-manifest.json"
}

variable deploy_node {
  default = true
}