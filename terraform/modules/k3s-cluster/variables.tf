variable "cluster_name" {
  description = "Name of the k3s cluster"
  type        = string
  default     = "homelab"
}

variable "server_count" {
  description = "Number of server (control plane) nodes"
  type        = number
  default     = 1
}

variable "agent_count" {
  description = "Number of agent (worker) nodes"
  type        = number
  default     = 2
}

variable "server_instance_type" {
  description = "EC2 instance type for server nodes"
  type        = string
  default     = "t3.medium"
}

variable "agent_instance_type" {
  description = "EC2 instance type for agent nodes"
  type        = string
  default     = "t3.medium"
}

variable "vpc_id" {
  description = "VPC ID where cluster will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for cluster nodes"
  type        = list(string)
}

variable "ssh_key_name" {
  description = "SSH key pair name for node access"
  type        = string
}

variable "k3s_version" {
  description = "k3s version to install"
  type        = string
  default     = "v1.29.2+k3s1"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
