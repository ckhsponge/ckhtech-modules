locals {
  buildspec_combine = {
    version = "0.2"

    phases = {
      install = {
        runtime-versions = {
          ruby = "3.2.2"
        }
      }
      build = {
        # combine node build into public/static
        # zip files minus public/
        # update lambda with zip
        # push public files to bucket
        # TODO: delete old files in static bucket
        commands = [
          "rm -rf app/public/static",
          "mkdir -p app/public",
          "mv $CODEBUILD_SRC_DIR_node_build/static app/public",
          "mv $CODEBUILD_SRC_DIR_node_build/asset-manifest.json app/asset-manifest.json",
          "cd app && zip -r \"../app.zip\" . -x \"public/*\" -x \"*.git*\" && cd ..",
          "aws lambda update-function-code --function-name ${var.lambda_function_name} --zip-file fileb://\"app.zip\" --no-cli-pager",
          "aws s3 sync app/public/ s3://${var.static_bucket_name}/${var.static_bucket_path} --no-cli-pager"
        ]
      }
      post_build = {
        commands = ["echo Done"]
      }
    }
  }
}

resource "aws_codebuild_project" "combine" {
  count = 1
  name          = "${local.canonical_name}-combine"
  build_timeout = 5

  source {
    type      = "NO_SOURCE"
    buildspec = yamlencode(local.buildspec_combine)
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
