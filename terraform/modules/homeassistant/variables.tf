variable "environment" {
  description = "Name of the environment, eg. staging, prod etc"
}

variable "dns_zone_id" {
  description = "Route53 zone ID to add a record to for the instance"
}

variable "add_dns_record" {
  description = "Whether to add a route53 DNS record to dns_zone_id resolving to the EIP address"
  default     = 1
}

variable "server_name" {
  description = "The hostname of the home assistant site"
}

variable "mqtt_server_name" {
  description = "The DNS name of the mosquitto server"
}

variable "letsencrypt_email" {
  description = "Email address to register with LetsEncrypt when requesting certificates"
}

variable "certbot_extra_args" {
  description = "Extra args to pass to certbot when creating TLS certificates"
  default     = "--test-cert"
}

variable "instance_key_name" {
  description = "Name of the key pair to use for EC2 instances"
  default     = ""
}

locals {
  az_count      = 1
  resource_name = "homeassistant"

  dns_record_ttl  = "86400"
  dns_record_type = "A"

  spot_instance_types = ["t4g.micro", "t4g.small"]
}
