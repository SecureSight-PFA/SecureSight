variable "environment" {
  description = "Environment name"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the OIDC provider (from eks module)"
  type        = string
}

variable "oidc_issuer_url" {
  description = "OIDC issuer URL from EKS cluster (with https://)"
  type        = string
}
