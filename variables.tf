variable "create_resources" {
  description = "Conditional resource creation."
  type = bool
  default = true
}

variable "dependency_string" {
  description = "String input from a resource attribute or module output that forms a dependency on that resource completing before this ingress controller is deployed. The most common usage of this variable is to form an arbitrary dependency on a Kubernetes object, or a Kubernetes cluster."
  type = string
  default = ""
}

variable "ingress_class" {
  description = "Name of the class which ingress objects will use to route traffic. Each controller deployment in the same cluster must use its own class."
  type = string
  default = "nginx"
}

variable "name" {
  description = "Ingress controller Helm chart release name."
  type = string
  default = "nginx"
}

variable "namespace" {
  description = "Ingress controller Helm chart namespace."
  type = string
  default = "default"
}

variable "namespace_scope" {
  description = "Whether to restrict the scope of the ingress controller to a single namespace (defined via the 'namespace' variable). By default, the controller will watch all namespaces for ingress events."
  type = bool
  default = false
}

variable "min_replicas" {
  description = "Ingress controller autoscaling minimum replica count. A reasonable value is typically one replica per fault domain."
  type = number
  default = 1
}

variable "max_replicas" {
  description = "Ingress controller autoscaling maximum replica count. Must be greater than or equal to min_replicas."
  type = number
  default = 1
}

variable "nlb_cert_arn" {
  description = "AWS resource name (ARN) of a TLS/SSL Cert, as managed by AWS Certificate Manager (ACM)."
  type = string
}

variable "kind" {
  description = "How to deploy ingress controller pods. Values can be either Deployment or DaemonSet."
  type = string
  default = "DaemonSet"
}
