resource "aws_lb_target_group" "alb-tg" {
  name     = "alb-tg"
  port     = var.http
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "alb-tg-attach" {
  for_each         = aws_instance.vms
  target_group_arn = aws_lb_target_group.alb-tg.arn
  port             = var.http
  target_id        = each.value.id
}