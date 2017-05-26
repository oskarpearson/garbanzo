variable "cluster_name" {}

variable "subnet_ids" {
  type = "list"
}

variable "security_groups" {
  type = "list"
}

variable "kubernetes_api_port" {
  default = "6443"
}
