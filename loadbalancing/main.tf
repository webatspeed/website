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

resource "aws_route53_zone" "webatspeed_zone_de" {
  name = "webatspeed.de"
}

resource "aws_acm_certificate" "webatspeed_acm_cert" {
  domain_name               = "webatspeed.de"
  subject_alternative_names = ["*.webatspeed.de"]
  validation_method         = "DNS"
  tags = {
    Name : "webatspeed.de"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "webatspeed_route53_record" {
  for_each = {
    for dvo in aws_acm_certificate.webatspeed_acm_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.webatspeed_zone_de.zone_id
}

resource "aws_acm_certificate_validation" "webatspeed_acm_cert_validation" {
  timeouts {
    create = "5m"
  }

  certificate_arn         = aws_acm_certificate.webatspeed_acm_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.webatspeed_route53_record : record.fqdn]
}

resource "aws_route53_record" "webatspeed_de_www" {
  name    = "www.webatspeed.de"
  type    = "A"
  zone_id = aws_route53_zone.webatspeed_zone_de.zone_id
  alias {
    evaluate_target_health = true
    name                   = aws_lb.webatspeed_lb.dns_name
    zone_id                = aws_lb.webatspeed_lb.zone_id
  }
}

resource "aws_route53_record" "webatspeed_de_apex" {
  name    = "webatspeed.de"
  type    = "A"
  zone_id = aws_route53_zone.webatspeed_zone_de.zone_id
  alias {
    evaluate_target_health = true
    name                   = aws_lb.webatspeed_lb.dns_name
    zone_id                = aws_lb.webatspeed_lb.zone_id
  }
}

resource "aws_lb_listener" "webatspeed_lb_listener_encrypted" {
  load_balancer_arn = aws_lb.webatspeed_lb.arn
  port              = var.listener_port_encrypted
  protocol          = var.listener_protocol_encrypted
  ssl_policy        = var.listener_ssl_policy
  certificate_arn   = aws_acm_certificate_validation.webatspeed_acm_cert_validation.certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webatspeed_tg.arn
  }
}

resource "aws_lb_listener_certificate" "webatspeed_lb_listener_cert" {
  listener_arn    = aws_lb_listener.webatspeed_lb_listener_encrypted.arn
  certificate_arn = aws_acm_certificate.webatspeed_acm_cert.arn
}
