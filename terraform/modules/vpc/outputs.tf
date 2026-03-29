output "vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.vpc.id
}

output "vpc_cidr" {
  description = "The CIDR of the created VPC"
  value       = aws_vpc.vpc.cidr_block
}
