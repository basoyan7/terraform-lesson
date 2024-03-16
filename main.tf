data "aws_ssm_parameter" "my_amzn_linux_ami" {  
   name     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "random_string" "random" {
  length           = 16
  special          = true
  override_special = "/@£$"
  depends_on = [
    aws_security_group.allow_tls,
    aws_vpc_security_group_ingress_rule.allow_tls_ipv4,
    aws_vpc_security_group_egress_rule.allow_all_traffic_ipv4,
    aws_instance.web
  ]
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = var.vpc_cidr
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_instance" "web" {
  ami           = data.aws_ssm_parameter.my_amzn_linux_ami.insecure_value
  instance_type = var.instance_type
  security_groups = [aws_security_group.allow_tls.name]
  tags = {
    Name = local.tag_prefix
  }
}

