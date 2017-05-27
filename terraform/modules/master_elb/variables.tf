variable "cluster_name" {}
variable "route53_zone_id" {}

variable "subnet_ids" {
  type = "list"
}

variable "security_groups" {
  type = "list"
}

variable "kubernetes_api_port" {
  default = "6443"
}
