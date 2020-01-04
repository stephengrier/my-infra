resource "aws_service_discovery_public_dns_namespace" "discovery" {
  name        = "service.blueparity.net"
  description = "Service discovery namespace"
}

resource "aws_service_discovery_service" "imap" {
  name = "imap"

  dns_config {
    namespace_id = "${aws_service_discovery_public_dns_namespace.discovery.id}"

    dns_records {
      ttl  = 30
      type = "A"
    }
  }

  health_check_config {
    failure_threshold = 3
    type              = "TCP"
  }
}
