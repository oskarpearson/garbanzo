variable "cluster_name" {}
variable "availability_zone" {}
variable "master_id" {}
variable "ssh_key_name" {}
variable "subnet_id" {}
variable "kms_key_arn" {}

variable "load_balancer_ids" {
  type = "list"
}

variable "security_groups" {
  type = "list"
}

variable "instance_type" {
  default = "m3.medium"
}
