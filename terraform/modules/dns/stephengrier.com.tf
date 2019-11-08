locals {
  stephengrier_com_domain = "stephengrier.com."
}

resource "aws_route53_zone" "stephengrier_com" {
  name = "${local.stephengrier_com_domain}"
}

resource "aws_route53_record" "stephengrier_com_mx" {
  zone_id = "${aws_route53_zone.stephengrier_com.zone_id}"
  name    = "${local.stephengrier_com_domain}"
  type    = "MX"
  ttl     = "600"

  records = [
    "10 mta3.blueparity.net.",
    "20 mta1.blueparity.net.",
  ]
}

resource "aws_route53_record" "stephengrier_com_txt" {
  zone_id = "${aws_route53_zone.stephengrier_com.zone_id}"
  name    = "${local.stephengrier_com_domain}"
  type    = "TXT"
  ttl     = "86400"

  records = [
    "v=spf1 a mx ?all",
  ]
}

resource "aws_route53_record" "www_stephengrier_com" {
  zone_id = "${aws_route53_zone.stephengrier_com.zone_id}"
  name    = "www"
  type    = "CNAME"
  ttl     = "300"
  records = ["stephengrier.github.io"]
}
