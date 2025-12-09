variable aws_region {
  type = string
}

variable environment {
  type = string
}

variable namespace {
  default = ""
}

variable name {
  default = "main"
}

variable deletion_protection {
  default = true
}

variable "tags" {
  description = "Tags to apply to the cluster"
  type        = map(string)
  default     = {}
}

variable backup_schedule {
  default = "cron(0 2 * * ? *)"
}

variable backup_retention_days {
  default = 0
}

variable backup_copy_region {
  type = string
}
