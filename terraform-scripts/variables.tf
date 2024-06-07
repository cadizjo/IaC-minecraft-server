variable "instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "Minecraft Server"
}

variable "aws_region" {
  description = "The AWS region to deploy resources in"
  default     = "us-west-2"
}