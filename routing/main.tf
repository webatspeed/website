resource "aws_route53_zone" "webatspeed_zone_de" {
  name = "webatspeed.de"
}

resource "aws_acm_certificate" "webatspeed_acm_cert" {
  domain_name               = aws_route53_zone.webatspeed_zone_de.name
  subject_alternative_names = ["*.${aws_route53_zone.webatspeed_zone_de.name}"]
  validation_method         = "DNS"
  tags = {
    Name : aws_route53_zone.webatspeed_zone_de.name
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
  ttl             = 600
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

resource "aws_route53_record" "webatspeed_de" {
  for_each = toset(["", "www."])
  name     = "${each.key}${aws_route53_zone.webatspeed_zone_de.name}"
  type     = "A"
  zone_id  = aws_route53_zone.webatspeed_zone_de.zone_id
  alias {
    evaluate_target_health = true
    name                   = var.dns_name
    zone_id                = var.zone_id
  }
}

resource "aws_ses_domain_identity" "webatspeed_ses_domain" {
  domain = aws_route53_zone.webatspeed_zone_de.name
}

resource "aws_ses_domain_mail_from" "webatspeed_ses_domain_mail_from" {
  domain           = aws_ses_domain_identity.webatspeed_ses_domain.domain
  mail_from_domain = "mail.${aws_ses_domain_identity.webatspeed_ses_domain.domain}"
}

resource "aws_route53_record" "webatspeed_verification_record" {
  name    = "_amazonses.${aws_ses_domain_identity.webatspeed_ses_domain.domain}"
  type    = "TXT"
  zone_id = aws_route53_zone.webatspeed_zone_de.zone_id
  ttl     = 600
  records = [join("", aws_ses_domain_identity.webatspeed_ses_domain.*.verification_token)]
}

resource "aws_ses_domain_dkim" "webatspeed_ses_domain_dkim" {
  domain = join("", aws_ses_domain_identity.webatspeed_ses_domain.*.domain)
}

resource "aws_route53_record" "webatspeed_dkim_record" {
  count   = 3
  zone_id = aws_route53_zone.webatspeed_zone_de.zone_id
  name    = "${element(aws_ses_domain_dkim.webatspeed_ses_domain_dkim.dkim_tokens, count.index)}._domainkey.${aws_ses_domain_identity.webatspeed_ses_domain.domain}"
  type    = "CNAME"
  ttl     = 600
  records = ["${element(aws_ses_domain_dkim.webatspeed_ses_domain_dkim.dkim_tokens, count.index)}.dkim.amazonses.com"]
}

resource "aws_route53_record" "webatspeed_spf_mail_from" {
  zone_id = aws_route53_zone.webatspeed_zone_de.zone_id
  name    = aws_ses_domain_mail_from.webatspeed_ses_domain_mail_from.mail_from_domain
  type    = "TXT"
  ttl     = 600
  records = ["v=spf1 include:amazonses.com ~all"]
}

resource "aws_route53_record" "webatspeed_spf_domain" {
  zone_id = aws_route53_zone.webatspeed_zone_de.zone_id
  name    = aws_ses_domain_identity.webatspeed_ses_domain.domain
  type    = "TXT"
  ttl     = 600
  records = ["v=spf1 include:amazonses.com ~all"]
}

resource "aws_route53_record" "webatspeed_mx_mail_from" {
  zone_id = aws_route53_zone.webatspeed_zone_de.id
  name    = aws_ses_domain_mail_from.webatspeed_ses_domain_mail_from.mail_from_domain
  type    = "MX"
  ttl     = 600
  records = ["10 feedback-smtp.${var.aws_region}.amazonses.com"]
}
