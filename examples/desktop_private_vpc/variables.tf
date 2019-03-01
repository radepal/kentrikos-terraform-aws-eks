variable "region" {}

variable "vpc_id" {}

variable "private_subnets" {
  type = "list"
}

variable "aws_profile" {}

variable "cluster_prefix" {}

variable "http_proxy" {}

variable "no_proxy" {}

variable "key_name" {}

variable "enable_cluster_autoscaling" {}

variable "enable_pod_autoscaling" {}

variable "cluster_version" {}

variable "owner" {}

variable "scaleinprotection" {}

variable "desired_worker_nodes" {}
