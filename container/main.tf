resource "aws_ecs_cluster" "webatspeed_cluster" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = var.enable_insights ? "enabled" : "disabled"
  }
}

resource "aws_cloudwatch_log_group" "webatspeed_log_group" {
  name = format("%s-logs", var.cluster_name)

  tags = {
    Application = var.cluster_name
  }
}

data "aws_iam_policy_document" "ecs_task_execution_role" {
  version = "2012-10-17"

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}

resource "aws_ecs_task_definition" "webatspeed_task_mongodb" {
  family                   = "mongodb"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = templatefile("${path.module}/task-definitions/mongodb.json", {
    username = var.db_user
    password = var.db_password
  })

  volume {
    name = "mongodb-volume"

    efs_volume_configuration {
      file_system_id     = var.file_system_id
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = var.file_system_access_id
      }
    }
  }

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }
}

resource "aws_ecs_service" "webatspeed_service_mongodb" {
  cluster         = aws_ecs_cluster.webatspeed_cluster.id
  name            = aws_ecs_task_definition.webatspeed_task_mongodb.family
  task_definition = aws_ecs_task_definition.webatspeed_task_mongodb.arn
  launch_type     = "FARGATE"
  desired_count   = var.count_mongodb

  network_configuration {
    security_groups = var.mongodb_sg
    subnets         = var.private_subnet_ids
  }
}

resource "aws_ecs_task_definition" "webatspeed_task_frontend" {
  family                   = "frontend"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = templatefile("${path.module}/task-definitions/frontend.json", {
    port = var.lb_port
  })

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

resource "aws_ecs_service" "webatspeed_service_frontend" {
  cluster         = aws_ecs_cluster.webatspeed_cluster.id
  name            = aws_ecs_task_definition.webatspeed_task_frontend.family
  task_definition = aws_ecs_task_definition.webatspeed_task_frontend.arn
  launch_type     = "FARGATE"
  desired_count   = var.count_frontend

  network_configuration {
    security_groups = [var.frontend_sg]
    subnets         = var.private_subnet_ids
  }

  load_balancer {
    target_group_arn = var.lb_target_group_arn
    container_name   = aws_ecs_task_definition.webatspeed_task_frontend.family
    container_port   = var.lb_port
  }
}

resource "aws_ecs_task_definition" "webatspeed_task_subscription" {
  family                   = "subscription"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = templatefile("${path.module}/task-definitions/subscription.json", {
    port           = var.port
    mongo-username = var.db_user
    mongo-password = var.db_password
    ses-username   = var.ses_username
    ses-password   = var.ses_password
    region         = var.region
    bucket         = var.bucket
    email          = var.email
  })

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

resource "aws_ecs_service" "webatspeed_service_subscription" {
  cluster         = aws_ecs_cluster.webatspeed_cluster.id
  name            = aws_ecs_task_definition.webatspeed_task_subscription.family
  task_definition = aws_ecs_task_definition.webatspeed_task_subscription.arn
  launch_type     = "FARGATE"
  desired_count   = var.count_subscription

  network_configuration {
    security_groups = var.subscription_sg
    subnets         = var.private_subnet_ids
  }
}
