resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${var.tag_prefix}-vpc"
  }
}

resource "aws_subnet" "public1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 1)
  availability_zone = "${var.region}a"
  tags = {
    Name = "${var.tag_prefix}-public"
  }
}

resource "aws_subnet" "public2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 2)
  availability_zone = "${var.region}b"

  tags = {
    Name = "${var.tag_prefix}-public2"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 11)
  availability_zone = "${var.region}a"
  tags = {
    Name = "${var.tag_prefix}-private"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.tag_prefix}-gw"
  }
}


resource "aws_route_table" "publicroutetable" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${var.tag_prefix}-route-table-gw"
  }
}


resource "aws_eip" "nateIP" {
  vpc = true
}


resource "aws_nat_gateway" "NAT" {
  allocation_id = aws_eip.nateIP.id
  subnet_id     = aws_subnet.public1.id

  tags = {
    Name = "${var.tag_prefix}-nat"
  }

}

resource "aws_route_table" "privateroutetable" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NAT.id
  }

  tags = {
    Name = "${var.tag_prefix}-route-table-nat"
  }

}


resource "aws_route_table_association" "PublicRT1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.publicroutetable.id
}

resource "aws_route_table_association" "PublicRT2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.publicroutetable.id
}

resource "aws_route_table_association" "PrivateRT1" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.privateroutetable.id
}

resource "aws_security_group" "web_server_sg" {
  vpc_id      = aws_vpc.main.id
  name        = "web_server_sg"
  description = "web_server_sg"

  ingress {
    description = "http from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "https from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "icmp from internet"
    from_port   = 0
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.tag_prefix}-web_server_sg"
  }
}




resource "aws_network_interface" "web-priv" {
  subnet_id   = aws_subnet.private.id
  private_ips = [cidrhost(cidrsubnet(var.vpc_cidr, 8, 11), 22)]

  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_network_interface_sg_attachment" "sg_attachment" {
  security_group_id    = aws_security_group.web_server_sg.id
  network_interface_id = aws_network_interface.web-priv.id
}

data "cloudinit_config" "server_config" {
  gzip          = true
  base64_encode = true
  part {
    content_type = "text/cloud-config"
    content      = file("${path.module}/scripts/webserver.yml")
  }
}




resource "aws_instance" "web_server" {
  ami           = var.ami
  instance_type = "t2.micro"
  # key_name      = "${var.tag_prefix}-key-pair"

  network_interface {
    network_interface_id = aws_network_interface.web-priv.id
    device_index         = 0
  }

  user_data = data.cloudinit_config.server_config.rendered
  tags = {
    Name = "${var.tag_prefix}-webserver"
  }
  # sometimes the webserver is running before the NAT gateway is available. The webserver is not able to download things
  depends_on = [
    aws_network_interface_sg_attachment.sg_attachment, aws_nat_gateway.NAT
  ]
}




resource "aws_acm_certificate" "cert" {
  private_key       = file("${path.module}/certificates/${var.certificate_private_key_file}")
  certificate_body  = file("${path.module}/certificates/${var.certificate_body_file}")
  certificate_chain = file("${path.module}/certificates/${var.certificate_chain_file}")
}




# loadbalancer Target Group
resource "aws_lb_target_group" "lb_target_group" {
  name     = "${var.tag_prefix}-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_target_group_attachment" "lb_target_group_attachment" {
  target_group_arn = aws_lb_target_group.lb_target_group.arn
  target_id        = aws_instance.web_server.id
  port             = 80
}

# # application load balancer
resource "aws_lb" "lb_application" {
  name               = "${var.tag_prefix}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_server_sg.id]
  subnets            = [aws_subnet.public1.id, aws_subnet.public2.id]

  tags = {
    Environment = "${var.tag_prefix}-lb"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.lb_application.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert.arn


  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }
}

data "aws_route53_zone" "selected" {
  name         = var.dns_zonename
  private_zone = false
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.dns_hostname
  type    = "CNAME"
  ttl     = "300"
  records = [aws_lb.lb_application.dns_name]
}
