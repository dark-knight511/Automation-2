provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  create_vpc = var.create_new_vpc
  az_count   = length(data.aws_availability_zones.available.names)
}

resource "aws_vpc" "main" {
  count                = local.create_vpc ? 1 : 0
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.name_tags, {
    Name = var.vpc_name
  })
}

resource "aws_internet_gateway" "main" {
  count  = local.create_vpc ? 1 : 0
  vpc_id = aws_vpc.main[0].id

  tags = merge(var.name_tags, {
    Name = "${var.vpc_name}-igw"
  })
}

resource "aws_subnet" "public" {
  count                   = local.create_vpc ? length(var.public_subnet_cidrs) : 0
  vpc_id                  = aws_vpc.main[0].id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index % local.az_count]
  map_public_ip_on_launch = true

  tags = merge(var.name_tags, {
    Name = "${var.vpc_name}-public-subnet-${count.index + 1}"
  })
}

resource "aws_subnet" "private" {
  count             = local.create_vpc ? length(var.private_subnet_cidrs) : 0
  vpc_id            = aws_vpc.main[0].id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index % local.az_count]

  tags = merge(var.name_tags, {
    Name = "${var.vpc_name}-private-subnet-${count.index + 1}"
  })
}

resource "aws_eip" "nat" {
  count = local.create_vpc ? 1 : 0
  domain = "vpc"

  tags = merge(var.name_tags, {
    Name = "${var.vpc_name}-nat-eip"
  })
}

resource "aws_nat_gateway" "main" {
  count         = local.create_vpc ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(var.name_tags, {
    Name = "${var.vpc_name}-nat-gateway"
  })
}

resource "aws_route_table" "public" {
  count  = local.create_vpc ? 1 : 0
  vpc_id = aws_vpc.main[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main[0].id
  }

  tags = merge(var.name_tags, {
    Name = "${var.vpc_name}-public-route-table"
  })
}

resource "aws_route_table" "private" {
  count  = local.create_vpc ? 1 : 0
  vpc_id = aws_vpc.main[0].id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[0].id
  }

  tags = merge(var.name_tags, {
    Name = "${var.vpc_name}-private-route-table"
  })
}

resource "aws_route_table_association" "public" {
  count          = local.create_vpc ? length(var.public_subnet_cidrs) : 0
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table_association" "private" {
  count          = local.create_vpc ? length(var.private_subnet_cidrs) : 0
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[0].id
}

resource "aws_route53_zone" "private" {
  count = local.create_vpc ? length(var.private_zone_names) : 0
  name  = var.private_zone_names[count.index]

  vpc {
    vpc_id = aws_vpc.main[0].id
  }

  tags = var.name_tags
}

output "vpc_id" {
  value = local.create_vpc ? aws_vpc.main[0].id : "No VPC created"
}

output "nat_gateway_public_ip" {
  value = local.create_vpc ? aws_eip.nat[0].public_ip : "No NAT Gateway created"
}

output "public_subnet_ids" {
  value = local.create_vpc ? aws_subnet.public[*].id : []
}

output "private_subnet_ids" {
  value = local.create_vpc ? aws_subnet.private[*].id : []
}