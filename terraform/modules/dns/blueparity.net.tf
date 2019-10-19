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
    "10 mta1.blueparity.net.",
    "20 mta2.blueparity.net.",
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

resource "aws_route53_record" "blueparity_net" {
  zone_id = "${aws_route53_zone.blueparity_net.zone_id}"
  name    = "${local.blueparity_net_domain}"
  type    = "A"
  ttl     = "86400"
  records = ["212.13.198.8"]
}

resource "aws_route53_record" "www_blueparity_net" {
  zone_id = "${aws_route53_zone.blueparity_net.zone_id}"
  name    = "www"
  type    = "A"
  ttl     = "86400"
  records = ["212.13.198.8"]
}

resource "aws_route53_record" "mta1_blueparity_net" {
  zone_id = "${aws_route53_zone.blueparity_net.zone_id}"
  name    = "mta1"
  type    = "A"
  ttl     = "86400"
  records = ["212.13.198.9"]
}

resource "aws_route53_record" "mta1_blueparity_net_aaaa" {
  zone_id = "${aws_route53_zone.blueparity_net.zone_id}"
  name    = "mta1"
  type    = "AAAA"
  ttl     = "86400"
  records = ["2001:ba8:0:1ce:2::54"]
}

resource "aws_route53_record" "mta1_blueparity_net_txt" {
  zone_id = "${aws_route53_zone.blueparity_net.zone_id}"
  name    = "mta1"
  type    = "TXT"
  ttl     = "86400"
  records = ["v=spf1 a -all"]
}

resource "aws_route53_record" "mta1_domainkey_blueparity_net" {
  zone_id = "${aws_route53_zone.blueparity_net.zone_id}"
  name    = "mta1._domainkey"
  type    = "TXT"
  ttl     = "300"
  records = ["v=DKIM1; t=y; k=rsa; p=MHwwDQYJKoZIhvcNAQEBBQADawAwaAJhAL+ePxQ2yh+cyM/2qKS2uB4//f2TKDQ4GSqN9ktKmXC6fACpPiDy1Cl9v4vC2Pdu393neILidmVk8OLGju5z+uf+Z31Snnf5nxfDVeQLegaa9Jl15voxDFtHTFTPzuqmDwIDAQAB;"]
}

resource "aws_route53_record" "domainkey_blueparity_net" {
  zone_id = "${aws_route53_zone.blueparity_net.zone_id}"
  name    = "_domainkey"
  type    = "TXT"
  ttl     = "300"
  records = ["t=y; o=~;"]
}

resource "aws_route53_record" "mta2_blueparity_net" {
  zone_id = "${aws_route53_zone.blueparity_net.zone_id}"
  name    = "mta2"
  type    = "A"
  ttl     = "86400"
  records = ["86.54.115.54"]
}

resource "aws_route53_record" "mta2_blueparity_net_txt" {
  zone_id = "${aws_route53_zone.blueparity_net.zone_id}"
  name    = "mta2"
  type    = "TXT"
  ttl     = "86400"
  records = ["v=spf1 a -all"]
}

resource "aws_route53_record" "ns0_blueparity_net" {
  zone_id = "${aws_route53_zone.blueparity_net.zone_id}"
  name    = "ns0"
  type    = "A"
  ttl     = "86400"
  records = ["212.13.198.10"]
}

resource "aws_route53_record" "ns0_blueparity_net_aaaa" {
  zone_id = "${aws_route53_zone.blueparity_net.zone_id}"
  name    = "ns0"
  type    = "AAAA"
  ttl     = "86400"
  records = ["2001:ba8:0:1ce:2::53"]
}

resource "aws_route53_record" "ns1_blueparity_net" {
  zone_id = "${aws_route53_zone.blueparity_net.zone_id}"
  name    = "ns1"
  type    = "A"
  ttl     = "86400"
  records = ["86.54.115.54"]
}

resource "aws_route53_record" "zebedee_blueparity_net" {
  zone_id = "${aws_route53_zone.blueparity_net.zone_id}"
  name    = "zebedee"
  type    = "A"
  ttl     = "86400"
  records = ["212.13.198.5"]
}

resource "aws_route53_record" "zebedee_blueparity_net_aaaa" {
  zone_id = "${aws_route53_zone.blueparity_net.zone_id}"
  name    = "zebedee"
  type    = "AAAA"
  ttl     = "86400"
  records = ["2001:ba8:0:1ce:21a:4dff:fef9:87c"]
}

resource "aws_route53_record" "zebedee_mgmt_blueparity_net" {
  zone_id = "${aws_route53_zone.blueparity_net.zone_id}"
  name    = "zebedee.mgmt"
  type    = "A"
  ttl     = "86400"
  records = ["192.168.214.1"]
}

resource "aws_route53_record" "scooby_blueparity_net" {
  zone_id = "${aws_route53_zone.blueparity_net.zone_id}"
  name    = "scooby"
  type    = "A"
  ttl     = "86400"
  records = ["212.13.198.7"]
}

resource "aws_route53_record" "scooby_blueparity_net_aaaa" {
  zone_id = "${aws_route53_zone.blueparity_net.zone_id}"
  name    = "scooby"
  type    = "AAAA"
  ttl     = "86400"
  records = ["2001:ba8:0:1ce:5652:ff:fe3b:4867"]
}

resource "aws_route53_record" "scooby_mgmt_blueparity_net" {
  zone_id = "${aws_route53_zone.blueparity_net.zone_id}"
  name    = "scooby.mgmt"
  type    = "A"
  ttl     = "86400"
  records = ["192.168.214.3"]
}

resource "aws_route53_record" "console_blueparity_net" {
  zone_id = "${aws_route53_zone.blueparity_net.zone_id}"
  name    = "console"
  type    = "A"
  ttl     = "86400"
  records = ["212.13.198.6"]
}

resource "aws_route53_record" "console_blueparity_net_aaaa" {
  zone_id = "${aws_route53_zone.blueparity_net.zone_id}"
  name    = "console"
  type    = "AAAA"
  ttl     = "86400"
  records = ["2001:ba8:0:1ce:216:3eff:feff:fe01"]
}

resource "aws_route53_record" "console_mgmt_blueparity_net" {
  zone_id = "${aws_route53_zone.blueparity_net.zone_id}"
  name    = "console.mgmt"
  type    = "A"
  ttl     = "86400"
  records = ["192.168.214.2"]
}

resource "aws_route53_record" "pugwash_blueparity_net" {
  zone_id = "${aws_route53_zone.blueparity_net.zone_id}"
  name    = "pugwash"
  type    = "A"
  ttl     = "86400"
  records = ["86.54.115.54"]
}

resource "aws_route53_record" "cloud1_blueparity_net" {
  zone_id = "${aws_route53_zone.blueparity_net.zone_id}"
  name    = "cloud1"
  type    = "A"
  ttl     = "86400"
  records = ["54.217.215.155"]
}

resource "aws_route53_record" "imap_blueparity_net" {
  zone_id = "${aws_route53_zone.blueparity_net.zone_id}"
  name    = "imap"
  type    = "A"
  ttl     = "86400"
  records = ["54.217.215.155"]
}

resource "aws_route53_record" "vpn_blueparity_net" {
  zone_id = "${aws_route53_zone.blueparity_net.zone_id}"
  name    = "vpn"
  type    = "A"
  ttl     = "86400"
  records = ["212.13.198.6"]
}
