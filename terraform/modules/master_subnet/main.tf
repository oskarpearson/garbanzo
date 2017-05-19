resource "aws_subnet" "master" {
  vpc_id                  = "${var.vpc_id}"
  cidr_block              = "${var.cidr_range}"
  map_public_ip_on_launch = "${var.map_public_ip_on_launch}"
}
