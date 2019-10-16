locals {
  grier_org_uk_domain = "grier.org.uk."
}

resource "aws_route53_zone" "grier_org_uk" {
  name   = "${local.grier_org_uk_domain}"
}

resource "aws_route53_record" "grier_org_uk_mx" {
  zone_id = "${aws_route53_zone.grier_org_uk.zone_id}"
  name    = "${local.grier_org_uk_domain}"
  type    = "MX"
  ttl     = "86400"

  records = [
    "20 mta2.blueparity.net.",
  ]
}

resource "aws_route53_record" "grier_org_uk_txt" {
  zone_id = "${aws_route53_zone.grier_org_uk.zone_id}"
  name    = "${local.grier_org_uk_domain}"
  type    = "TXT"
  ttl     = "86400"

  records = [
    "v=spf1 a mx ?all",
  ]
}

resource "aws_route53_record" "grier_org_uk_a" {
  zone_id = "${aws_route53_zone.grier_org_uk.zone_id}"
  name    = "${local.grier_org_uk_domain}"
  type    = "A"
  ttl     = "86400"
  records = ["86.54.115.54"]
}

resource "aws_route53_record" "grier_org_uk_www" {
  zone_id = "${aws_route53_zone.grier_org_uk.zone_id}"
  name    = "www"
  type    = "A"
  ttl     = "86400"
  records = ["86.54.115.54"]
}

resource "aws_route53_record" "grier_org_uk_imap" {
  zone_id = "${aws_route53_zone.grier_org_uk.zone_id}"
  name    = "imap"
  type    = "A"
  ttl     = "86400"
  records = ["86.54.115.54"]
}

resource "aws_route53_record" "grier_org_uk_pugwash" {
  zone_id = "${aws_route53_zone.grier_org_uk.zone_id}"
  name    = "pugwash"
  type    = "A"
  ttl     = "86400"
  records = ["86.54.115.54"]
}

resource "aws_route53_record" "grier_org_uk_a_mx" {
  zone_id = "${aws_route53_zone.grier_org_uk.zone_id}"
  name    = "mx"
  type    = "A"
  ttl     = "86400"
  records = ["86.54.115.54"]
}
