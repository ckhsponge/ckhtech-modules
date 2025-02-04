

resource "aws_codepipeline" "main" {
  name     = "${var.service}-${var.environment}-${var.name}"
  pipeline_type = "V2" # V2 pipelines are billed $0.002/minute, V1 are $1/month
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = module.codepipline_bucket.bucket_name
    type     = "S3"
  }


  dynamic "stage" {
    for_each = [for repo in compact([var.github_repository_id]) : repo]

    content {
      name = "Source"

      action {
        name     = "source"
        category = "Source"
        owner    = "AWS"
        provider = "CodeStarSourceConnection"
        version  = "1"
        output_artifacts = ["source"]

        configuration = {
          FullRepositoryId     = stage.value
          BranchName           = var.github_branch
          ConnectionArn        = aws_codestarconnections_connection.github[0].arn
          DetectChanges        = var.detect_changes
          OutputArtifactFormat = "CODE_ZIP"
        }
      }
    }
  }


  dynamic "stage" {
    for_each = module.input_bucket

    content {
      name = "Source"

      action {
        name     = "source"
        category = "Source"
        owner    = "AWS"
        provider = "S3"
        version = "1"
        output_artifacts = ["source"]

        configuration = {
          S3Bucket             = stage.value.bucket_name
          S3ObjectKey          = var.repository_zip_filename
          PollForSourceChanges = false
        }
      }
    }
  }

  stage {
    name = "Build"

    dynamic "action" {
      for_each = length(aws_codebuild_project.ruby) > 0 ? [1] : []
      content {
        name     = "${local.canonical_name}-ruby"
        category = "Build"
        owner    = "AWS"
        provider = "CodeBuild"
        input_artifacts = ["source"]
        output_artifacts = ["source_ruby"]
        version = "1"
        #      run_order = "2"

        configuration = {
          ProjectName   = aws_codebuild_project.ruby[0].name
          PrimarySource = "source"
        }
      }
    }

    dynamic "action" {
      for_each = length(aws_codebuild_project.node) > 0 ? [1] : []
      content {
        name     = "${local.canonical_name}-node"
        category = "Build"
        owner    = "AWS"
        provider = "CodeBuild"
        input_artifacts = ["source"]
        output_artifacts = ["node_build"]
        version = "1"
        #      run_order = "2"

        configuration = {
          ProjectName   = aws_codebuild_project.node[0].name
          PrimarySource = "source"
        }
      }
    }
  }

  stage {
    name = "Deploy"

    dynamic "action" {
      for_each = length(aws_codebuild_project.combine) > 0 ? [1] : []
      content {
        name     = "${local.canonical_name}-combine"
        category = "Build"
        owner    = "AWS"
        provider = "CodeBuild"
        input_artifacts = ["source_ruby", "node_build"]
        version = "1"
        #      run_order = "2"

        configuration = {
          ProjectName   = aws_codebuild_project.combine[0].name
          PrimarySource = "source_ruby"
        }
      }
    }
  }
}

resource "aws_iam_role" "events_role" {
  name = "${local.canonical_name}-deployment-events-codepipeline"

  assume_role_policy = data.aws_iam_policy_document.events_assume_role.json
}

data "aws_iam_policy_document" "events_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "events_policy" {
  name   = "events-codebuild-policy"
  role   = aws_iam_role.events_role.id
  policy = data.aws_iam_policy_document.codepipeline_start_policy.json
}

data "aws_iam_policy_document" "codepipeline_start_policy" {
  statement {
    actions = [
      "codepipeline:StartPipelineExecution"
    ]
    effect = "Allow"
    resources = [
      aws_codepipeline.main.arn
    ]
  }
}
