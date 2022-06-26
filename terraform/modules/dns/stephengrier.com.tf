locals {
  stephengrier_com_domain = "stephengrier.com."
}

resource "aws_route53_zone" "stephengrier_com" {
  name = local.stephengrier_com_domain
}

resource "aws_route53_record" "stephengrier_com_mx" {
  zone_id = aws_route53_zone.stephengrier_com.zone_id
  name    = local.stephengrier_com_domain
  type    = "MX"
  ttl     = "600"

  records = [
    "5 gmr-smtp-in.l.google.com.",
    "10 alt1.gmr-smtp-in.l.google.com.",
    "20 alt2.gmr-smtp-in.l.google.com.",
    "30 alt3.gmr-smtp-in.l.google.com.",
    "40 alt4.gmr-smtp-in.l.google.com.",
  ]
}

resource "aws_route53_record" "stephengrier_com_txt" {
  zone_id = aws_route53_zone.stephengrier_com.zone_id
  name    = local.stephengrier_com_domain
  type    = "TXT"
  ttl     = "86400"

  records = [
    "v=spf1 a mx ?all",
  ]
}

resource "aws_route53_record" "www_stephengrier_com" {
  zone_id = aws_route53_zone.stephengrier_com.zone_id
  name    = "www"
  type    = "CNAME"
  ttl     = "300"
  records = ["stephengrier.github.io"]
}
