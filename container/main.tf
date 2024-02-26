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
    region    = var.region
    log_group = aws_cloudwatch_log_group.webatspeed_log_group.name
    username  = var.db_user
    password  = var.db_password
  })

  volume {
    name = "mongodb-volume"

    efs_volume_configuration {
      file_system_id = var.file_system_id
      root_directory = "/data/mongodb"
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
  desired_count   = 1

  network_configuration {
    security_groups = var.mongodb_sg
    subnets         = var.private_subnet_ids
  }

  service_connect_configuration {
    enabled = true

    log_configuration {
      log_driver = "awslogs"
      options = {
        awslogs-group : aws_cloudwatch_log_group.webatspeed_log_group.name
        awslogs-region : var.region
        awslogs-stream-prefix : aws_ecs_task_definition.webatspeed_task_mongodb.family
      }
    }
  }
}
