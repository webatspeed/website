output "lb_target_group_arn" {
  value = aws_lb_target_group.webatspeed_tg.arn
}

output "lb_endpoint" {
  value = aws_lb.webatspeed_lb.dns_name
}

output "lb_zone_id" {
  value = aws_lb.webatspeed_lb.zone_id
}
