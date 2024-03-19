
locals {
  dynamodb_type_index_name = "type_created_at_index"
}
module dynamodb {
  count = var.create_dynamodb ? 1 : 0
  source = "../dynamodb"
  aws_region = var.aws_region
  service = var.service

  additional_global_secondary_indexes = [{
    name = local.dynamodb_type_index_name
    hash_key = "type"
    hash_key_type = "S"
    range_key = "created_at"
    range_key_type = "N"
  }]
}
