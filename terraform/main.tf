resource "aws_vpc" "vpc" {
  cidr_block              = var.vpc_cidr

  tags = {
    Name                  = "${var.project_name_prefix}_vpc"
  }
}

resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet_cidr
  availability_zone       = var.subnet_az
  map_public_ip_on_launch = true

  tags = {
    Name                  = "${var.project_name_prefix}_subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id                  = aws_vpc.vpc.id

  tags = {
    Name                  = "${var.project_name_prefix}_igw"
  }
}

resource "aws_route_table" "rtb" {
  vpc_id                  = aws_vpc.vpc.id

  route {
    cidr_block            = "0.0.0.0/0"
    gateway_id            = aws_internet_gateway.igw.id
  }

  tags = {
    Name                  = "${var.project_name_prefix}_rtb"
  }
}

resource "aws_route_table_association" "rtb_association" {
  subnet_id               = aws_subnet.subnet.id
  route_table_id          = aws_route_table.rtb.id
}

resource "aws_security_group" "sg" {
  name                    = "${var.project_name_prefix}_sg"
  vpc_id                  = aws_vpc.vpc.id

  tags = {
    Name                  = "${var.project_name_prefix}_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "sg_http" {
  security_group_id         = aws_security_group.sg.id
  cidr_ipv4                 = "0.0.0.0/0"
  from_port                 = 80
  ip_protocol               = "tcp"
  to_port                   = 80

  tags = {
    Name                    = "${var.project_name_prefix}_sg_http"
  }
}

resource "aws_vpc_security_group_ingress_rule" "sg_ssh" {
  security_group_id         = aws_security_group.sg.id
  cidr_ipv4                 = var.ssh_cidr_block
  from_port                 = 22
  ip_protocol               = "tcp"
  to_port                   = 22

  tags = {
    Name                    = "${var.project_name_prefix}_sg_ssh"
  }
}

resource "aws_vpc_security_group_egress_rule" "sg_within" {
  security_group_id         = aws_security_group.sg.id
  cidr_ipv4                 = "0.0.0.0/0"
  ip_protocol               = "-1"

  tags = {
    Name                    = "${var.project_name_prefix}_sg_within"
  }
}

data "aws_ami" "latest_ubuntu_server_image" {
  most_recent               = true
  owners                    = ["099720109477"]

  filter {
    name                    = "name"
    values                  = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name                    = "architecture"
    values                  = ["x86_64"]
  }
}

resource "aws_key_pair" "ssh_key" {
  key_name                  = "${var.project_name_prefix}_ssh_key"
  public_key                = file(var.ssh_file_location)

  tags = {
    Name                    = "${var.project_name_prefix}_ssh_key"
  }
}

resource "aws_instance" "ec2_instance" {
  ami                       = data.aws_ami.latest_ubuntu_server_image.id
  instance_type             = var.instance_type

  subnet_id                 = aws_subnet.subnet.id
  vpc_security_group_ids    = [aws_security_group.sg.id]
  availability_zone         = var.subnet_az

  associate_public_ip_address = true
  key_name                  = aws_key_pair.ssh_key.key_name

  tags = {
    Name                    = "${var.project_name_prefix}_ec2_instance"
  }
}

resource "aws_eip" "eip" {
  instance                  = aws_instance.ec2_instance.id
  domain                    = "vpc"

  tags = {
    Name                    = "${var.project_name_prefix}_eip"
  }
}

data "aws_route53_zone" "selected" {
  name                      = var.domain_name
}

resource "aws_route53_record" "www" {
  zone_id                   = data.aws_route53_zone.selected.zone_id
  name                      = "www.${var.domain_name}"
  type                      = "A"
  ttl                       = 300
  records                   = [aws_eip.eip.public_ip]
}

#  name                      = var.domain_name

resource "aws_route53_record" "root" {
  zone_id 		    = data.aws_route53_zone.selected.zone_id
  name    		    = var.domain_name
  type    		    = "A"
  ttl    		    = 300
  records 		    = [aws_eip.eip.public_ip]
}
