provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}

resource "aws_route53_zone" "webatspeed_zone_de" {
  name = var.root_domain_name
}

resource "aws_acm_certificate" "webatspeed_cert" {
  domain_name               = "*.${var.root_domain_name}"
  validation_method         = "DNS"
  subject_alternative_names = [var.root_domain_name]
  provider                  = aws.virginia
}

resource "aws_route53_record" "webatspeed_route53_record" {
  for_each = {
    for dvo in aws_acm_certificate.webatspeed_cert.domain_validation_options : dvo.domain_name => {
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
  provider = aws.virginia
  timeouts {
    create = "7m"
  }

  certificate_arn         = aws_acm_certificate.webatspeed_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.webatspeed_route53_record : record.fqdn]
}

resource "aws_cloudfront_distribution" "webatspeed_distribution" {
  count = var.use ? 1 : 0

  origin {
    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }

    domain_name = var.static_endpoint
    origin_id   = var.www_domain_name
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = var.www_domain_name
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  aliases = [var.www_domain_name]

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.webatspeed_cert.arn
    ssl_support_method  = "sni-only"
  }
}

resource "aws_cloudfront_distribution" "webatspeed_distribution_apex" {
  count = var.use ? 1 : 0

  origin {
    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }

    domain_name = var.static_endpoint_apex
    origin_id   = var.root_domain_name
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = var.root_domain_name
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  aliases = [var.root_domain_name]

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.webatspeed_cert.arn
    ssl_support_method  = "sni-only"
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

resource "aws_route53_record" "webatspeed_alias_www" {
  count = var.use ? 1 : 0

  name    = var.www_domain_name
  type    = "A"
  zone_id = aws_route53_zone.webatspeed_zone_de.zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.webatspeed_distribution[0].domain_name
    zone_id                = aws_cloudfront_distribution.webatspeed_distribution[0].hosted_zone_id
  }
}

resource "aws_route53_record" "webatspeed_alias_apex" {
  count = var.use ? 1 : 0

  name    = ""
  type    = "A"
  zone_id = aws_route53_zone.webatspeed_zone_de.zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.webatspeed_distribution_apex[0].domain_name
    zone_id                = aws_cloudfront_distribution.webatspeed_distribution_apex[0].hosted_zone_id
  }
}
