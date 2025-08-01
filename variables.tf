variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR for VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR for public subnet"
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR for private subnet"
  default     = "10.0.2.0/24"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for EC2/ASG access"
  default     = "my-assignment-bucket"
}

# Task 2 (ASG) only
variable "asg_min_size" {
  description = "Minimum size of Auto Scaling Group"
  default     = 1
}
variable "asg_max_size" {
  description = "Maximum size of Auto Scaling Group"
  default     = 3
}
variable "asg_desired_capacity" {
  description = "Desired capacity of Auto Scaling Group"
  default     = 1
}
variable "scale_in_threshold" {
  description = "CPU utilization threshold for scaling IN (remove instances)"
  default     = 80
}
variable "scale_out_threshold" {
  description = "CPU utilization threshold for scaling OUT (add instances)"
  default     = 60
} 