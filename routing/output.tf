output "certificate_arn" {
  value = aws_acm_certificate.webatspeed_acm_cert.arn
}

output "routes" {
  value = [for i in aws_route53_record.webatspeed_de : i.name]
}
