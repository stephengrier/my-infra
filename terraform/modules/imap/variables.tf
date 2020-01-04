variable "environment" {
  description = "Name of the environment, eg. staging, prod etc"
}

locals {
  az_count = 3
}

variable "number_of_instances" {
  description = "The number of instances in the cluster"
  default     = 1
}

variable "cluster_name" {
  description = "Name of the cluster"
  default     = "imap"
}
