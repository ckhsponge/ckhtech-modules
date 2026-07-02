locals {
  slack_template         = "curl -X POST -H 'Content-type: application/json' --data '{\"text\":\"$${message}\"}' ${var.slack_webhook}"
  slack_commands_combine = length(var.slack_webhook) > 0 ? [templatestring(local.slack_template, { message = "DEPLOY COMPLETE ${local.canonical_name} *${var.environment}*" })] : []
  lambda_update_command = join("; ", [
    "update_lambda() { local name=$${1} log=/tmp/lambda_$${1}.log; echo \"Updating $${name}...\" | tee $${log}; aws lambda update-function-code --function-name \"$${name}\" --zip-file fileb://\"app.zip\" --no-cli-pager --query 'FunctionName' --output text >> $${log} 2>&1 && echo \"Done $${name}\" >> $${log} || { echo \"FAILED $${name}\" >> $${log}; return 1; }; }",
    "pids=()",
    "${join("; ", [for name in var.lambda_function_names : "update_lambda '${name}' > /tmp/lambda_${name}.log 2>&1 & pids+=($${!})"])}",
    "failed=0",
    "for pid in $${pids[@]}; do wait $${pid} || failed=1; done",
    "for name in ${join(" ", [for name in var.lambda_function_names : "'${name}'"])}; do cat /tmp/lambda_$${name}.log 2>/dev/null; done",
    "[ $${failed} -eq 0 ]"
  ])
  buildspec_combine = {
    version = "0.2"

    phases = {
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
            "${local.lambda_update_command}"
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
  build_timeout   = 15
  queued_timeout  = 30

  source {
    type = "NO_SOURCE"
    buildspec = yamlencode(local.buildspec_combine)
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/amazonlinux-x86_64-standard:6.0"
    type         = "LINUX_CONTAINER"
    // host_kernel    = "LINUX_KERNEL_LATEST" // NOT YET SUPPORTED :(
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
