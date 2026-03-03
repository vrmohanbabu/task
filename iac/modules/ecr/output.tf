output "ecr_repo_id" {
    value = aws_ecr_repository.repo_name.name
}

output "ecr_repo_arn" {
    value = aws_ecr_repository.repo_name.arn
} 