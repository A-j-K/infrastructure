
### Default variables
variable "colour" { default = "green" }

### Provided via TF_VAR envs
variable "region" { }
variable "zone_id" { }
variable "domain" { }

provider "aws" {
	region = "${var.region}"
}
                                                                                                                                                
module "vpc" {
	source = "../../modules/vpc"
	colour = "${var.colour}"
	github_user = "https://github.com/A-j-K.keys"
	region = "${var.region}"
	zone_id = "${var.zone_id}"
	domain = "${var.domain}"
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


