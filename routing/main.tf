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
    create = "7m"
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
    name                   = var.dns_name
    zone_id                = var.zone_id
  }
}

resource "aws_route53_record" "webatspeed_de_apex" {
  name    = "webatspeed.de"
  type    = "A"
  zone_id = aws_route53_zone.webatspeed_zone_de.zone_id
  alias {
    evaluate_target_health = true
    name                   = var.dns_name
    zone_id                = var.zone_id
  }
}
