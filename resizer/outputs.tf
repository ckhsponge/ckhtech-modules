output "cloudfront_distribution_arn" {
  value = local.cloudfront_distribution_arn
}

output lambda_invoke_url {
  value = aws_apigatewayv2_stage.lambda.invoke_url
}

output lambda_invoke_domain_name {
  value = replace(replace(aws_apigatewayv2_stage.lambda.invoke_url,"https://",""),"/","")
}

output original_directory {
  value = var.original_directory
}

output source_directory {
  value = var.source_directory
}

output destination_directory {
  value = var.destination_directory
}

output host_name {
  value = var.host_name
}

output files_bucket {
  value = data.aws_s3_bucket.files.bucket
}

output example_source_url {
  value = var.create_example_file ? "s3://${aws_s3_object.possum[0].bucket}/${aws_s3_object.possum[0].key}" : ""
}

output example_resized_url {
  value = "https://${var.host_name}/${var.destination_directory}/${local.example_image_id}/${keys(var.sizes_by_name)[0]}.webp" // TODO use var.sizes_by_name[0]
}

