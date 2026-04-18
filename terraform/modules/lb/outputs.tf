output "alb_controller_status" {
  description = "Status of the ALB controller helm release"
  value       = helm_release.aws_load_balancer_controller.status
}