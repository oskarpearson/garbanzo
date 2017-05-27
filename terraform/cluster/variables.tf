variable "cluster_name" {}
variable "kms_key_arn" {}
variable "route53_zone_id" {}
variable "ssh_key_name" {}
variable "ssl_key_bucket" {}
variable "vpc_id" {}

variable "master_count" {
  default = "3"
}

variable "availability_zones" {
  type = "map"
}
