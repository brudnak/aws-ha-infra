resource "random_pet" "random_pet" {

  keepers = {
    aws_prefix = "${var.aws_prefix}"
  }

  length    = 2
  separator = "-"
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_instance" "aws_instance" {
  count                  = 3
  ami                    = var.aws_ami
  instance_type          = "t3a.medium"
  subnet_id              = var.aws_subnet_id
  vpc_security_group_ids = [var.aws_security_group_id]
  key_name               = var.aws_pem_key_name

  root_block_device {
    volume_size = 150
  }

  tags = {
    Name = "${random_pet.random_pet.keepers.aws_prefix}-${random_pet.random_pet.id}${formatdate("MMMDDYY", timestamp())}"
  }
}


resource "aws_lb_target_group" "aws_lb_target_group_80" {
  name        = "${var.aws_prefix}-80-${random_pet.random_pet.id}${formatdate("MMMDDYY", timestamp())}"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.aws_vpc
  health_check {
    protocol          = "HTTP"
    port              = "traffic-port"
    healthy_threshold = 3
    interval          = 10
  }
}

resource "aws_lb_target_group" "aws_lb_target_group_443" {
  name        = "${var.aws_prefix}-443-${random_pet.random_pet.id}${formatdate("MMMDDYY", timestamp())}"
  port        = 443
  protocol    = "HTTPS"
  target_type = "instance"
  vpc_id      = var.aws_vpc
  health_check {
    protocol          = "HTTPS"
    port              = 443
    healthy_threshold = 3
    interval          = 10
  }
}

# attach instances to the target group 80
resource "aws_lb_target_group_attachment" "attach_tg_80" {
  count            = length(aws_instance.aws_instance)
  target_group_arn = aws_lb_target_group.aws_lb_target_group_80.arn
  target_id        = aws_instance.aws_instance[count.index].id
  port             = 80
}

# attach instances to the target group 443
resource "aws_lb_target_group_attachment" "attach_tg_443" {
  count            = length(aws_instance.aws_instance)
  target_group_arn = aws_lb_target_group.aws_lb_target_group_443.arn
  target_id        = aws_instance.aws_instance[count.index].id
  port             = 443
}


# create a load balancer
resource "aws_lb" "aws_lb" {
  load_balancer_type = "application"
  name               = "${var.aws_prefix}-nlb-${random_pet.random_pet.id}${formatdate("MMMDDYY", timestamp())}"
  internal           = false
  subnets            = [var.aws_subnet_a, var.aws_subnet_b, var.aws_subnet_c]
}

# add a listener for port 80
resource "aws_lb_listener" "aws_lb_listener_80" {
  load_balancer_arn = aws_lb.aws_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.aws_lb_target_group_80.arn
  }
}

resource "aws_route53_record" "aws_route53_record" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "${var.aws_prefix}-${random_pet.random_pet.id}"
  type    = "CNAME"
  ttl     = "60"
  records = [aws_lb.aws_lb.dns_name]
}

data "aws_route53_zone" "zone" {
  name = var.aws_route53_fqdn
}

resource "aws_acm_certificate" "cert" {
  domain_name       = "${var.aws_prefix}-${random_pet.random_pet.id}.${var.aws_route53_fqdn}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  count = 1

  name    = element(aws_acm_certificate.cert.domain_validation_options.*.resource_record_name, count.index)
  type    = element(aws_acm_certificate.cert.domain_validation_options.*.resource_record_type, count.index)
  zone_id = data.aws_route53_zone.zone.zone_id
  records = [element(aws_acm_certificate.cert.domain_validation_options.*.resource_record_value, count.index)]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = aws_route53_record.cert_validation[*].fqdn
}

# update listener to use new certificate
resource "aws_lb_listener" "aws_lb_listener_443" {
  load_balancer_arn = aws_lb.aws_lb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate_validation.cert.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.aws_lb_target_group_443.arn
  }
}
