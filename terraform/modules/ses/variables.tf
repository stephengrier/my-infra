variable "domain" {
  type        = string
  description = "Domain to validate with SES"
}

variable "zone_id" {
  type        = string
  description = "Route53 zone ID to add TXT and MX records to"
}
