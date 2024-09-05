locals {
  repository_zip_file = "repository.zip"
}

resource "aws_codepipeline" "main" {
  name     = "${var.service}-${var.environment}-${var.name}"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = module.codepipline_bucket.bucket_name
    type     = "S3"
  }

  # TODO: allow github source
  #   stage {
  #     name = "Source"
  #
  #     action {
  #       name             = "source"
  #       category         = "Source"
  #       owner            = "AWS"
  #       provider         = "CodeStarSourceConnection"
  #       version          = "1"
  #       output_artifacts = ["source"]
  #       #      run_order        = "1"
  #
  #       configuration = {
  #         FullRepositoryId     = local.github_repository
  #         BranchName           = var.github_branch
  #         ConnectionArn        = aws_codestarconnections_connection.github.arn
  #         DetectChanges        = var.webhooks_enabled
  #         OutputArtifactFormat = "CODE_ZIP"
  #       }
  #
  #     }
  #   }


  stage {
    name = "Source"

    action {
      name     = "source"
      category = "Source"
      owner    = "AWS"
      provider = "S3"
      version = "1"
      #       input_artifacts = ["${var.service}-build"]
      output_artifacts = ["source"]

      configuration = {
        S3Bucket             = module.input_bucket[0].bucket_name
        S3ObjectKey          = local.repository_zip_file
        PollForSourceChanges = false
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


resource "aws_cloudwatch_event_rule" "s3_event_rule" {
  name          = "${local.canonical_name}-deployment-codepipeline-start"
  description   = "Trigger CodePipeline when an S3 object is created"
  event_pattern = <<EOF
{
  "source": [
    "aws.s3"
  ],
  "detail-type": [
    "AWS API Call via CloudTrail"
  ],
  "detail": {
    "eventSource": ["s3.amazonaws.com"],
    "eventName": ["PutObject","CompleteMultipartUpload", "CopyObject"],
    "requestParameters": {
      "bucketName": ["${module.input_bucket[0].bucket_name}"],
      "key": ["${local.repository_zip_file}"]
    }
  }
}
EOF
}

resource "aws_cloudwatch_event_target" "codepipeline_target" {
  rule      = aws_cloudwatch_event_rule.s3_event_rule.name
  target_id = "${local.canonical_name}-deployment-codepipeline-target"
  arn       = aws_codepipeline.main.arn
  role_arn  = aws_iam_role.events_role.arn
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
