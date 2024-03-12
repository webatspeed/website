output "certificate_arn" {
  value = aws_acm_certificate.webatspeed_cert.arn
}

output "routes" {
  value = [var.www_domain_name, var.root_domain_name]
}
