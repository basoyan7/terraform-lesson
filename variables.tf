
variable "vpc_id" {
  type    = string
}

variable "vpc_cidr" {
  type    = string
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

