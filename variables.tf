variable "vpc_id" {
  default = "vpc-40832228"
}

data "aws_vpc" "selected" {
  id = "${var.vpc_id}"
}
