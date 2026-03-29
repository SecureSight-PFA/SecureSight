output "eip_allocation_id" {
  description = "The id of the nat"
  value       = aws_eip.nat_eip.id 
}