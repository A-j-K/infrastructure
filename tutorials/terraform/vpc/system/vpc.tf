
variable "enviroment" { }

module "vpc" {
	source = "github.com/terraform-community-modules/tf_aws_vpc"
	name = "${var.name}-tf-vpc"
	cidr = "${var.vpc_cidr}" 
	azs = ["${var.azs}"]
	private_subnets = ["10.244.11.0/24","10.244.12.0/24","10.244.13.0/24"]
	public_subnets  = ["10.244.1.0/24","10.244.2.0/24","10.244.3.0/24"]
	enable_nat_gateway = "true"
	enable_dns_support = "true"
	enable_dns_hostnames = "true"
	tags {
		"Terraform" = "true"
		"Environment" = "vpc-${var.enviroment}"
		"OWNER" = "andyk"
	}
}

