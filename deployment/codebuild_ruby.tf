locals {
  buildspec_ruby = <<-EOF
version: 0.2

phases:
  install:
    runtime-versions:
      ruby: 3.2.2
    commands:
      - echo CODEBUILD_SRC_DIR $CODEBUILD_SRC_DIR
      - gem install bundler
  pre_build:
    commands:
      - pwd
      - ls -l
      - bundle config set --local path '${var.directory}/vendor/bundle'
      - bundle config set --local without development
  build:
    commands:
      - bundle install
  post_build:
    commands:
      - pwd
      - ls -l
artifacts:
  base-directory: $CODEBUILD_SRC_DIR/
  files:
    - '**/*'

  secondary-artifacts:
    ruby:
      base-directory: $CODEBUILD_SRC_DIR/
      files:
        - '**/*'
      name: source_ruby
EOF
}

resource "aws_codebuild_project" "ruby" {
  count = 1
  name          = "${local.canonical_name}-ruby"
  build_timeout = 5

  source {
    type      = "NO_SOURCE"
    buildspec = local.buildspec_ruby
  }

  environment {
    compute_type = "BUILD_LAMBDA_1GB"
    image        = "aws/codebuild/amazonlinux-x86_64-lambda-standard:ruby3.2"
    type         = "LINUX_LAMBDA_CONTAINER"
    environment_variable {
      name  = "AWS_REGION"
      value = var.aws_region
    }
  }

  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    location = module.codepipline_bucket.bucket_name
    type     = "S3"
  }

}
