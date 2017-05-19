module "master_security_group" {
  source = "../modules/master_security_group"

  cluster_name = "${var.cluster_name}"
}
