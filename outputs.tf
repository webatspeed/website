output "instances" {
  value     = { for i in module.compute.instance : i.tags.Name => "${i.public_ip}:${module.compute.instance_port}" }
  sensitive = true
}

output "kube_config" {
  value     = [for i in module.compute.instance : "export KUBECONFIG=./orchestration/config/k3s-${i.tags.Name}.yaml"]
  sensitive = true
}

output "addresses" {
  value = concat(
    [for route in module.routing.routes : "https://${route}"],
    ["http://${module.loadbalancing.lb_endpoint}"]
  )
}

output "smtp_user" {
  value     = "${module.mailing.smtp_username} : ${module.mailing.smtp_password}"
  sensitive = true
}

output "attachment_bucket" {
  value = module.mailing.bucket_name
}
