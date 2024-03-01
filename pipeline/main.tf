data "aws_iam_policy_document" "webatspeed_pipeline_policy" {
  version = "2012-10-17"

  statement {
    principals {
      identifiers = [
        "codebuild.amazonaws.com",
        "codedeploy.amazonaws.com",
        "codepipeline.amazonaws.com"
      ]
      type = "Service"
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "webatspeed_pipeline_role" {
  name               = "${var.pipe_name}-role"
  assume_role_policy = data.aws_iam_policy_document.webatspeed_pipeline_policy.json

  tags = {
    Name = "${var.pipe_name}-role"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "random_id" "webatspeed_random_id_pipeline" {
  byte_length = 2
}

resource "aws_s3_bucket" "webatspeed_pipeline_bucket" {
  bucket        = "${var.pipe_name}-${random_id.webatspeed_random_id_pipeline.dec}"
  force_destroy = true
}

data "aws_iam_policy_document" "codepipeline_policy" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObjectAcl",
      "s3:PutObject",
      "s3:DeleteObject",
    ]

    resources = [
      aws_s3_bucket.webatspeed_pipeline_bucket.arn,
      "${aws_s3_bucket.webatspeed_pipeline_bucket.arn}/*"
    ]
  }

  statement {
    actions   = ["codestar-connections:UseConnection"]
    resources = [aws_codestarconnections_connection.webatspeed_connection.arn]
  }

  statement {
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name   = "codepipeline_policy"
  role   = aws_iam_role.webatspeed_pipeline_role.id
  policy = data.aws_iam_policy_document.codepipeline_policy.json
}

resource "aws_codestarconnections_connection" "webatspeed_connection" {
  name          = "webatspeed-connection"
  provider_type = "GitHub"
}

resource "aws_codepipeline" "webatspeed_pipeline" {
  name     = var.pipe_name
  role_arn = aws_iam_role.webatspeed_pipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.webatspeed_pipeline_bucket.id
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      category         = "Source"
      name             = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.webatspeed_connection.arn
        FullRepositoryId = "webatspeed/frontend"
        BranchName       = "main"
      }
    }
  }

  stage {
    name = "Build"

    action {
      category         = "Build"
      name             = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = "webatspeed"
      }
    }
  }
}
