resource "aws_subnet" "workers" {
  vpc_id                  = "${var.vpc_id}"
  availability_zone       = "${var.availability_zone}"
  cidr_block              = "${var.cidr_range}"
  map_public_ip_on_launch = "${var.map_public_ip_on_launch}"

  tags {
    Name            = "${var.cluster_name}-workers"
    kubernetes      = "true"
    kubernetes_type = "workers"
    cluster_name    = "${var.cluster_name}"
  }
}

output "subnet_id" {
  value = "${aws_subnet.workers.id}"
}
