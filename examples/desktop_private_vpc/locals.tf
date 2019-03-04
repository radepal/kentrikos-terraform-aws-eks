locals {
  aws_authenticator_env_variables = {
    AWS_PROFILE = "${var.aws_profile}"
  }

  tags = {
    ProductDomain = "${var.cluster_prefix}"
    Environment   = "dev"
  }
}
