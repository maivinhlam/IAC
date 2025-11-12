# Compute Module - EC2 Instances
resource "aws_security_group" "web" {
  name_prefix = "${var.name}-web-"
  vpc_id      = var.vpc_id

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-web-sg"
  }
}

# Key Pair
resource "aws_key_pair" "main" {
  count = var.create_key_pair ? 1 : 0

  key_name   = "${var.name}-key"
  public_key = var.public_key

  tags = {
    Name = "${var.name}-key"
  }
}

# Launch Template
resource "aws_launch_template" "main" {
  name_prefix   = "${var.name}-"
  image_id      = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.create_key_pair ? aws_key_pair.main[0].key_name : var.key_name

  vpc_security_group_ids = [aws_security_group.web.id]

  user_data = base64encode(var.user_data)

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      {
        Name = "${var.name}-instance"
      },
      var.tags
    )
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "main" {
  count = var.enable_auto_scaling ? 1 : 0

  name                = "${var.name}-asg"
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = var.target_group_arns
  health_check_type   = var.health_check_type
  health_check_grace_period = 300

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  tag {
    key                 = "Name"
    value               = "${var.name}-asg"
    propagate_at_launch = false
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Standalone EC2 Instance (alternative to ASG)
resource "aws_instance" "main" {
  count = var.enable_auto_scaling ? 0 : var.instance_count

  ami                    = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name               = var.create_key_pair ? aws_key_pair.main[0].key_name : var.key_name
  vpc_security_group_ids = [aws_security_group.web.id]
  subnet_id              = var.subnet_ids[count.index % length(var.subnet_ids)]

  user_data = var.user_data

  root_block_device {
    volume_type = "gp3"
    volume_size = var.root_volume_size
    encrypted   = true
  }

  tags = merge(
    {
      Name = "${var.name}-instance-${count.index + 1}"
    },
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Data source for Amazon Linux AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
