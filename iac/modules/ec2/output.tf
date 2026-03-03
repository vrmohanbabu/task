output "instance_id" {
    value = aws_instance.demo_instance.id
}

output "security_group_id" {
    value = aws_security_group.ports_open.id
}