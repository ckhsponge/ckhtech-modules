locals {
  slack_template         = "curl -X POST -H 'Content-type: application/json' --data '{\"text\":\"$${message}\"}' ${var.slack_webhook}"
  slack_commands_combine = length(var.slack_webhook) > 0 ? [templatestring(local.slack_template, { message = "DEPLOY COMPLETE ${local.canonical_name} *${var.environment}*" })] : []
  lambda_update_command = join(" & ", [for name in var.lambda_function_names : "aws lambda update-function-code --function-name ${name} --zip-file fileb://\"app.zip\" --no-cli-pager"])
  buildspec_combine = {
    version = "0.2"

    phases = {
      install = {
        runtime-versions = {
          ruby = "3.4.2"
        }
      }
      build = {
        # combine node build into public/static
        # zip files minus public/
        # update lambda with zip
        # push public files to bucket
        # TODO: delete old files in static bucket
        commands = concat(
          [
            "rm -rf app/public/static",
            "mkdir -p app/public",
          ],
          length(aws_codebuild_project.node) > 0 ? [
            "mv $CODEBUILD_SRC_DIR_node_build/static app/public",
            "mv $CODEBUILD_SRC_DIR_node_build/${var.node_asset_manifest_filename} app/${var.node_asset_manifest_filename}",
          ] : [],
          [
            "cd app && zip -r \"../app.zip\" . -x \"public/*\" -x \"*.git*\" && cd .."
          ],
          [
            "${local.lambda_update_command} & wait"
          ],
          ["aws s3 sync app/public/ s3://${var.static_bucket_name}/${var.static_bucket_path} --no-cli-pager"],
          local.slack_commands_combine
        )
      }
      post_build = {
        commands = ["echo Done"]
      }
    }
  }
}

resource "aws_codebuild_project" "combine" {
  count         = 1
  name          = "${local.canonical_name}-combine"
  build_timeout = 5

  source {
    type = "NO_SOURCE"
    buildspec = yamlencode(local.buildspec_combine)
  }

  environment {
    compute_type = "BUILD_LAMBDA_1GB"
    image        = "aws/codebuild/amazonlinux-x86_64-lambda-standard:ruby3.4"
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
