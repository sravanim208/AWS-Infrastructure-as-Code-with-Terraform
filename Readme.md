# AWS Infrastructure as Code with Terraform

This repository contains a Terraform configuration to provision an AWS infrastructure that includes:
- A Virtual Private Cloud (VPC) with two public and two private subnets
- Route tables for each subnet
- A security group allowing HTTP (port 80) and HTTPS (port 443) traffic from the internet
- An Elastic Load Balancer (ELB) listening on ports 80 and 443
- A public Route 53 hosted zone with a CNAME record for the ELB

## Prerequisites

Before we begin, ensure you have the following installed:

- [Terraform](https://www.terraform.io/downloads.html) (version 1.0 or later)
- An AWS account with appropriate permissions to create VPCs, subnets, security groups, ELBs, and Route 53 resources
- AWS CLI configured with your credentials (`aws configure`)

## Getting Started

1. **Clone the Repository**

   Clone this repository to your local machine:

   ```bash
   git clone [https://github.com/sravanim208/AWS-Infrastructure-as-Code-with-Terraform.git]
   cd aws-terraform-infrastructure


Initialize Terraform Run the following command to initialize the Terraform configuration:
terraform init


Plan the Infrastructure Generate an execution plan to see what resources will be created:
terraform plan


Apply the Configuration Apply the Terraform configuration to create the resources in AWS:
terraform apply

Type yes when prompted to confirm the changes.
Verify the Resources After the apply command completes, you can verify the resources in the AWS Management Console.
Cleanup

To remove all the resources created by this Terraform configuration, run:
terraform destroy

Type yes when prompted to confirm the destruction of the resources.
