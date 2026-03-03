module "vpc" {
  source = "../../modules/vpc"
  vpc_cidr = "10.0.0.0/16"
  public_subnet_az1_cidr = "10.0.0.0/24"
  public_subnet_az2_cidr = "10.0.1.0/24"
  private_subnet_az1_cidr = "10.0.16.0/20"
  private_subnet_az2_cidr = "10.0.32.0/20"
  project_name = "devops"
  environment_name = "prod"
}

module "ec2" {
  source = "../../modules/ec2"
  vpc_id = module.vpc.vpi_id
  subnet_id = module.vpc.pri_az1_id
  instance_type = "t3.micro"
  key_name = "personal_pem"
  ecr_repo_arn = module.ecr.ecr_repo_arn
}

module "ecr" {
  source = "../../modules/ecr"
  ecr_repo_name = "task/nodejs-appw"
}