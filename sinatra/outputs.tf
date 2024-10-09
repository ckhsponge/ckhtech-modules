#output excludes {
#  value = data.archive_file.lambda_file.excludes
#}

#output resizer_writer_policy_arn {
#  value = length(module.resizer) > 0 ? module.resizer[0].bucket_writer_policy_arn : ""
#}

output cloudfront_distribution_arn {
  value = module.cloudfront.aws_cloudfront_distribution_arn
}

output lambda_function_name {
  value = aws_lambda_function.sinatra.function_name
}

output lambda_function_arn {
  value = aws_lambda_function.sinatra.arn
}

output static_s3_origin_path_root {
  value = module.cloudfront.static_s3_origin_path_root
}

locals {
  task_function_names = [for t in aws_lambda_function.task : t.function_name]
}

output task_invoke_commands {
  value = formatlist( "aws lambda invoke --function-name %s --payload '{ \"type\": \"generate\", \"limit\": 1 }' --cli-binary-format raw-in-base64-out --invocation-type Event /dev/null", local.task_function_names)
}

output lambda_task_function_names {
  value = [for t in aws_lambda_function.task : t.function_name]
}

output lambda_task_function_names_by_task {
  value = {for k,v in aws_lambda_function.task : k => v.function_name}
}
