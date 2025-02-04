resource "aws_codestarconnections_connection" "github" {
  count = length(var.github_repository_id) > 0 ? 1 : 0
  name          = "${local.canonical_name}-github"
  provider_type = "GitHub"
}
