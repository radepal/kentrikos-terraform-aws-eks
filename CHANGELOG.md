# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2019-02-27
### Added
- Base EKS module for deployment of Kubernetes cluster v1.10
- Proxy configuration to allow EKS cluster to operate in private VPC environment
- Pining versions
- This CHANGELOG file

## [not named yet] - undated
### Added
- **for pod autoscaling added:**
  - variables for proxy / no_proxy
  - create template file proxy-environment-variables.yaml
  - create template file workergroup_proxy.tpl
  - add process to extract and inject proxy environment in the kube-system 
  - created a dependency on changes based on proxy settings
  - created support scripts to check on:
    - kube-dns readiness
    - tiller-pod readiness
  - helm_rbac_config
  - installed metrics server on the EKS cluster
  - allowed to toggle horiontal scaling (pods)

- **for cluster autoscaling added:**
  - allowed to toggle vertical scaling (nodes)
  - template cluster_autoscaling.yaml.tpl
  - "null_resource" "initialize_cluster_autoscaling" to main.tf
  - "local_file" "cluster_autoscaling" to main.tf
  - "template_file" "cluster_autoscaling" to main.tf
  - variable "enable_cluster_autoscaling" {} to variables.tf
  - helm install stable/cluster-autoscaler
    - referencing github project: https://github.com/helm/charts/tree/master/stable/cluster-autoscaler


