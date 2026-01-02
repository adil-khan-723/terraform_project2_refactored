resource "aws_lb" "alb" {
  internal                   = false
  name                       = "alb"
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb-sg.id]
  subnets                    = data.aws_subnets.default_subents.ids
  enable_deletion_protection = true

  tags = {
    Environment = "test"
  }
}

resource "aws_security_group" "alb-sg" {
  name        = "alb-sg"
  description = "security group for the loadbalancer"
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.alb-sg.id
  from_port         = var.http
  to_port           = var.http
  ip_protocol       = "tcp"
  cidr_ipv4         = var.cidr
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.alb-sg.id
  ip_protocol       = "-1"
  cidr_ipv4         = var.cidr
}

output "load_balancer_DNS" {
  value = aws_lb.alb.dns_name
}