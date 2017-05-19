variable "cluster_name" {}
variable "availability_zone" {}
variable "number" {}
variable "ssh_key_name" {}

variable "security_groups" {
  type = "list"
}

variable "instance_type" {
  default = "m3.medium"
}
