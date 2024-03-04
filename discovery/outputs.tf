output "registry_frontend_arn" {
  value = aws_service_discovery_service.webatspeed_ds_frontend.arn
}

output "registry_subscription_arn" {
  value = aws_service_discovery_service.webatspeed_ds_subscription.arn
}

output "registry_mongodb_arn" {
  value = aws_service_discovery_service.webatspeed_ds_mongodb.arn
}

output "local_namespace" {
  value = aws_service_discovery_private_dns_namespace.webatspeed_private_sd.name
}

output "mongo_host" {
  value = "${aws_service_discovery_service.webatspeed_ds_mongodb.name}.${aws_service_discovery_private_dns_namespace.webatspeed_private_sd.name}"
}

output "subscription_url" {
  value = "http://${aws_service_discovery_service.webatspeed_ds_subscription.name}.${aws_service_discovery_private_dns_namespace.webatspeed_private_sd.name}:8080"
}
