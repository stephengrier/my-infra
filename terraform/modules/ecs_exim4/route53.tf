resource "aws_route53_record" "mta3" {
  zone_id = "${var.dns_zone_id}"
  name    = "mta3"
  type    = "A"

  alias {
    name                   = "${var.nlb_dns_name}"
    zone_id                = "${var.nlb_zone_id}"
    evaluate_target_health = false
  }
}
