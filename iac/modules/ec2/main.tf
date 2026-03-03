data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2-server-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "other_access_policy" {
  name        = "access_for_ec2"
  description = "Allowing access for ec2"

  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Statement1",
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "arn:aws:s3:::test-buckets"
    },
    {
      "Sid": "Statement2",
      "Effect": "Allow",
      "Action": "ecr:*",
      "Resource": var.ecr_repo_arn
    }
  ]
 })
}

resource "aws_iam_role_policy_attachment" "other_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.other_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "SSM_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-server-role"
  role = aws_iam_role.ec2_role.name
}

resource "aws_instance" "demo_instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name = var.key_name
  subnet_id = var.subnet_id
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.id

  vpc_security_group_ids = [
    aws_security_group.ports_open.id
  ]

  root_block_device {
        delete_on_termination = true
        encrypted             = false
        tags                  = {}
        tags_all              = {}
        volume_size           = 10
        volume_type           = "gp2"
    }

  tags = {
    Name = "${var.project_name}-${var.environment_name}-demo-instance"
  }
}

resource "aws_security_group" "ports_open" {
  name        = "${var.project_name}-${var.environment_name}-open-sg"
  description = "Allow ports"
  vpc_id      = var.vpc_id

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment_name}-open-sg"
  }
}



