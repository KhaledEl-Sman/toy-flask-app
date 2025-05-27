variable "project_name_prefix" {default = "dev-botit"}
variable "domain_name" {default = "mazzady.club"}
variable "vpc_cidr" {default = "10.1.0.0/16"}
variable "subnet_az" {default = "eu-west-1b"}
variable "subnet_cidr" {default = "10.1.0.0/20"}
variable "instance_type" {default = "t3.micro"}
variable "ssh_cidr_block" {default = "78.47.221.219/32"}
variable "ssh_public_key" {}
