
## Provide a colour (blue/green)
variable "colour" { }

## Provide you github account user name
variable "github_user" { default = "" }

## Provided via TF_VAR envs
variable "region" { }
variable "zone_id" { }
variable "domain" { }

provider "aws" {
	region = "${var.region}"
}
                                                                                                                                                
module "vpc" {
	source = "github.com/terraform-community-modules/tf_aws_vpc"
	name = "${var.colour}-tf-vpc"
	cidr = "10.24.0.0/16" 
	azs = ["${var.region}a"]
	private_subnets = ["10.24.11.0/24"]
	public_subnets  = ["10.24.1.0/24"]
	enable_nat_gateway = "true"
	enable_dns_support = "true"
	enable_dns_hostnames = "true"
	tags {
		"Terraform" = "true"
		"Environment" = "io-ajk-test"
		"SubEnvironment" = "green"
	}
}

###
# Bastion host
###

resource "aws_iam_role" "role" {
	name = "bastion-host-iam-role-${var.colour}"
	path = "/"
	assume_role_policy = "${file("${path.module}/bastion_iam_role.json")}"
}

resource "aws_iam_policy" "policy" {
	name = "bastion-host-iam-policy-${var.colour}"
	path = "/"
	policy = "${file("${path.module}/bastion_iam_policy.json")}"
}

resource "aws_iam_policy_attachment" "attach" {
	name = "bastion-host-iam-policy-attachment-${var.colour}"
	roles = ["${aws_iam_role.role.name}"]
	policy_arn = "${aws_iam_policy.policy.arn}"
}

resource "aws_iam_instance_profile" "iam_profile" {
	name = "bastion-host-iam-instance-profile-${var.colour}"
	roles = [
		"${aws_iam_role.role.name}"
	]
}

data "template_file" "user_data" {
	template = "${file("${path.module}/bastion_user_data_tpl.sh")}"
	vars {
		colour = "${var.colour}"
		#bastion_id = "${module.bastion.id}"
		github_user = "${var.github_user}"
	}
}

module "bastion" {
	source                      = "github.com/terraform-community-modules/tf_aws_bastion_s3_keys"
	vpc_id                      = "${module.vpc.vpc_id}"
	#eip                         = "${module.bastion.public_ip}"
	associate_public_ip_address = true
	instance_type               = "t2.micro"
	ami                         = "ami-739fbb15"
	region                      = "${var.region}"
	iam_instance_profile        = "${aws_iam_instance_profile.iam_profile.id}"
	s3_bucket_name              = "io-ajk-teraform-green-keys"
	subnet_ids                  = "${module.vpc.public_subnets}"
	keys_update_frequency       = "5,20,35,50 * * * *"
	additional_user_data_script = "${data.template_file.user_data.rendered}"
}

#resource "aws_route53_record" "bastion" {
#	zone_id = "${var.zone_id}"
#	name = "bastion-${var.colour}.${var.domain}"
#	type = "A"
#	ttl = "300"
#	records = ["${module.bastion.public_ip}"]
#}

output "colour" {
	value = "${var.colour}"
}

output "vpc_id" {
	value = "${module.vpc.vpc_id}"
}

output "public_subnets" {
	value = "${module.vpc.public_subnets}"
}

output "private_subnets" {
	value = "${module.vpc.private_subnets}"
}

output "public_route_table_ids" {
	value = "${module.vpc.public_route_table_ids}"
}

output "private_route_table_ids" {
	value = "${module.vpc.private_route_table_ids}"
}

output "default_security_group_id" {
	value = "${module.vpc.default_security_group_id}"
}

output "nat_eips" {
	value = "${module.vpc.default_security_group_id}"
}

output "nat_eips_public_ips" {
	value = "${module.vpc.nat_eips_public_ips}"
}

output "igw_id" {
	value = "${module.vpc.igw_id}"
}


