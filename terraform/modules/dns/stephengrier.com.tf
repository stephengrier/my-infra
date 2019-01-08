locals {
  stephengrier_com_domain = "stephengrier.com."
}

resource "aws_route53_zone" "stephengrier_com" {
  name   = "${local.stephengrier_com_domain}"
}

resource "aws_route53_record" "stephengrier_com_mx" {
  zone_id = "${aws_route53_zone.stephengrier_com.zone_id}"
  name    = "@"
  type    = "MX"
  ttl     = "86400"

  records = [
    "10 mta1.blueparity.net.",
    "20 mta2.blueparity.net.",
  ]
}

resource "aws_route53_record" "stephengrier_com_txt" {
  zone_id = "${aws_route53_zone.stephengrier_com.zone_id}"
  name    = "@"
  type    = "TXT"
  ttl     = "86400"

  records = [
    "v=spf1 a mx ?all",
  ]
}

resource "aws_route53_record" "stephengrier_com_www" {
  zone_id = "${aws_route53_zone.stephengrier_com.zone_id}"
  name    = "www"
  type    = "A"
  ttl     = "86400"
  records = ["212.13.198.8"]
}
