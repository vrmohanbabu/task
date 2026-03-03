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

variable "vpc_cidr" {
    description = "cidr for vpc"
    type = string
    default = "10.0.0.0/16"
}

variable "public_subnet_az1_cidr" {
    description = "cidr for pub 1"
    type = string
    default = "10.0.0.0/24"
}

variable "public_subnet_az2_cidr" {
    description = "cidr for pub 2"
    type = string
    default = "10.0.1.0/24"
}

variable "private_subnet_az1_cidr" {
    description = "cidr for pri 1"
    type = string
    default = "10.0.16.0/20"
}

variable "private_subnet_az2_cidr" {
    description = "cidr for pri 2"
    type = string
    default = "10.0.32.0/20"
}
