terraform {
  backend "s3" {
    key = "master/terraform.tfstate"

    # bucket = "will-be-set-by-init-interactively"
    # region = "will-be-set-by-init-interactively"
  }
}
