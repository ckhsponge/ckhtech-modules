
module dsql {
  count = var.create_dsql ? 1 : 0
  source = "../dsql"
  
  providers = {
    aws.backup_region = aws.backup
  }
  
  aws_region = var.aws_region
  environment = var.environment
  namespace = var.service

  deletion_protection = var.dsql_deletion_protection
  backup_copy_region = var.backup_region
}
