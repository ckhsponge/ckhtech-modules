resource "aws_codecommit_repository" "main" {
  count = var.create_codecommit_repository ? 1 : 0
  repository_name = var.service
  description     = "${var.service} and associated resources"
}
