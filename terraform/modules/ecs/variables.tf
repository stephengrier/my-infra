variable "environment" {
  description = "Name of the environment, eg. staging, prod etc"
}

locals {
  az_count = 2
}

variable "cluster_name" {
  description = "Name of the ECS cluster"
  default     = "ecs-cluster"
}

variable "number_of_instances" {
  description = "The number of instances in the ECS cluster"
  default     = 2
}
