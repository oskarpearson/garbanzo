variable "vpc_id" {}
variable "cidr_range" {}
variable "availability_zone" {}
variable "cluster_name" {}

variable "map_public_ip_on_launch" {
  default = false
}
