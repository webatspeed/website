output "cluster_id" {
  value = aws_ecs_cluster.webatspeed_cluster.id
}

output "cloudwatch_group" {
  value = aws_cloudwatch_log_group.webatspeed_log_group.name
}
