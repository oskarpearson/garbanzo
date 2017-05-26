terraform {
  backend "s3" {
    key = "example_vpc/terraform.tfstate"

    # bucket = "will-be-set-by-init-interactively"
    # region = "will-be-set-by-init-interactively"
  }
}
