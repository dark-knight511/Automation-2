variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "create_new_vpc" {
  description = "Whether to create a new VPC or use an existing one"
  type        = bool
  default     = true
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
}

variable "private_zone_names" {
  description = "List of names for private hosted zones"
  type        = list(string)
}

variable "name_tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment  = "production"
    Team         = "devops"
    Owner        = "owner"
    OwnerEmail   = "owneremail"
    CreationDate = "06-05-2023"
  }
}