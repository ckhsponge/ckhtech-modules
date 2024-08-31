output aws_region {
  value = var.aws_region
}

output table_name {
  value = aws_dynamodb_table.main.name
}

output table_name_without_namespace {
  value = local.table_name_without_namespace
}

output table_name_namespace {
  value = local.table_name_namespace
}

output table_arn {
  value = aws_dynamodb_table.main.arn
}

output global_secondary_indexes_string_count {
  value = var.global_secondary_indexes_string_count
}

output global_secondary_indexes_number_count {
  value = var.global_secondary_indexes_number_count
}

output hash_key {
  value = aws_dynamodb_table.main.hash_key
}

output writer_policy_arn {
  value = aws_iam_policy.writer.arn
}

output writer_policy_name {
  value = aws_iam_policy.writer.name
}
