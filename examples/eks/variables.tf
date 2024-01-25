variable "prefix" {
  type = string
  default = "example-"
}

variable "eks_cluster_version" {
  type    = string
  default = "1.28"
}

locals {
  tags = {
    Terraform = "true"
    Environment = "example"
    Example = "true"
  }
}
