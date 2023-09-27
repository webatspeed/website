output "lb_target_group_arn" {
  value = aws_lb_target_group.webatspeed_tg.arn
}

output "lb_endpoint" {
  value = aws_lb.webatspeed_lb.dns_name
}
