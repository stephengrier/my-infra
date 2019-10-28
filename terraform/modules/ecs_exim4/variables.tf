variable "desired_count" {
  description = "The number of tasks to run"
  default     = 2
}

variable "ecs_cluster_arn" {}
variable "vpc_id" {}
variable "nlb_arn" {}
variable "ecs_sg_id" {}
variable "nlb_dns_name" {}
variable "nlb_zone_id" {}
variable "dns_zone_id" {}
