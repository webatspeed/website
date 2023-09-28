resource "aws_lb" "webatspeed_lb" {
  name            = "webatspeed-loadbalancer"
  subnets         = var.public_subnets
  security_groups = [var.public_sg]
  idle_timeout    = 400
}

resource "aws_lb_target_group" "webatspeed_tg" {
  name     = "webatspeed-lb-tg-${substr(uuid(), 0, 3)}"
  port     = var.tg_port
  protocol = var.tg_protocol
  vpc_id   = var.vpc_id
  lifecycle {
    ignore_changes        = [name]
    create_before_destroy = true
  }
  health_check {
    healthy_threshold   = var.lb_healthy_threshold
    unhealthy_threshold = var.lb_unhealthy_threshold
    timeout             = var.lb_timeout
    interval            = var.lb_interval
  }
}

resource "aws_lb_listener" "webatspeed_lb_listener_plain" {
  load_balancer_arn = aws_lb.webatspeed_lb.arn
  port              = var.listener_port_plain
  protocol          = var.listener_protocol_plain
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webatspeed_tg.arn
  }
}

resource "aws_lb_listener" "webatspeed_lb_listener_encrypted" {
  load_balancer_arn = aws_lb.webatspeed_lb.arn
  port              = var.listener_port_encrypted
  protocol          = var.listener_protocol_encrypted
  ssl_policy        = var.listener_ssl_policy
  certificate_arn   = var.certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webatspeed_tg.arn
  }
}

resource "aws_lb_listener_certificate" "webatspeed_lb_listener_cert" {
  listener_arn    = aws_lb_listener.webatspeed_lb_listener_encrypted.arn
  certificate_arn = var.certificate_arn
}
