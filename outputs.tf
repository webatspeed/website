output "load_balancer_endpoint" {
  value = module.loadbalancing.lb_endpoint
}

output "instances" {
  value     = { for i in module.compute.instance : i.tags.Name => "${i.public_ip}:${module.compute.instance_port}" }
  sensitive = true
}

output "kube_config" {
  value     = [for i in module.compute.instance : "export KUBECONFIG=./orchestration/config/k3s-${i.tags.Name}.yaml"]
  sensitive = true
}
