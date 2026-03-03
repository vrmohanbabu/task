variable "project_name" {
    description = "project name"
    type = string
    default = "devops"
}

variable "environment_name" {
    description = "environment name"
    type = string
    default = "prod"
}

variable "ecr_repo_arn" {
    description = "ARN for ecr repo"
    type = string
}

variable "vpc_id" {
    description = "VPC id"
    type = string
}

variable "instance_type" {
    description = "Instance type"
    type = string
    default = "t3.micro"
}

variable "key_name" {
    description = "Name and path of pem file"
    type = string
    default = "personal_pem"
}

variable "subnet_id" {
    description = "Need to provide subnet id to place the ec2"
    type = string
}

