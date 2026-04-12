terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "k3s" {
  name_prefix = "${var.cluster_name}-k3s-"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 8472
    to_port     = 8472
    protocol    = "udp"
    self        = true
  }

  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    self        = true
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-k3s"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "server" {
  count = var.server_count

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.server_instance_type
  key_name               = var.ssh_key_name
  vpc_security_group_ids = [aws_security_group.k3s.id]
  subnet_id              = element(var.subnet_ids, count.index)

  root_block_device {
    volume_size = 50
    volume_type = "gp3"
  }

  user_data = <<-EOF
    #!/bin/bash
    curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=${var.k3s_version} sh -s - server \\
      --cluster-init \\
      --tls-san ${self.private_ip} \\
      --disable traefik \\
      --disable servicelb \\
      --write-kubeconfig-mode 644
  EOF

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-server-${count.index}"
    Role = "server"
  })
}

resource "aws_instance" "agent" {
  count = var.agent_count

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.agent_instance_type
  key_name               = var.ssh_key_name
  vpc_security_group_ids = [aws_security_group.k3s.id]
  subnet_id              = element(var.subnet_ids, count.index)

  root_block_device {
    volume_size = 50
    volume_type = "gp3"
  }

  user_data = <<-EOF
    #!/bin/bash
    sleep 30
    curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=${var.k3s_version} K3S_URL=https://${aws_instance.server[0].private_ip}:6443 K3S_TOKEN=${var.cluster_name} sh -
  EOF

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-agent-${count.index}"
    Role = "agent"
  })

  depends_on = [aws_instance.server]
}
