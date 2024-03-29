output "addresses" {
  value = concat(
    [for route in module.routing.routes : "https://${route}"]
  )
}

output "smtp_user" {
  value     = "${module.mailing.smtp_username} : ${module.mailing.smtp_password}"
  sensitive = true
}

output "attachment_bucket" {
  value = module.mailing.bucket_name
}
