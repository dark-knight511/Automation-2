provider "aws" {
  region = var.region
}

# Create the API Gateway REST API
resource "aws_api_gateway_rest_api" "api" {
  name        = var.api_name
}

# Create a resource
resource "aws_api_gateway_resource" "resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = var.resource_name
}

# Create a method
resource "aws_api_gateway_method" "method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = var.method
  authorization = "NONE"
}

# Integrate the method with a Lambda function
resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_function_arn
}

# Deploy the API
resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [aws_api_gateway_integration.integration]

  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = var.stage_name
}

# Create a VPC link
resource "aws_api_gateway_vpc_link" "vpc_link" {
  name        = "${var.api_name}-vpc-link"
  target_arns = [var.subnet_ids[0]]
}

# Create a private endpoint
resource "aws_api_gateway_method_settings" "private_settings" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_deployment.deployment.stage_name
  method_path = "*/*"
  
  settings {
    metrics_enabled    = true
    logging_level      = "INFO"
    data_trace_enabled = true
  }
}

# Create a VPC endpoint for API Gateway
resource "aws_vpc_endpoint" "api_gateway_endpoint" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.execute-api"
  vpc_endpoint_type = "Interface"
  subnet_ids        = var.subnet_ids

  private_dns_enabled = true
  security_group_ids  = [aws_security_group.api_gw_sg.id]
}

# Security group for the API Gateway VPC endpoint
resource "aws_security_group" "api_gw_sg" {
  name        = "${var.api_name}-api-gw-sg"
  description = "Security group for API Gateway VPC endpoint"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
