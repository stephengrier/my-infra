variable "environment" {
  description = "Name of the environment, eg. staging, prod etc"
}

locals {
  az_count        = 3
  dns_record_ttl  = "86400"
  dns_record_type = "A"
}

variable "number_of_instances" {
  description = "The number of instances in the cluster"
  default     = 1
}

variable "cluster_name" {
  description = "Name of the cluster"
  default     = "imap"
}

variable "dns_zone_id" {
  description = "Route53 zone ID to add a record to for the instance"
}
