region             = "us-east-1"
vpc_id             = "vpc-xxxxxxxx"
subnet_ids         = ["subnet-xxxxxxxx", "subnet-yyyyyyyy"]
api_name           = "MyPrivateAPI"
stage_name         = "dev"
resource_name      = "myresource"
method             = "GET"
lambda_function_arn = "arn:aws:lambda:us-east-1:123456789012:function:my-function"
