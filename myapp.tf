resource "aws_security_group" "allow_ssh" {
  name        = "allow_all"
  description = "Allow inbound SSH traffic from my IP"
  vpc_id      = "${data.aws_vpc.selected.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "Allow SSH"
  }
}

resource "aws_security_group" "web_server" {
  name        = "web server"
  description = "Allow HTTP and HTTPS traffic in, browser access out."
  vpc_id      = "${data.aws_vpc.selected.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 1024
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "web01" {
  ami                         = "ami-f0f8d695"
  instance_type               = "t2.micro"
  subnet_id                   = "subnet-af85a4e2"
  vpc_security_group_ids      = ["${aws_security_group.web_server.id}", "${aws_security_group.allow_ssh.id}"]
  key_name                    = "personalkeypair"
  tenancy                     = "default"
  ebs_optimized               = false
  associate_public_ip_address = "true"

  root_block_device {
    volume_size           = 10
    volume_type           = "gp2"
    delete_on_termination = "true"
  }

  tags {
    Name = "web01"
  }
}

resource "aws_alb_target_group" "test" {
  name     = "tf-example-targetgrp"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${data.aws_vpc.selected.id}"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    path                = "/"
    port                = 80
    protocol            = "HTTP"
    interval            = 30
  }

  target_type = "instance"
}

resource "aws_lb_target_group_attachment" "test" {
  target_group_arn = "${aws_alb_target_group.test.arn}"
  target_id        = "${aws_instance.web01.id}"
  port             = 80
}

resource "aws_alb" "test" {
  name            = "tf-example-alb-ecs"
  subnets         = ["subnet-af85a4e2", "subnet-7c628406"]
  security_groups = ["sg-de37aab5"]
  internal        = false
}

resource "aws_alb_listener" "front_end" {
  load_balancer_arn = "${aws_alb.test.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.test.id}"
    type             = "forward"
  }
}
