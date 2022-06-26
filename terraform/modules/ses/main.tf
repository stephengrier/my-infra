# Domain to validate with SES.
resource "aws_ses_domain_identity" "domain" {
  domain = var.domain
}

# TXT record to validate domain with SES.
resource "aws_route53_record" "ses_verification_record" {
  zone_id = var.zone_id
  name    = "_amazonses.${var.domain}."
  type    = "TXT"
  ttl     = "600"
  records = ["${aws_ses_domain_identity.domain.verification_token}"]
}

# Set a MAIL FROM to a subdomain of our domain instead of the default
# amazonses.com one. This will make sure we are DMARC compliant, as long as we
# publish an SPF record for the new subdomain.
resource "aws_ses_domain_mail_from" "domain" {
  domain           = aws_ses_domain_identity.domain.domain
  mail_from_domain = "mail.${aws_ses_domain_identity.domain.domain}"
}

data "aws_region" "current" {}

# MX record for our MAIL FROM subdomain.
resource "aws_route53_record" "mail_from_mx" {
  zone_id = var.zone_id
  name    = aws_ses_domain_mail_from.domain.mail_from_domain
  type    = "MX"
  ttl     = "600"
  records = ["10 feedback-smtp.${data.aws_region.current.name}.amazonses.com"]
}

resource "aws_route53_record" "mail_from_txt" {
  zone_id = var.zone_id
  name    = aws_ses_domain_mail_from.domain.mail_from_domain
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:amazonses.com -all"]
}
