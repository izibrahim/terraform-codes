variable "instance_type" {
  type    = string
  default = "t2.mirco"
}



variable "usernames" {
  type    = list(any)
  default = ["dev-loadbalancer", "stage-loadbalanacer", "prod-loadbalancer"]
}


variable "ec2_instance" {
  type    = list(any)
  default = ["ec1", "ec2", "ec3"]
}


locals {
  common_tags = {
    department = "IT"
    app = "kubernate"
  }
}
