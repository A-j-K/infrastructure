#--------------------------------------------------------------
# This module creates all compute resources
#--------------------------------------------------------------

variable "name"               { }
variable "region"             { }
variable "vpc_id"             { }
variable "vpc_cidr"           { }
variable "key_name"           { }
variable "azs"                { }
variable "private_subnet_ids" { }
variable "public_subnet_ids"  { }
variable "sub_domain"         { }
variable "route_zone_id"      { }

variable "docker_host_amis"          { }
variable "docker_host_node_count"    { }
variable "docker_host_instance_type" { }


module "docker_host" {
  source = "./docker_host"

  name               = "${var.name}-docker_host"
  vpc_id             = "${var.vpc_id}"
  vpc_cidr           = "${var.vpc_cidr}"
  key_name           = "${var.key_name}"
  subnet_ids         = "${var.public_subnet_ids}"
  amis               = "${var.docker_host_amis}"
  nodes              = "${var.docker_host_node_count}"
  instance_type      = "${var.docker_host_instance_type}"
  sub_domain         = "${var.sub_domain}"
  route_zone_id      = "${var.route_zone_id}"
}

output "docker_host_private_ips"  { value = "${module.docker_host.private_ips}" }
output "docker_host_public_ips"   { value = "${module.docker_host.public_ips}" }
output "docker_host_private_fqdn" { value = "${module.docker_host.private_fqdn}" }
output "docker_host_public_fqdn"  { value = "${module.docker_host.public_fqdn}" }


