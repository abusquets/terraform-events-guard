variable "aws_region" {
  description = "Region AWS"
  type        = string
  default     = "eu-central-1"
}

variable "instance_name" {
  description = "Instance name"
  type        = string
  default     = "events-guard-project"
}

variable "instance_blueprint_id" {
  description = "Image Blueprint (Amazon Linux 2023)"
  type        = string
  default     = "amazon_linux_2023"
}

variable "instance_bundle_id" {
  description = "Lightsail instance type"
  type        = string
  default     = "small_2_0"
}

variable "instance_key_pair_name" {
  description = "Name of the SSH key pair to access the server"
  type        = string
}

variable "redis_password" {
  description = "The password for Redis"
  type        = string
}

variable "mongodb_password" {
  description = "The password for MongoDB"
  type        = string
}

variable "k3s_token" {
  description = "The token for K3s"
  type        = string
}

variable "my_private_key" {
  description = "The private key for the SSH key pair"
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "enable_k3s_setup" {
  description = "Controls if k3s_setup should be executed."
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "The domain name for the project"
  type        = string
}

variable "issuer_email" {
  description = "The email for the issuer"
  type        = string
}