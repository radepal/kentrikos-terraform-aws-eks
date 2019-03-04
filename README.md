# A Terraform module to deploy an AWS EKS Cluster in a restricted VPC (with corporate proxy)

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
*  **protect_cluster_from_scale_in**    

#### Explanation and usage:

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-------:|:--------:|
| **region** | AWS region | string | n/a | yes |
| **vpc\_id** | ID of VPC to deploy the cluster | string | n/a | yes |
| **private\_subnets** | All private subnets in your VPC | list | n/a | yes |
| **product\_domain\_name** | Name of your product-domain (used in a tag) | string | n/a | no |
| **environment\_type** | Environment where this deployment runs in (used in a tag) | string | n/a | no|
| **cluster\_prefix** | Name prefix of your EKS cluster | string | n/a | yes |
| **http\_proxy** | IP[:PORT] address and  port of HTTP proxy for your environment | string | `""` | no |
| **no\_proxy** | Endpoint that do not need to go through proxy | string | `""` | no |
| **key\_name** | Existing key-pair to use to access the instance created by the ASG/LC | string | n/a | yes |
| **desired\_worker\_nodes** | Desired amount of worker nodes (needs to be => then minimum worker nodes) | string | `"1"` | no |
| **min\_worker\_nodes** | Minimum amount of worker nodes (recommend 1 or more, but smaller then 'max') | string | `"1"` | no |
| **max\_worker\_nodes** | Maximum amount of worker nodes to spin up | string | `"6"` | no |
| **worker\_node\_instance\_type** | Determines the type to use to build your worker group (cluster) | string | `"m4.large"` | no |
| **enable\_pod\_autoscaling** | Enable horizontal autoscaling (pods) | boolean | false |yes |
| **enable\_cluster\_autoscaling** | Enable vertical autoscaling (nodes) | boolean | false | yes |
| **protect\_cluster\_from\_scale\_in** | enable scale in prevention for worker nodes | boolean | false | yes |
| **tags** | Map of tags to apply to deployed resources | map | `<map>` | no |
| **outputs\_directory** | The local folder path to store output files. Must end with '/' . | string | `"./output/"` | no |


#### Example:

| Variable | Value | explanation | 
|:------:|:-------------:|:----:|
|**region** | "us-east-1" | the region you want to deploy the EKS.|
|**vpc_id** | "vpc-12345678"|your VPC ID to deploy the EKS to. |
|**private\_subnets** |"["subnet-12345678", "subnet-23456789", "subnet-34567890"]"|your private subnets in the VPC to use for the EKS, in a list format.|
|**product\_domain\_name** | "ec2\_node\_private\_vpc" | the name of your product.  This is used as a tag.|
|**environment\_type** | "dev" | tag to show what environment this deployment lives in |
|**cluster\_prefix** | "my-eks" | the unique name for your EKS cluster |
|**http\_proxy** | "http://1.1.1.1:80"|your proxy in the transit account.| 
|**no\_proxy** | "localhost,127.0.0.1,10.0.0.0/8,172.16.0.0/12,.internal"|the endpoint(s) that should not use the above described proxy. |
|**key\_name** | "my-key-pair"| existing key-pair to be able to connect to the nodes.|  
| **desired\_worker\_nodes** | '"1"' | 1 worker will be spun up in your worker group  |
| **min\_worker\_nodes** |  '"1"' | 1 worker node will always run (high availability) |
| **max\_worker\_nodes** | '"6"' | a maximum of 6 worker nodes will be utilized (when 'enable\_cluster\_autoscaling' is set to 'true') | 
| **worker\_node\_instance\_type** | "t3.medium" | instance types used in this worker group (the larger, the more free IP's you need) |
| **enable\_pod\_autoscaling** | true | POD Autoscaling is enabled in your environment (the deployment of your app determines if this is actually utlized)  |
| **enable\_cluster\_autoscaling** | true | Autoscaling in your worker group is enabled, based on the policy and load |
| **protect_cluster_from_scale_in** | true | Scale in prevention is set for the worker group (the cluster will scale up (based on enable\_cluster\_autoscaling setting) but not scale down) | 
| **tags** |  Name = Value | Map of tags to apply to deployed resources |
| **outputs\_directory** | ./my-output/ | The local folder path to store output files. Must end with '/' |


## Outputs


In the folder **./outputs**, several files are created by terraform.  **kubeconfig\_EKS\_NAME** can be used by the operator to access the EKS cluster or to deploy applications.  The other files are not needed during normal operation but will provide insight in how the cluster and nodes are configured.

Also when the terraform script is finished, it will output the following to the console:  

| Name | Description |
|------|-------------|
| **cluster\_endpoint** | Endpoint for EKS control plane. |
| **config\_map\_aws\_auth** | used during the creation of the EKS cluster |
| **kubeconfig** | kubectl config as generated by the module. |
