output "nlb_arn" {
  description = "NLB this ingress controller service creates."
  value = join( "", data.aws_lb.ingress_nginx[ * ].arn )
}

output "nlb_fqdn" {
  description = "Fully qualified domain name of the ingress controller NLB."
  value = local.nlb_fqdn
}

output "nlb_zone_id" {
  description = "Route53 Zone ID the ingress controller NLB FQDN is registered in."
  value = join( "", data.aws_lb.ingress_nginx[ * ].zone_id )
}

output "nlb_name" {
  description = "Pretty name of the ingress controller NLB."
  value = local.nlb_name
}
