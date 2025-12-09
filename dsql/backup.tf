resource aws_backup_vault main {
  count = var.backup_retention_days > 0 ? 1 : 0
  name = "dsql-${local.name}"
}

resource aws_backup_vault copy {
  count    = var.backup_retention_days > 0 ? 1 : 0
  provider = aws.backup_region
  name     = "dsql-${local.name}-copy"
}

resource aws_backup_plan main {
  count = var.backup_retention_days > 0 ? 1 : 0
  name = "dsql-${local.name}"

  rule {
    rule_name         = "daily"
    target_vault_name = aws_backup_vault.main[0].name
    schedule          = var.backup_schedule

    lifecycle {
      delete_after = var.backup_retention_days
    }

    copy_action {
      destination_vault_arn = aws_backup_vault.copy[0].arn

      lifecycle {
        delete_after = var.backup_retention_days
      }
    }
  }
}

resource aws_backup_selection main {
  count        = var.backup_retention_days > 0 ? 1 : 0
  name         = "dsql-${local.name}"
  plan_id      = aws_backup_plan.main[0].id
  iam_role_arn = aws_iam_role.backup[0].arn

  resources = [
    aws_dsql_cluster.main.arn
  ]
}

resource aws_iam_role backup {
  count = var.backup_retention_days > 0 ? 1 : 0
  name = "dsql-${local.name}-backup"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "backup.amazonaws.com"
      }
    }]
  })
}

resource aws_iam_role_policy_attachment backup {
  count      = var.backup_retention_days > 0 ? 1 : 0
  role       = aws_iam_role.backup[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource aws_iam_role_policy_attachment restore {
  count      = var.backup_retention_days > 0 ? 1 : 0
  role       = aws_iam_role.backup[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}
