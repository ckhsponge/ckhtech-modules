locals {
  slack_commands_ruby = length(var.slack_webhook) > 0 ? [
    templatestring(local.slack_template, {
      message = "DEPLOY START ${local.canonical_name} *${var.environment}*"
    })
  ] : []
  buildspec_ruby = {
    version = "0.2"

    phases = {
      install = {
        runtime-versions = {
          ruby = "3.2.2"
        }
      }
      build = {
        commands = concat(
          local.slack_commands_ruby,
          var.build_commands_ruby
        )
      }
      post_build = {
        commands = ["echo Done"]
      }
    }

    artifacts = {
      base-directory = "$CODEBUILD_SRC_DIR/"
      files = ["**/*"]

      secondary-artifacts = {
        ruby = {
          base-directory = "$CODEBUILD_SRC_DIR/"
          files = ["**/*"]
          name           = "source_ruby"
        }
      }
    }
  }
}

resource "aws_codebuild_project" "ruby" {
  count         = 1
  name          = "${local.canonical_name}-ruby"
  build_timeout = 5

  source {
    type = "NO_SOURCE"
    buildspec = yamlencode(local.buildspec_ruby)
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
