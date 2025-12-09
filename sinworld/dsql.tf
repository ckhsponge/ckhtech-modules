
module dsql {
  count = var.create_dsql ? 1 : 0
  source = "../dsql"
  
  providers = {
    aws.backup = aws.backup
  }
  
  aws_region = var.aws_region
  environment = var.environment
  namespace = var.service

  deletion_protection = var.dsql_deletion_protection
  backup_retention_days = var.dsql_backup_retention_days
  backup_schedule = var.dsql_backup_schedule
}
