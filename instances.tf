locals {
  instances = {
    for i in range(var.nos) :
    "instance-${i + 1}" => data.aws_subnets.default_subents.ids[i % length(data.aws_subnets.default_subents.ids)]
  }
}

resource "aws_instance" "vms" {
  for_each               = local.instances
  ami                    = data.aws_ami.ubuntu.id
  vpc_security_group_ids = [aws_security_group.vms-sg.id]
  subnet_id              = each.value
  instance_type          = var.type_instance
  key_name               = var.key
  user_data = templatefile("${path.module}/user_data.tpl", {
    instance_name = each.key
  })

  tags = {
    Name = each.key
  }

  lifecycle {
    create_before_destroy = true
  }
  depends_on = [aws_lb.alb]
}

resource "aws_security_group" "vms-sg" {
  name        = "vms-sg"
  description = "security group for the vms"
}

resource "aws_vpc_security_group_ingress_rule" "from-alb" {
  security_group_id            = aws_security_group.vms-sg.id
  from_port                    = var.http
  to_port                      = var.http
  referenced_security_group_id = aws_security_group.alb-sg.id
  ip_protocol                  = "tcp"
}
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.vms-sg.id
  from_port         = var.ssh
  to_port           = var.ssh
  cidr_ipv4         = var.cidr
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "all-alb" {
  security_group_id = aws_security_group.vms-sg.id
  ip_protocol       = "-1"
  cidr_ipv4         = var.cidr
}