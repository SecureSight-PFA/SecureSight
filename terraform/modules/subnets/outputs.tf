output "public_subnet_ids" {
    description = "List of IDs for the public subnets"
    value = [for subnet in aws_subnet.public : subnet.id]
}

output "private_subnet_ids" {
    description = "List of IDs for the private subnets"
    value = [for subnet in aws_subnet.private : subnet.id]
}