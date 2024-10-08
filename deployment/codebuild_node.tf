locals {
  buildspec_node = {
    version = "0.2"

    phases = {
      install = {
        runtime-versions = {
          node = 20
        }
      }
      build = {
        commands = var.build_commands_node
      }
      post_build = {
        commands = ["echo Done"]
      }
    }

    artifacts = {
      base-directory = "$CODEBUILD_SRC_DIR/build/"
      files = ["**/*"]
    }
  }
}



resource "aws_codebuild_project" "node" {
  count = 1
  name          = "${local.canonical_name}-node"
  build_timeout = 5

  source {
    type      = "NO_SOURCE"
    buildspec = yamlencode(local.buildspec_node)
  }

  environment {
    compute_type = "BUILD_LAMBDA_2GB"
    image        = "aws/codebuild/amazonlinux-x86_64-lambda-standard:nodejs20"
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
