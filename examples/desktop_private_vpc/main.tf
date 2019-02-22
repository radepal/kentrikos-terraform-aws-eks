provider "aws" {
  region  = "${var.region}"
  profile = "${var.aws_profile}"
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
  desired_worker_nodes            = 1
  aws_authenticator_env_variables = "${local.aws_authenticator_env_variables}"
  tags                            = "${local.tags}"
  enable_metrics       = true
  enabled_metrics      = "GroupMinSize,GroupMaxSize,GroupDesiredCapacity,GroupTerminatingInstances,GroupInServiceInstances,GroupTotalInstances" # A comma delimited string of metrics enabled for this Auto Scaling group
}
