# Terraform AWS Assignment (Simple, DRY, Root-Based)

This repository contains a simple, root-based Terraform solution for the following assignment:

## Assignment Requirements

**Task 1**
- Automate the creation of an EC2 instance under a load balancer.
- Create a role with S3 access.
- Launch an EC2 instance with a role inside the private subnet of a VPC, and install Apache through bootstrapping.
- Create a load balancer in the public subnet.
- Add the EC2 instance under the load balancer.

**Task 2**
- Create an auto scaling group with minimum size of 1 and maximum size of 3 with a load balancer.
- Add the created instances under the auto scaling group.
- Write a lifecycle policy:
  - Scale in: CPU utilization > 80%
  - Scale out: CPU utilization < 60%

---

## Project Structure

```
├── data.tf         # Data sources (AMI lookup)
├── network.tf      # VPC, subnets, NAT, routes (shared)
├── security.tf     # Security groups (shared)
├── iam.tf          # IAM role/profile (shared)
├── task1.tf        # Task 1: EC2 under ALB
├── task2.tf        # Task 2: Auto Scaling Group under ALB
├── variables.tf    # All variables for both tasks
├── outputs.tf      # Outputs for both tasks
├── provider.tf     # AWS provider configuration
└── README.md       # This file
```

---

## How to Use

### 1. Prerequisites
- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- AWS credentials configured (via environment variables or `~/.aws/credentials`)
- An S3 bucket created in your AWS account (for the EC2 S3 access role)

### 2. Configure Variables
Edit `variables.tf` or create a `terraform.tfvars` file in the root. Example:

```
aws_region         = "us-east-1"
vpc_cidr           = "10.0.0.0/16"
public_subnet_cidr = "10.0.1.0/24"
private_subnet_cidr= "10.0.2.0/24"
instance_type      = "t2.micro"
s3_bucket_name     = "your-existing-s3-bucket"
# For Task 2 only:
asg_min_size        = 1
asg_max_size        = 3
asg_desired_capacity= 1
scale_in_threshold  = 80
scale_out_threshold = 60
```

**Note:** The AMI ID is automatically retrieved using a data source, so you don't need to specify it manually.

### 3. Deploy Both Tasks
- All files are included by default. Both Task 1 and Task 2 will be deployed together with a single command:
  ```bash
  terraform init
  terraform apply
  ```
- This will create:
  - Shared: VPC, subnets, NAT, route tables, security groups, IAM role/profile
  - Task 1: EC2 instance in private subnet (with Apache), ALB, target group, listener
  - Task 2: Launch Template, Auto Scaling Group (min=1, max=3), ALB, target group, listener, CloudWatch alarms for scaling

### 4. Destroy Resources
To clean up:
```bash
terraform destroy
```

---

## File Descriptions

- **data.tf**: Data sources (automatically gets latest Amazon Linux 2 AMI)
- **network.tf**: VPC, subnets, NAT, route tables (shared)
- **security.tf**: Security groups for ALB and EC2/ASG (shared)
- **iam.tf**: IAM role, S3 policy, instance profile (shared)
- **task1.tf**: Task 1 resources (EC2, ALB, etc)
- **task2.tf**: Task 2 resources (ASG, Launch Template, ALB, scaling, etc)
- **variables.tf**: All variables for both tasks. Edit as needed.
- **outputs.tf**: Outputs for both tasks (VPC, subnets, ALB DNS, ASG name)
- **provider.tf**: AWS provider and Terraform version.

---

## Notes
- Both Task 1 and Task 2 can be deployed at the same time. All resources use unique names/prefixes.
- The S3 bucket must already exist in your AWS account.
- The AMI is automatically retrieved using a data source (no manual AMI ID needed).
- All resources are created in the same VPC for simplicity.

---

## Outputs
- `vpc_id`: The VPC ID
- `public_subnet_id`: The public subnet ID
- `private_subnet_id`: The private subnet ID
- `task1_alb_dns_name`: The DNS name of the Task 1 Application Load Balancer
- `task2_alb_dns_name`: The DNS name of the Task 2 Application Load Balancer
- `task2_asg_name`: The name of the Task 2 Auto Scaling Group

---

## License
MIT 