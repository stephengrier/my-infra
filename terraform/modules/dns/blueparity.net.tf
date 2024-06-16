locals {
  blueparity_net_domain = "blueparity.net."
}

resource "aws_route53_zone" "blueparity_net" {
  name = local.blueparity_net_domain
}

resource "aws_route53_record" "blueparity_net_mx" {
  zone_id = aws_route53_zone.blueparity_net.zone_id
  name    = local.blueparity_net_domain
  type    = "MX"
  ttl     = "3600"

  records = [
    "5 gmr-smtp-in.l.google.com.",
    "10 alt1.gmr-smtp-in.l.google.com.",
    "20 alt2.gmr-smtp-in.l.google.com.",
    "30 alt3.gmr-smtp-in.l.google.com.",
    "40 alt4.gmr-smtp-in.l.google.com.",
    "100 mxa.mailgun.org.",
    "100 mxb.mailgun.org.",
  ]
}

resource "aws_route53_record" "blueparity_net_txt" {
  zone_id = aws_route53_zone.blueparity_net.zone_id
  name    = local.blueparity_net_domain
  type    = "TXT"
  ttl     = "3600"

  records = [
    "v=spf1 a mx include:mailgun.org ?all",
  ]
}

resource "aws_route53_record" "smtp_domainkey_blueparity_net_txt" {
  zone_id = aws_route53_zone.blueparity_net.zone_id
  name    = "smtp._domainkey"
  type    = "TXT"
  ttl     = "3600"

  records = [
    "k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDSjlWXaSXgqtbidbwmgIJ1C9EX7orjTiiM1wQ5m24Zm+zWXv7OLxCfFTwezAxLEN3pYEHS990v7XidAnaa5Fi2A7z+OjsMrdWBeMAlATUCDhh61wKghZb3C4g2jSZ+Uxy+fISBaMoU2zFzSI4KpN9KIrO3KObOmvH7GAX1pksqTQIDAQAB",
  ]
}
