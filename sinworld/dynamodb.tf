
locals {
  dynamodb_type_index_name = "type_created_at_index"
}
module dynamodb {
  count = var.create_dynamodb ? 1 : 0
  source = "../dynamodb"
  aws_region = var.aws_region
  environment = var.environment
  service = var.service

  additional_global_secondary_indexes = var.dynamodb_additional_global_secondary_indexes
  deletion_protection = var.dynamodb_deletion_protection
}
