variable "cluster_name" {}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name         = "${var.cluster_name}"
    kubernetes   = "true"
    cluster_name = "${var.cluster_name}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    kubernetes   = "true"
    cluster_name = "${var.cluster_name}"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = "${aws_vpc.main.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.main.id}"
}
