variable "cluster_name" {}
variable "route53_zone_id" {}
variable "ssh_key_name" {}
variable "ssl_key_bucket" {}

variable "desired_capacity" {}
variable "max_size" {}
variable "min_size" {}

variable "availability_zones" {
  type = "list"
}

variable "instance_type" {
  default = "m3.medium"
}

variable "security_groups" {
  type = "list"
}

variable "subnet_ids" {
  type = "list"
}
