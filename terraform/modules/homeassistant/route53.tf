resource "aws_route53_record" "ha" {
  count   = var.add_dns_record
  zone_id = var.dns_zone_id
  name    = local.resource_name
  type    = local.dns_record_type
  ttl     = local.dns_record_ttl
  records = [aws_eip.ha_instance.public_ip]
}

resource "aws_route53_record" "mqtt" {
  count   = var.add_dns_record
  zone_id = var.dns_zone_id
  name    = var.mqtt_server_name
  type    = local.dns_record_type
  ttl     = local.dns_record_ttl
  records = [aws_eip.ha_instance.public_ip]
}
