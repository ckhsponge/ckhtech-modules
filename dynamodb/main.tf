locals {
  table_name = "${var.service}.${var.name}.${var.environment}"
  additional_attributes = length(var.additional_global_secondary_indexes) == 0 ? [] : flatten(
    [for g in var.additional_global_secondary_indexes : [
      {
        name = g.hash_key
        type = g.hash_key_type
      }, {
        name = g.range_key
        type = g.range_key_type
      }
    ]]
  )

  string_indexes = [for i in range(var.global_secondary_indexes_string_count) : {
    name = "string_index${i}"
    hash_key = "string_hash_key${i}"
    hash_key_type = "S"
    range_key = "string_range_key${i}"
    range_key_type = "S"
  }]
  string_index_attributes = flatten([for s in local.string_indexes : [{
    name = s.hash_key
    type = s.hash_key_type
  }, {
    name = s.range_key
    type = s.range_key_type
  },
  ]])

  number_indexes = [for i in range(var.global_secondary_indexes_number_count) : {
    name = "number_index${i}"
    hash_key = "number_hash_key${i}"
    hash_key_type = "S"
    range_key = "number_range_key${i}"
    range_key_type = "N"
  }]
  number_index_attributes = flatten([for s in local.number_indexes : [{
    name = s.hash_key
    type = s.hash_key_type
  }, {
    name = s.range_key
    type = s.range_key_type
  },
  ]])

  hash_key_attribute = {name = var.hash_key, type = "S"}
  attributes = flatten([local.hash_key_attribute,local.additional_attributes,local.string_index_attributes,local.number_index_attributes])
  global_secondary_indexes = flatten([var.additional_global_secondary_indexes, local.string_indexes, local.number_indexes])
}

resource aws_dynamodb_table main {
  name = local.table_name
  hash_key = var.hash_key
#  range_key = var.range_key
  billing_mode = "PAY_PER_REQUEST"
  stream_enabled = length(var.replica_regions) > 0
  stream_view_type = "NEW_AND_OLD_IMAGES"

  deletion_protection_enabled = var.deletion_protection

  dynamic attribute {
    for_each = local.attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  dynamic global_secondary_index {
    for_each = local.global_secondary_indexes
    content {
      name = global_secondary_index.value.name
      hash_key = global_secondary_index.value.hash_key
      range_key = global_secondary_index.value.range_key
      projection_type = "ALL"
      read_capacity = 0
      write_capacity = 0
    }
  }

  dynamic replica {
    for_each = var.replica_regions
    content {
      point_in_time_recovery = true
      region_name = replica.value
    }
  }

  server_side_encryption {
    enabled = true
  }

  point_in_time_recovery {
    enabled = true
  }
}

data aws_caller_identity main {}

data aws_iam_policy_document writer {
  statement {
    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:Scan",
      "dynamodb:Query",
      "dynamodb:UpdateItem",
      "dynamodb:DescribeTable",
      "dynamodb:CreateTable"
    ]
    resources = [
      aws_dynamodb_table.main.arn,
      "${aws_dynamodb_table.main.arn}/index/*"
    ]
  }
  statement {
    actions = [
      "dynamodb:ListTables"
    ]
    resources = [
      "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.main.account_id}:table/*"
    ]
  }
}

resource aws_iam_policy writer {
  name = "dynamodb-${aws_dynamodb_table.main.name}-writer"
  path = "/"
  description = "Write to dynamodb ${aws_dynamodb_table.main.name}"
  policy = data.aws_iam_policy_document.writer.json
}
