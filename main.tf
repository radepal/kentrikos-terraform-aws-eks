module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "2.1.0"

  cluster_name                               = "${var.cluster_prefix}"
  subnets                                    = ["${compact(concat(var.private_subnets, var.public_subnets))}"]
  write_kubeconfig                           = true
  config_output_path                         = "${var.outputs_directory}"
  tags                                       = "${var.tags}"
  vpc_id                                     = "${var.vpc_id}"
  worker_groups                              = "${local.worker_group}"
  kubeconfig_aws_authenticator_env_variables = "${var.aws_authenticator_env_variables}"
  worker_group_count                         = "1"
  worker_additional_security_group_ids       = ["${aws_security_group.all_worker_mgmt.id}"]
  cluster_version                            = "${var.cluster_version}"
}

resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      = "${var.vpc_id}"
}

resource "aws_security_group_rule" "allow_ssh" {
  count       = "${length(var.allowed_worker_ssh_cidrs) != 0 ? 1 : 0}"
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["${var.allowed_worker_ssh_cidrs}"]

  security_group_id = "${aws_security_group.all_worker_mgmt.id}"
}

data "template_file" "http_proxy_workergroup" {
  template = "${file("${path.module}/templates/workergroup_proxy.tpl")}"

  vars {
    http_proxy   = "${var.http_proxy}"
    https_proxy  = "${var.http_proxy}"
    no_proxy     = "${local.no_proxy_merged}"
    cluster_name = "${var.cluster_prefix}"
  }
}

data "template_file" "proxy_environment_variables" {
  template = "${file("${path.module}/templates/proxy-environment-variables.yaml.tpl")}"

  vars {
    http_proxy  = "${var.http_proxy}"
    https_proxy = "${var.http_proxy}"
    no_proxy    = "${local.no_proxy_merged}"
  }
}

resource "local_file" "proxy_environment_variables" {
  count    = "${var.http_proxy != "" ? 1 : 0 }"
  filename = "${var.outputs_directory}proxy-environment-variables.yaml"
  content  = "${data.template_file.proxy_environment_variables.rendered}"
}

resource "null_resource" "proxy_environment_variables" {
  count      = "${var.http_proxy != "" ? 1 : 0 }"
  depends_on = ["module.eks", "local_file.proxy_environment_variables"]

  provisioner "local-exec" {
    command = "kubectl apply -f \"${local_file.proxy_environment_variables.filename}\" --kubeconfig=\"${var.outputs_directory}kubeconfig_${var.cluster_prefix}\""
  }
}

resource "null_resource" "master_config_services_proxy" {
  count      = "${var.http_proxy != "" ? length(local.master_config_services_proxy) : 0 }"
  depends_on = ["module.eks", "null_resource.proxy_environment_variables"]

  provisioner "local-exec" {
    command = <<EOC
    kubectl get ${lookup(local.master_config_services_proxy[count.index], "type")} ${lookup(local.master_config_services_proxy[count.index], "name")} --namespace=kube-system --kubeconfig=${var.outputs_directory}kubeconfig_${var.cluster_prefix} -o=json > ${var.outputs_directory}${lookup(local.master_config_services_proxy[count.index], "name")}.tmp;
    jq '.spec.template.spec.containers[] += {"envFrom": [{"configMapRef": {"name": "proxy-environment-variables"}}]}' ${var.outputs_directory}${lookup(local.master_config_services_proxy[count.index], "name")}.tmp > ${var.outputs_directory}${lookup(local.master_config_services_proxy[count.index], "name")}.json;
    kubectl apply -f ${var.outputs_directory}${lookup(local.master_config_services_proxy[count.index], "name")}.json --kubeconfig=${var.outputs_directory}kubeconfig_${var.cluster_prefix};
    rm ${var.outputs_directory}${lookup(local.master_config_services_proxy[count.index], "name")}.tmp;
  EOC
  }
}

resource "null_resource" "validate_dns" {
  provisioner "local-exec" {
    command = <<EOC
    /bin/sh \
      "${path.module}/scripts/validate_dns.sh" "${var.outputs_directory}kubeconfig_${var.cluster_prefix}"
    EOC
  }

  depends_on = ["module.eks", "null_resource.master_config_services_proxy"]
}

data "template_file" "helm_rbac_config" {
  template = "${file("${path.module}/templates/helm_rbac_config.yaml.tpl")}"
}

resource "local_file" "helm_rbac_config" {
  count      = "${local.enable_helm}"
  filename   = "${var.outputs_directory}helm_rbac_config.yaml"
  content    = "${data.template_file.helm_rbac_config.rendered}"
  depends_on = ["module.eks"]
}

resource "null_resource" "initialize_helm" {
  count = "${local.enable_helm}"

  provisioner "local-exec" {
    command = "kubectl apply -f \"${local_file.helm_rbac_config.filename}\" --kubeconfig=\"${var.outputs_directory}kubeconfig_${var.cluster_prefix}\""
  }

  provisioner "local-exec" {
    command = "helm init --service-account tiller --kubeconfig=\"${var.outputs_directory}kubeconfig_${var.cluster_prefix}\""
  }

  provisioner "local-exec" {
    command = <<EOC
    /bin/sh \
      "${path.module}/scripts/check_tiller_pod.sh" "${var.outputs_directory}kubeconfig_${var.cluster_prefix}"
    EOC
  }

  depends_on = ["null_resource.validate_dns", "local_file.helm_rbac_config"]
}

resource "null_resource" "install_metrics_server" {
  count = "${local.enable_helm}" #only for pod autoscaling

  provisioner "local-exec" {
    command = "helm install stable/metrics-server --name metrics-server --namespace metrics  --kubeconfig=${var.outputs_directory}kubeconfig_${var.cluster_prefix}"
  }

  depends_on = ["null_resource.initialize_helm"]
}

data "template_file" "cluster_autoscaling" {
  template = "${file("${path.module}/templates/cluster_autoscaling.yaml.tpl")}"

  vars {
    http_proxy   = "${var.http_proxy}"
    https_proxy  = "${var.http_proxy}"
    no_proxy     = "${local.no_proxy_merged}"
    region       = "${var.region}"
    cluster_name = "${var.cluster_prefix}"
  }
}

resource "local_file" "cluster_autoscaling" {
  count    = "${local.enable_cluster_autoscaling}"
  filename = "${var.outputs_directory}cluster_autoscaling.yaml"
  content  = "${data.template_file.cluster_autoscaling.rendered}"
}

resource "null_resource" "initialize_cluster_autoscaling" {
  count = "${local.enable_cluster_autoscaling}"

  provisioner "local-exec" {
    command = "helm install stable/cluster-autoscaler --values=${local_file.cluster_autoscaling.filename} --kubeconfig=${var.outputs_directory}kubeconfig_${var.cluster_prefix}"
  }

  depends_on = ["null_resource.initialize_helm"]
}
