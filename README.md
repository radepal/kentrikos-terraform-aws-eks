# A Terraform module to deploy an AWS EKS Cluster Behind a (corporate) proxy

This module will create an **[AWS EKS](https://docs.aws.amazon.com/eks/index.html)** cluster and is a terraform wrapper for the official **[AWS terraform EKS module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws)** to provide ease of deployment with environments that may need use of a proxy for connectivity in a private VPC.

This EKS module is referencing the github EKS module maintained by terraform and is available **[here](https://github.com/terraform-aws-modules/terraform-aws-eks)**.

The following tools are required for deployment (the versions are needed to support AWS EKS functionality):  

  * **kubectl** (version 1.13+)  
  * **jq**  
  * **aws-iam-authenticator**  
  * **awscli** (version 1.16+)


## Usage

#### Two examples have been provided.  
  * **desktop\_private\_VPC** - will deploy an EKS cluster from your desktop in the provided account;  
  * **ec2\_node\_private\_VPC** - will deploy an EKS cluster from an EC2 instance in the provided account.

Depending on your need, go to the appropriate folder and run:  

  * terraform init && terraform apply  


## Inputs

#### List of all variables used:  

*  **region**   
*  **vpc\_id**  
*  **private\_subnets**  
*  **cluster\_prefix**  
*  **http\_proxy**  
*  **no\_proxy**  
*  **product\_domain_name**  
*  **environment\_type**  
*  **key\_name**  
*  **desired\_worker\_nodes**  
*  **max\_worker\_nodes**  
*  **min\_worker\_nodes**  
*  **worker\_node\_instance\_type**  
*  **enable\_pod\_autoscaling**  
*  **enable\_cluster\_autoscaling**
*  **scaleinprotection**    
*  **owner**

#### Explanation and usage:

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-------:|:--------:|
| **product\_domain\_name** | Name of your product-domain (used in a tag) | string | n/a | no |
| **environment\_type** | Environment where this deployment runs in (used in a tag) | string | n/a | no|
| **cluster\_prefix** | Name prefix of your EKS cluster | string | n/a | yes |
| **desired\_worker\_nodes** | Desired amount of worker nodes (needs to be => then minimum worker nodes) | string | `"1"` | no |
| **http\_proxy** | IP[:PORT] address and  port of HTTP proxy for your environment | string | `""` | no |
| **key\_name** | Existing key-pair to use to access the instance created by the ASG/LC | string | n/a | yes |
| **max\_worker\_nodes** | Maximum amount of worker nodes to spin up | string | `"6"` | no |
| **min\_worker\_nodes** | Minimum amount of worker nodes (needs to be <= then desired worker nodes). | string | `"1"` | no |
| **no\_proxy** | Endpoint that do not need to go through proxy | string | `""` | no |
| **outputs\_directory** | The local folder path to store output files. Must end with '/' . | string | `"./output/"` | no |
| **private\_subnets** | All private subnets in your VPC | list | n/a | yes |
| **region** | AWS region | string | n/a | yes |
| **tags** | Map of tags to apply to deployed resources | map | `<map>` | no |
| **vpc\_id** | ID of VPC to deploy the cluster | string | n/a | yes |
| **worker\_node\_instance\_type** | Determines the type to use to build your worker group (cluster) | string | `"m4.large"` | no |
| **enable\_pod\_autoscaling** | Enable horizontal autoscaling (pods) | boolean | false |yes |
| **enable\_cluster\_autoscaling** | Enable vertical autoscaling (nodes) | boolean | false | yes |
| **scaleinprotection** | enable scale in prevention for worker nodes | boolean | false | yes |
| **owner** | add owner description to tags set on resources | string | n/a | no |


#### Example:




  

## Outputs


In the folder **./outputs**, several files are created by terraform.  **kubeconfig\_EKS\_NAME** can be used by the operator to access the EKS cluster or to deploy applications.  The other files are not needed during normal operation but will provide insight in how the cluster and nodes are configured.

Also when the terraform script is finished, it will output the following to the console:  

| Name | Description |
|------|-------------|
| **cluster\_endpoint** | Endpoint for EKS control plane. |
| **config\_map\_aws\_auth** | used during the creation of the EKS cluster |
| **kubeconfig** | kubectl config as generated by the module. |
