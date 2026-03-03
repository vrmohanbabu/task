resource "aws_ecr_repository" "repo_name" {
  name                 = var.ecr_repo_name
  image_tag_mutability = "MUTABLE"

}