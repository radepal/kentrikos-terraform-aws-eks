provider "aws" {
  region = "${var.region}"
}

module "eks" {
  source = "../../"

  region                          = "${var.region}"
  vpc_id                          = "${var.vpc_id}"
  private_subnets                 = "${var.private_subnets}"
  cluster_prefix                  = "${var.cluster_prefix}"
  http_proxy                      = "${var.http_proxy}"
  no_proxy                        = "${var.no_proxy}"
  key_name                        = "${var.key_name}"
  desired_worker_nodes            = "${var.desired_worker_nodes}"
  aws_authenticator_env_variables = "${local.aws_authenticator_env_variables}"
  tags                            = "${local.tags}"
  cluster_version                 = "${var.cluster_version}"
  enable_cluster_autoscaling      = "${var.enable_cluster_autoscaling}"
  enable_pod_autoscaling          = "${var.enable_pod_autoscaling}"
}
