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
