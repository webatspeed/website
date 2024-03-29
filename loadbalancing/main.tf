resource "aws_lb" "webatspeed_lb" {
  count = var.use ? 1 : 0

  name            = "webatspeed-loadbalancer"
  subnets         = var.public_subnets
  security_groups = [var.public_sg]
  idle_timeout    = 400
}

resource "aws_lb_target_group" "webatspeed_tg" {
  count = var.use ? 1 : 0

  name        = "webatspeed-lb-tg-${substr(uuid(), 0, 3)}"
  port        = var.tg_port
  protocol    = var.tg_protocol
  vpc_id      = var.vpc_id
  target_type = "ip"

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
  count = var.use ? 1 : 0

  load_balancer_arn = aws_lb.webatspeed_lb.*.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "webatspeed_lb_listener_encrypted" {
  count = var.use ? 1 : 0

  load_balancer_arn = aws_lb.webatspeed_lb.*.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.listener_ssl_policy
  certificate_arn   = var.certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webatspeed_tg.*.arn
  }
}

resource "aws_lb_listener_certificate" "webatspeed_lb_listener_cert" {
  count = var.use ? 1 : 0

  listener_arn    = aws_lb_listener.webatspeed_lb_listener_encrypted.*.arn
  certificate_arn = var.certificate_arn
}
