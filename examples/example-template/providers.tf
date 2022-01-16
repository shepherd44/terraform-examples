variable "profile" {
  type = string
  default = "default"
}

variable "default_region" {
  type = string
  default = "ap-northeast-2"
}

provider "aws" {
  profile = var.profile
  region = var.default_region
}
