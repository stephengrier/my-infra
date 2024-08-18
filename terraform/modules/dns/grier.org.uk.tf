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
    "10 mxa.mailgun.org.",
    "10 mxb.mailgun.org.",
  ]
}

resource "aws_route53_record" "grier_org_uk_txt" {
  zone_id = aws_route53_zone.grier_org_uk.zone_id
  name    = local.grier_org_uk_domain
  type    = "TXT"
  ttl     = "3600"

  records = [
    "v=spf1 include:mailgun.org ?all",
  ]
}

resource "aws_route53_record" "mx_domainkey_grier_org_uk_txt" {
  zone_id = aws_route53_zone.grier_org_uk.zone_id
  name    = "mx._domainkey"
  type    = "TXT"
  ttl     = "3600"

  records = [
    "k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC+qxN9FKwaiBKgaVZQMlap4EvFgquewi0Sae+MU6cwwAjVF8FRdMQ5qcuqfONDNnatsiY1aqEs++RPz/w7ed5vKXPkdYmqftOdnzH1jY/Z3DltWxccTiVuahNwmzlG4Q9rBc8/YI2TaX6vRjHWWe/R2e8QrMHgNj+8ji4TdfTx6QIDAQAB",
  ]
}
