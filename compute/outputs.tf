output "instance" {
  value     = aws_instance.webatspeed_node[*]
  sensitive = true
}

output "instance_port" {
  value = aws_lb_target_group_attachment.webatspeed_tg_attach[0].port
}
