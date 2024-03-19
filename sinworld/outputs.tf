output codecommit_repository_clone_url_ssh {
  value = length(aws_codecommit_repository.main) > 0 ? aws_codecommit_repository.main[0].clone_url_ssh : ""
}

output url {
  value = "https://${var.host_name}"
}

output zip_command {
  value = "cd app && zip -r ../app.zip *"
}

output publish_command {
  value = "aws lambda update-function-code --function-name ${module.sinatra.lambda_function_name} --publish --zip-file fileb://app.zip"
}

output put_public_command {
  value = length(module.static_bucket) > 0 ? "aws s3 sync app/public/ s3://${module.static_bucket[0].bucket_name}${module.sinatra.static_s3_origin_path_root}/" : ""
}

#output route53_zone_name_servers {
#  value = length(aws_route53_zone.main) > 0 ? aws_route53_zone.main[0].name_servers : []
#}
#
#output smtp_username {
#  value = length(module.email) > 0 ? module.email[0].smtp_username : ""
#}
#
#output smtp_password {
#  value = length(module.email) > 0 ? module.email[0].smtp_password : ""
#}
#
#output smtp_endpoint {
#  value = length(module.email) > 0 ? module.email[0].smtp_endpoint : ""
#}
#
#
