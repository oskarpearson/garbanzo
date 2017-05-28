resource "aws_eip" "master" {
  vpc = true
}

data "aws_route53_zone" "master" {
  zone_id = "${var.route53_zone_id}"
}

resource "aws_route53_record" "eip" {
  zone_id = "${var.route53_zone_id}"
  name    = "master-${var.master_id}.${var.cluster_name}.${data.aws_route53_zone.master.name}"

  type    = "A"
  ttl     = "30"
  records = ["${aws_eip.master.public_ip}"]
}
