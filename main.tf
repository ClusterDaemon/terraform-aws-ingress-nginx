# Nginx ingress controller provisioner
# Datapath load balancer discovery

# Wait for K8S cluser to become ready.
# A good input for this is an API URL.
resource "null_resource" "k8s_ready" {
  count = var.create_resources == true ? 1 : 0

  triggers = {
    ready = var.dependency_string
  }

}

# Deploy ingress-nginx Helm chart.
# Make sure the kubernetes API server has permission to create NLB objects, if this isn't an EKS deployment.
resource "helm_release" "ingress_nginx" {
  count = var.create_resources == true ? 1 : 0

  name = var.name
  repository= "https://kubernetes.github.io/ingress-nginx"
  chart = "ingress-nginx"
  namespace = var.namespace
  create_namespace = true

  values = [ <<EOF
    controller:
      kind: ${ var.kind }
      scope:
        enabled: ${ var.namespace_scope }
        namespace: ${ var.namespace_scope == true ? var.namespace : "" }
      useComponentLabel: true
      ingressClass: ${ var.ingress_class }
      autoscaling:
        enabled: true
        minReplicas: ${ var.min_replicas }
        maxReplicas: ${ var.max_replicas }
      service:
        externalTrafficPolicy: Local
        targetPorts:
          https: http
        annotations:
          service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
          service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: "true"
          service.beta.kubernetes.io/aws-load-balancer-backend-protocol: "http"
          service.beta.kubernetes.io/aws-load-balancer-ssl-ports: "https"
          service.beta.kubernetes.io/aws-load-balancer-ssl-cert: ${ var.nlb_cert_arn }
    EOF
  ]

  depends_on = [ null_resource.k8s_ready ]
}

# Wait for all objects deployed by Helm to fully function, and for the Kubernetes API to asynchronously create an NLB.
# The sleep time should be equivalent to NLB creation API call timeout. There's probably a better way to verify this rather than waiting.
resource "null_resource" "ingress_ready" {
  count = var.create_resources == true ? 1 : 0

  provisioner "local-exec" {
    command = "sleep 120"
  }

  depends_on = [ helm_release.ingress_nginx ]
}

# Obtain data about the ingress controller unified datapath service object using predefined service name.
data "kubernetes_service" "ingress_nginx" {
  count = var.create_resources == true ? 1 : 0

  metadata {
    name = "${ var.name }-ingress-nginx-controller"
  }

  depends_on = [ null_resource.ingress_ready, helm_release.ingress_nginx ]
}

# Obtain ingress controller load balancer information using first 32 bits of the DNS hostname from Kubernetes service.
data "aws_lb" "ingress_nginx" {
  count = var.create_resources == true ? 1 : 0

  name = local.nlb_name

  depends_on = [ data.kubernetes_service.ingress_nginx ]
}

locals {

  nlb_fqdn = join( "", data.kubernetes_service.ingress_nginx[ * ].load_balancer_ingress.0.hostname )

  # Obtain pretty load balancer name from first 32 bits of its FQDN.
  nlb_name = substr(
    local.nlb_fqdn,
    0,
    32
  )

}
