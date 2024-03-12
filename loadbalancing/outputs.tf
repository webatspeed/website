output "lb_target_group_arn" {
  value = var.use ? aws_lb_target_group.webatspeed_tg[0].arn : null
}

output "lb_endpoint" {
  value = var.use ? aws_lb.webatspeed_lb[0].dns_name : null
}

output "lb_zone_id" {
  value = var.use ? aws_lb.webatspeed_lb[0].zone_id : null
}
