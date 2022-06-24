locals {
  blueparity_net_domain = "blueparity.net."
}

resource "aws_route53_zone" "blueparity_net" {
  name = "${local.blueparity_net_domain}"
}

resource "aws_route53_record" "blueparity_net_mx" {
  zone_id = "${aws_route53_zone.blueparity_net.zone_id}"
  name    = "${local.blueparity_net_domain}"
  type    = "MX"
  ttl     = "86400"

  records = [
    "5 gmr-smtp-in.l.google.com.",
    "10 alt1.gmr-smtp-in.l.google.com.",
    "20 alt2.gmr-smtp-in.l.google.com.",
    "30 alt3.gmr-smtp-in.l.google.com.",
    "40 alt4.gmr-smtp-in.l.google.com.",
  ]
}

resource "aws_route53_record" "blueparity_net_txt" {
  zone_id = "${aws_route53_zone.blueparity_net.zone_id}"
  name    = "${local.blueparity_net_domain}"
  type    = "TXT"
  ttl     = "86400"

  records = [
    "v=spf1 a mx ?all",
  ]
}

resource "aws_route53_record" "pugwash_blueparity_net" {
  zone_id = "${aws_route53_zone.blueparity_net.zone_id}"
  name    = "pugwash"
  type    = "A"
  ttl     = "86400"
  records = ["86.54.115.54"]
}

resource "aws_route53_record" "imap_blueparity_net" {
  zone_id = "${aws_route53_zone.blueparity_net.zone_id}"
  name    = "imap"
  type    = "A"
  ttl     = "86400"
  records = ["52.213.67.140"]
}
