resource "aws_eip" "master" {
  vpc = true
}

resource "aws_route53_record" "eip" {
  zone_id = "${var.route53_zone_id}"
  name    = "master-${var.master_id}.${var.cluster_name}"

  type    = "A"
  ttl     = "30"
  records = ["${aws_eip.master.public_ip}"]
}
