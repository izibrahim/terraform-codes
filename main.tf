
terraform {
  required_providers {
    aws = {
    }
    google = {
      source  = "hashicorp/google"
      version = "4.27.0"
    }
    github = {

    }
  }
}


provider "aws" {
  region = "us-east-2"
}

provider "aws" {
  region = "us-west-2"
  alias  = "west"
}

data "aws_ami" "app_ami" {
  most_recent = true
  owners      = ["amazon"]


  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*"]
  }
}


data "aws_ami" "app_region" {
  most_recent = true
  owners      = ["amazon"]
  provider    = aws.west


  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*"]
  }
}


resource "aws_instance" "vm_instance_one" { # This is resource block type is here "aws_instance"  and resource name is "vm_instance"
  #name = "ec2_instance"
  ami           = data.aws_ami.app_ami.id #  arguments  and argument can be include things like machine sizes, disk image names, or VPC IDs and etc
  instance_type = "t2.micro"
  key_name = "remote_exec"
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("./remote_exec.pem") # ./ means current working directory
    host        = self.public_ip
  }
  provisioner "remote-exec" {
    on_failure = continue # Now this will not mark as resoucre as taint.
    inline = [
      "mkdir remote_exec",
      "cd remote_exec",
      "cat > cat.txt" # if any of this command fail provisinar will fail and mark resouces as taint
    ]
  }
  tags = {
    test = var.ec2_instance[count.index]
  }
  count = 3

}

/*
resource "aws_instance" "vm_instance_two" { # This is resource block type is here "aws_instance"  and resource name is "vm_instance"
  #name = "ec2_instance"
  ami           = data.aws_ami.app_region.id #  arguments  and argument can be include things like machine sizes, disk image names, or VPC IDs and etc
  instance_type = "t2.micro"
  provider      = aws.west
  tags = {
    test = var.ec2_instance[count.index]
  }
  count = 3
}

resource "aws_eip" "lb2" {
  vpc      = true
  provider = aws.west
  count    = var.is_test == true ? 2 : 0
}

resource "aws_ebs_volume" "db_ebs" {
  availability_zone = "us-west-2a"
  provider          = aws.west
  size              = 8
  tags              = local.common_tags
}


variable "is_test" {
  default = true
}

resource "aws_eip" "lb" {
  vpc = true
}


resource "aws_iam_user" "lb" {
  name  = var.usernames[count.index]
  path  = "/system/"
  count = 3
}


output "iam_user" {
  value = aws_iam_user.lb[*].arn
}



output "vitrual_ip" {
  value = aws_eip.lb.public_ip
}

output "tags-name" {
  value = aws_instance.vm_instance_one[*].tags
}

# below code is use to import the resource

resource "aws_instance" "ec2_import_resource" { # This is resource block type is here "aws_instance"  and resource name is "vm_instance"
  ami           = "ami-02d1e544b84bf7502"
  instance_type = "t2.micro"
  tags = {
    Name = "ec2_instance"
  }
}
#
output "lists_of_res" {
  value = concat(aws_iam_user.lb[*].arn, aws_instance.vm_instance_one[*].tags)
}




#terraform import aws_instance.ec2_import_resource i-0a145f9a867bf6043

# finding once i added the google and run the validate command it findout that the provide google not installed
#D:\Cloud\Terraforn-BootCamp-Udemy\codes\Practice TF>terraform validate

???
??? Error: Missing required provider
???
??? This configuration requires provider registry.terraform.io/hashicorp/google, but that provider isn't available. You
??? may be able to install it automatically by running:
???   terraform init

Key point
==========
Validation requires an initialized working directory with any referenced
plugins and modules installed. To initialize a working directory for
validation without accessing any configured remote backend, use:
    terraform init -backend=false


terraform Import


  Import existing infrastructure into your Terraform state.

  This will find and import the specified resource into your Terraform
  state, allowing existing infrastructure to come under Terraform
  management without having to be initially created by Terraform.

  The ADDR specified is the address to import the resource to. Please
  see the documentation online for resource addresses. The ID is a
  resource-specific ID to identify that resource being imported. Please
  reference the documentation for the resource type you're importing to
  determine the ID syntax to use. It typically matches directly to the ID
  that the provider uses.

  The current implementation of Terraform import can only import resources
  into the state. It does not generate configuration. A future version of
  Terraform will also generate configuration.

  Because of this, prior to running terraform import it is necessary to write
  a resource configuration block for the resource manually, to which the
  imported object will be attached.

  This command will not modify your infrastructure, but it will make
  network requests to inspect parts of your infrastructure relevant to
  the resource being imported.

  To disable the TF_LOG=off this is disable the log dont copy the TF_LOG= to github
  it have access key info

  terraform refresh and terraform state mv create the backup state files
  alais provider name must be string

  state file not maintain any thing related to provisioners lcoal/exec
      on_failure = continue # Now this will not mark as resoucre as taint.
*/
