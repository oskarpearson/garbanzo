variable "vpc_id" {}
variable "cluster_name" {}
variable "ssh_key_name" {}
variable "kms_key_arn" {}

variable "availability_zones" {
  type = "map"
}
