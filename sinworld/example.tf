
locals {
  app_zip = "app.zip"
  source_dir = "${path.module}/app"
  output_path = "${path.module}/${local.app_zip}"
}

data "archive_file" "lambda_file" {
  type = "zip"

  source_dir  = local.source_dir
  excludes = fileset("${path.module}/app","public/**")
  output_path = local.output_path
}

