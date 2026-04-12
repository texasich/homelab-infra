terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  type    = string
  default = "us-west-2"
}

module "vpc" {
  source = "../../modules/vpc"
  name   = "homelab"
  cidr   = "10.0.0.0/16"

  tags = {
    Project = "homelab"
  }
}

module "k3s" {
  source       = "../../modules/k3s-cluster"
  cluster_name = "homelab"
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.private_subnets
  ssh_key_name = var.ssh_key_name

  server_count         = 1
  agent_count          = 2
  server_instance_type = "t3.medium"
  agent_instance_type  = "t3.medium"

  tags = {
    Project = "homelab"
  }
}

variable "ssh_key_name" {
  type        = string
  description = "SSH key pair name"
}

output "k3s_server_ips" {
  value = module.k3s.server_ips
}

output "k3s_agent_ips" {
  value = module.k3s.agent_ips
}
