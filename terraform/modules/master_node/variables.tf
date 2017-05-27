variable "availability_zone" {}
variable "cluster_name" {}
variable "kms_key_arn" {}
variable "master_count" {}
variable "master_id" {}
variable "route53_zone_id" {}
variable "ssh_key_name" {}
variable "ssl_key_bucket" {}
variable "subnet_id" {}

variable "load_balancer_ids" {
  type = "list"
}

variable "security_groups" {
  type = "list"
}

variable "instance_type" {
  default = "m3.medium"
}
