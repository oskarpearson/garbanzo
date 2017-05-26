resource "aws_subnet" "master" {
  vpc_id                  = "${var.vpc_id}"
  availability_zone       = "${var.availability_zone}"
  cidr_block              = "${var.cidr_range}"
  map_public_ip_on_launch = "${var.map_public_ip_on_launch}"

  tags {
    Name            = "${var.cluster_name}-master-${var.master_id}"
    kubernetes      = "true"
    kubernetes_type = "master"
    cluster_name    = "${var.cluster_name}"
  }
}

output "subnet_id" {
  value = "${aws_subnet.master.id}"
}
