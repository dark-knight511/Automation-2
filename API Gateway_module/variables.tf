variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the API Gateway will be accessible"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs in the VPC"
  type        = list(string)
}

variable "api_name" {
  description = "Name of the API Gateway"
  type        = string
}

variable "stage_name" {
  description = "Stage name for the API Gateway deployment"
  type        = string
}

variable "resource_name" {
  description = "Name of the API resource"
  type        = string
}

variable "method" {
  description = "HTTP method for the API resource"
  type        = string
}

variable "lambda_function_arn" {
  description = "ARN of the Lambda function to integrate with API Gateway"
  type        = string
}
