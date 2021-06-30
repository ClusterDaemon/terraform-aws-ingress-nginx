# terraform-aws-ingress-nginx

Terraform resource module that deploys an "ingress-nginx" Helm chart from the "stable" repository that creates a TLS-terminated NLB oject in AWS, and provides rich output regarding that NLB. Using this pattern, a suite of applications can be exposed via a single NLB object with TLS protection managed outside of Kubernetes - no need to manage TLS secrets.

This is useful when forming route53 records or VPC endpoint services that point to such an NLB object, as this module provides strong interdependency guarantees that are needed to make such a solution function reliably.

While the included example is written for the EKS Terraform module, this module will work for any Kubernetes implementation in AWS with sufficient permissions. Details on establishing those permissions is not in the scope of this document. If in doubt, try it with EKS.

- [terraform-aws-ingress-nginx](#terraform-aws-ingress-nginx)
  - [Dependencies](#dependencies)
  - [Resource Types](#resource-types)
  - [Features](#features)
  - [Usage](#usage)
  - [Inputs](#inputs)
  - [Outputs](#outputs)
  - [Contributing](#contributing)
  - [Change Log](#change-log)
  - [Authors](#authors)

## Dependencies

| Provider | Version |
| --- | --- |
| aws | ~> 2.45 |
| kubernetes | ~> 1.11 |
| helm | ~> 1.3.0 |


## Resource Types

 * null\_resource
 * helm\_release


## Features:

 - Resilient autoscaling ingress controller deployment via Nginx and Helm3.
 - Vital output for resulting Kubernetes Service object.
 - Vital output for resulting AWS NLB object.
 - All resources optionally dependent on arbitrary input variable


## Usage:

See the [examples directory](examples) for complete example usage.

### Calling Providers:

```hcl
provider "aws" {
  region  = var.region
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.eks.token
  load_config_file       = false
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.eks.token
    load_config_file       = false
  }
}

# Obtain data from these sources to establish Kubernetes provider attribute values.
# The name attribute must be filled with the desired EKS cluster ID.
# This code assumes an EKS cluster was established using the EKS module by the name "EKS".

data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_id
}
```

### Installing the Module:

```hcl
module "ingress" {
  source = "git@github.com/ClusterDaemon/terraform-aws-ingress-nginx.git?ref=v0.3.0"

  #
  # Input attributes
  #
}
```


## Inputs:

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | --- |
| name | Ingress controller Helm chart release name. Must be unique among controller deployments. | string | "nginx" | no |
| ingress\_class | Name of the class which ingress objects will use to route traffic within Kubernetes. Each controller deployment in the same cluster must use a unique class. | string | "nginx" | no |
| namespace | Ingress controller Helm chart namespace. This affects what namespace the chart is managed in, and consequently where its Kubernetes objects are created. If the `namespace_scope` variable is set to `true`, this also affects what namespace the ingress controller watches for events. | string | "default" | no |
| namespace\_scope | Whether to restrict the scope of the ingress controller to a single namespace (defined via the `namespace` variable). By default, the controller will watch all namespaces for ingress events. | bool | false | no |
| min\_replicas | Ingress controller autoscaling minimum replica count. A reasonable value is typically one replica per fault domain. | number | 1 | no |
| max\_replicas | Ingress controller autoscaling maximum replica count. Must be greater than or equal to `min_replicas`. | number | 1 | no |
| nlb\_cert\_arn | Amazon resource name of a TLS/SSL certificate, as managed by AWS Certificate Manager. | string | nil | yes |
| dependency\_string | String input from a resource attribute or module output that forms a dependency on that resource completing before this ingress controller is deployed. The most common usage of this variable is to form an arbitrary dependency on a Kubernetes object, or a Kubernetes cluster. | string | "" | no |
| create\_resources | Controls whether any resource in-module is created. | bool | yes | no |


## Outputs:

| Name | Description | Type |
| --- | --- | --- |
| nlb\_arn | Amazon resource name of the NLB object that is created by Kubernetes when the ingress controller is deployed. | string |
| nlb\_fqdn | Fully qualified domain name of th eingress controller NLB. | string |
| nlb\_zone\_id | Route53 zone ID the ingress controller NLB FQDN is registered in. | string |
| nlb\_name | Pretty name in AWS of the ingress controller NLB. | string |


## Contributing

Report issues/questions/feature requests on in the [issues](https://github.com/ClusterDaemon/terraform-aws-ingress-nginx/issues/new) section.

Full contributing [guidelines are covered here](https://github.com/ClusterDaemon/terraform-aws-ingress-nginx/blob/master/CONTRIBUTING.md).


## Change Log

The [changelog](https://github.com/ClusterDaemon/terraform-aws-ingress-nginx/tree/master/CHANGELOG.md) captures all important release notes.


## Authors

Created and maintained by [David Hay](https://github.com/ClusterDaemon) - david.hay@nebulate.tech
