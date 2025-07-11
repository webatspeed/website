resource "aws_service_discovery_private_dns_namespace" "webatspeed_private_sd" {
  name = "webatspeed.local"
  vpc  = var.vpc_id
}

resource "aws_service_discovery_service" "webatspeed_ds_mongodb" {
  name = "mongodb"

  dns_config {
    namespace_id   = aws_service_discovery_private_dns_namespace.webatspeed_private_sd.id
    routing_policy = "MULTIVALUE"

    dns_records {
      ttl  = 60
      type = "A"
    }
  }
}

resource "aws_service_discovery_service" "webatspeed_ds_frontend" {
  name = "frontend"

  dns_config {
    namespace_id   = aws_service_discovery_private_dns_namespace.webatspeed_private_sd.id
    routing_policy = "MULTIVALUE"

    dns_records {
      ttl  = 60
      type = "A"
    }
  }
}

resource "aws_service_discovery_service" "webatspeed_ds_subscription" {
  name = "subscription"

  dns_config {
    namespace_id   = aws_service_discovery_private_dns_namespace.webatspeed_private_sd.id
    routing_policy = "MULTIVALUE"

    dns_records {
      ttl  = 60
      type = "A"
    }
  }
}
