resource "aws_route53_record" "imap" {
  zone_id = var.dns_zone_id
  name    = var.cluster_name
  type    = local.dns_record_type
  ttl     = local.dns_record_ttl
  records = [aws_eip.imap.public_ip]
}
