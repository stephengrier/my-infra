locals {
  grier_org_uk_domain = "grier.org.uk."
}

resource "aws_route53_zone" "grier_org_uk" {
  name = local.grier_org_uk_domain
}

resource "aws_route53_record" "grier_org_uk_mx" {
  zone_id = aws_route53_zone.grier_org_uk.zone_id
  name    = local.grier_org_uk_domain
  type    = "MX"
  ttl     = "3600"

  records = [
    "10 smtp.secureserver.net.",
    "20 mailstore1.secureserver.net.",
  ]
}

resource "aws_route53_record" "grier_org_uk_txt" {
  zone_id = aws_route53_zone.grier_org_uk.zone_id
  name    = local.grier_org_uk_domain
  type    = "TXT"
  ttl     = "86400"

  records = [
    "v=spf1 include:secureserver.net ?all",
  ]
}
