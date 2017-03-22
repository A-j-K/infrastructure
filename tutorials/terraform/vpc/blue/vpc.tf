
### Default variables
variable "colour" { default = "blue" }

### Provided via TF_VAR envs
variable "region" { }

terraform {
        backend "s3" {
                bucket = "io-ajk-terraform-state-files"
                key = "io-ajk-blue-vpc.tfstate"
                region = "eu-west-1"
                encrypt = "true"
                lock_table = "terraform_locks"
        }
}

provider "aws" {
	region = "${var.region}"
}
                                                                                                                                                
module "vpc" {
	source = "github.com/terraform-community-modules/tf_aws_vpc"
	name = "${var.colour}-tf-vpc"
	cidr = "10.24.0.0/16" 
	azs = ["${var.region}a","${var.region}b","${var.region}c"]
	private_subnets = ["10.24.11.0/24","10.24.12.0/24","10.24.13.0/24"]
	public_subnets  = ["10.24.1.0/24","10.24.2.0/24","10.24.3.0/24"]
	enable_nat_gateway = "true"
	enable_dns_support = "true"
	enable_dns_hostnames = "true"
	tags {
		"Terraform" = "true"
		"Environment" = "io-ajk-test"
		"SubEnvironment" = "green"
	}
}

output "colour" {
	value = "${var.colour}"
}

output "vpc_id" {
	value = "${module.vpc.vpc_id}"
}

output "vpc_public_subnets" {
	value = "${module.vpc.public_subnets}"
}

output "vpc_private_subnets" {
	value = "${module.vpc.private_subnets}"
}

output "vpc_public_route_table_ids" {
	value = "${module.vpc.public_route_table_ids}"
}

output "vpc_private_route_table_ids" {
	value = "${module.vpc.private_route_table_ids}"
}

output "vpc_default_security_group_id" {
	value = "${module.vpc.default_security_group_id}"
}

output "vpc_nat_eips" {
	value = "${module.vpc.default_security_group_id}"
}

output "vpc_nat_eips_public_ips" {
	value = "${module.vpc.nat_eips_public_ips}"
}

output "vpc_igw_id" {
	value = "${module.vpc.igw_id}"
}

