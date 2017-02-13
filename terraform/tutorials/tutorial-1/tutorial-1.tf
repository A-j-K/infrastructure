
variable "vpc_cidr" {}
variable "azs" {}
variable "name" {}

provider "aws" {
  region = "us-east-1"
}
  
module "tutorial-vpc" {
  source = "github.com/terraform-community-modules/tf_aws_vpc"
  name = "${var.name}-vpc"
  cidr = "${var.vpc_cidr}"
  private_subnets = ["10.249.1.0/24","10.249.2.0/24","10.249.3.0/24"]
  public_subnets  = ["10.249.11.0/24","10.249.12.0/24","10.249.13.0/24"] 
  enable_nat_gateway = "true"
  enable_dns_support = "true"
  enable_dns_hostnames = "true"
  azs      = ["${var.azs}"]
  tags {
    "Terraform" = "true"
    "Environment" = "tutorial"
  }
}

module "ssh_only_sg" {
  source = "git@github.com:A-j-K/terraform-modules.git//tutorials/tf_aws_sg/sg_ssh_only?ref=master"
  security_group_name = "${var.name}-docker-host-ssh-only-sg"
  vpc_id = "${module.tutorial-vpc.vpc_id}"
  source_cidr_block = "0.0.0.0/0"
}

module "https_only_sg" {
  source = "git@github.com:A-j-K/terraform-modules.git//tutorials/tf_aws_sg/sg_https_only?ref=master"
  security_group_name = "${var.name}-docker-host-https-only-sg"
  vpc_id = "${module.tutorial-vpc.vpc_id}"
  source_cidr_block = "0.0.0.0/0"
}

module "iam_role" {
  source = "git@github.com:A-j-K/terraform-modules.git//tutorials/tf_aws_iam/iam_instance_role?ref=master"
  name = "${var.name}"
  path = "/"
  policy = "${file("resources/s3-full-policy.json")}"
  assume_role_policy = "${file("resources/ec2-allow.json")}"
}

module "docker_host_3" {
  source = "git@github.com:A-j-K/terraform-modules.git//tutorials/docker_host?ref=master"
  name = "${var.name}-docker-host"
  ami = "ami-c4e924d2"
  instance_type = "t2.micro"
  iam_instance_profile = "${module.iam_role.iam_profile_id}"
  subnet_id = "${element(module.tutorial-vpc.public_subnets, 0)}"
  vpc_security_group_ids = [
    "${module.ssh_only_sg.security_group_id_ssh_only}",
    "${module.https_only_sg.security_group_id_https_only}"
  ]
  user_data = "${file("resources/user_data.sh")}"
}


