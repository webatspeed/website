data "local_file" "buildspec_frontend" {
  filename = "${path.module}/specs/frontend.yml"
}

resource "aws_codebuild_project" "webatspeed_build_frontend" {
  name         = "webatspeed-frontend"
  service_role = var.pipeline_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/amazonlinux2-aarch64-standard:3.0"
    type            = "ARM_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "DOCKER_USER"
      value = var.docker_user
    }

    environment_variable {
      name  = "DOCKER_PASS"
      value = var.docker_pass
    }

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = "webatspeed/webatspeed-fe"
    }

    environment_variable {
      name  = "SUBSCRIPTION_URL"
      value = var.subscription_url
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name = var.cloudwatch_group
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = data.local_file.buildspec_frontend.content
  }
}

data "local_file" "buildspec_subscription" {
  filename = "${path.module}/specs/subscription.yml"
}

resource "aws_codebuild_project" "webatspeed_build_subscription" {
  name         = "webatspeed-subscription"
  service_role = var.pipeline_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "DOCKER_USER"
      value = var.docker_user
    }

    environment_variable {
      name  = "DOCKER_PASS"
      value = var.docker_pass
    }

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = "webatspeed/subscription-service"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name = var.cloudwatch_group
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = data.local_file.buildspec_subscription.content
  }
}
