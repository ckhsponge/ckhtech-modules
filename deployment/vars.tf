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

variable environment_variables {
  default = {}
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
    "cd app",
    <<-EOT
      ruby_version=$(awk 'NR == 1 { print $1 }' .ruby-version)
      installed_versions=$(rbenv versions --bare)
      if ! printf '%s\n' "$installed_versions" | grep -Fxq "$ruby_version"; then
        ruby_series=$(awk -F. 'NR == 1 { print $1 "." $2 }' .ruby-version)
        ruby_version=$(printf '%s\n' "$installed_versions" | awk -F. -v series="$ruby_series" '$1 "." $2 == series && /^[0-9]+\.[0-9]+\.[0-9]+$/' | sort -V | tail -n 1)
        if [ -z "$ruby_version" ]; then
          echo "No installed Ruby $ruby_series version found"
          exit 1
        fi
        rbenv local "$ruby_version"
        sed -i -E "s/^ruby ['\"][^'\"]+['\"]/ruby '$ruby_version'/" Gemfile
        # Refresh the locked Ruby version before enabling frozen deployment mode.
        BUNDLE_IGNORE_CONFIG=true BUNDLE_DEPLOYMENT=false BUNDLE_FROZEN=false BUNDLE_PATH=vendor/bundle BUNDLE_WITHOUT=development bundle update --ruby
      fi
    EOT
    ,
    "ruby -v",
    "bundle config set --local deployment true",
    "bundle config set --local path 'vendor/bundle'",
    "bundle config set --local without development",
    "bundle install",
    "bundle list",
    "cd .."
  ]
}

variable build_command_migrate {
  default = "echo 'not migrating'"
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

variable build_policy_arns {
  default = []
}
