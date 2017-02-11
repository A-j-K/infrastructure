#--------------------------------------------------------------
# This module creates all resources necessary for docker_host 
#--------------------------------------------------------------

variable "name"              { default = "docker_host" }
variable "vpc_id"            { }
variable "vpc_cidr"          { }
variable "key_name"          { }
variable "subnet_ids"        { }
variable "atlas_username"    { }
variable "atlas_environment" { }
variable "atlas_token"       { }
variable "amis"              { }
variable "nodes"             { }
variable "instance_type"     { }
variable "sub_domain"        { }
variable "route_zone_id"     { }

resource "aws_security_group" "docker_host" {
  name        = "${var.name}"
  vpc_id      = "${var.vpc_id}"
  description = "docker_host security group"

  tags      { 
    Name = "${var.name}" 
    Demo = "true"
  }
  lifecycle { create_before_destroy = true }

  ingress {
    protocol    = "tcp"
    from_port   = 22 
    to_port     = 22 
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443 
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "template_file" "user_data" {
  template = "${path.module}/docker_host.sh.tpl"
  count    = "${var.nodes}"

  lifecycle { create_before_destroy = true }

  vars {
    node_name         = "${var.name}-${count.index+1}"
  }
}

resource "aws_instance" "docker_host" {
  ami           = "${element(split(",", var.amis), count.index)}"
  count         = "${var.nodes}"
  instance_type = "${var.instance_type}"
  key_name      = "${var.key_name}"
  subnet_id     = "${element(split(",", var.subnet_ids), count.index)}"
  user_data     = "${element(template_file.user_data.*.rendered, count.index)}"

  vpc_security_group_ids = ["${aws_security_group.docker_host.id}"]

  tags      { Name = "${var.name}" }
  lifecycle { create_before_destroy = true }
}

resource "aws_route53_record" "docker_host_public" {
  zone_id = "${var.route_zone_id}"
  name    = "docker_host.${var.sub_domain}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.docker_host.*.public_ip}"]
}

resource "aws_route53_record" "docker_host_private" {
  zone_id = "${var.route_zone_id}"
  name    = "private.docker_host.${var.sub_domain}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.docker_host.*.private_ip}"]
}

output "public_ips"   { value = "${join(",", aws_instance.docker_host.*.public_ip)}" }
output "private_ips"  { value = "${join(",", aws_instance.docker_host.*.private_ip)}" }
output "public_fqdn"  { value = "${aws_route53_record.docker_host_public.fqdn}" }
output "private_fqdn" { value = "${aws_route53_record.docker_host_private.fqdn}" }

