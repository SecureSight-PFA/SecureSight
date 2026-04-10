# SecureSight – Kubernetes Security & SRE Project

This repository contains a cloud-native microservices application based on the **Sock-Shop demo**, enhanced with Kubernetes best practices, security hardening, and infrastructure automation using Terraform.

The project is actively in progress as part of an SRE + Security engineering learning path.

---

## Project Context

We started from a standard microservices application and progressively improved it by applying:

- Kubernetes best practices
- Security hardening principles
- Observability and reliability improvements
- Infrastructure as Code (Terraform)
- Local-first development with Minikube, with future AWS EKS deployment

---

## Local Development (Minikube)

We initially deployed and tested everything locally using Minikube:

- `kubectl` + `minikube` setup
- Applied Sock-Shop manifests
- Replaced OpenShift-specific resources with Kubernetes-native equivalents
- Used Kustomize overlays for environment separation
- Verified full application flow locally before cloud migration

---

## Kubernetes Improvements Applied

### Resource Management
- Added CPU and memory requests/limits
---

### Health Probes
Implemented:
- Liveness probes
- Readiness probes
- TCP probes for databases

Added **startup probes for Java services**:
- carts
- orders
- shipping
- queue-master

---

### Autoscaling
- Configured Horizontal Pod Autoscaler (HPA)
- CPU-based scaling for workloads
- Frontend prioritized for scaling behavior testing

---

### Networking & Security Policies
Implemented a **default-deny network security model**:

- DNS explicitly allowed (required for service discovery)
- Ingress controller → frontend allowed
- Frontend → backend services restricted and explicitly defined
- Each service isolated to its own database
- RabbitMQ access restricted to required services only

---

## Infrastructure (Terraform)

Infrastructure is fully defined using a **modular Terraform architecture**:

### Modules
- VPC
- Subnets
- Routing
- Security Groups
- EKS
- IAM
- Load Balancer (in progress)

### Environments
- dev
- test
- prod

Each environment differs only via `terraform.tfvars` (no code duplication).

---

### Key Infrastructure Decisions

- State stored in **S3 backend**
- State locking enabled
- Region: `us-east-2`
- Designed for cost efficiency and least privilege access
- Private + public subnet architecture for EKS workloads

---

## IAM & Security Model

IAM is split into three main components:

- **Cluster Role** → EKS control plane permissions
- **Node Role** → EC2 worker node permissions
- **IRSA (Post-EKS IAM)** → service-level AWS access using Kubernetes ServiceAccounts

IRSA is used to follow least privilege principles by giving AWS permissions only to specific pods when needed.

---

## Storage (In Progress)

- Currently using Minikube default storage class
- Planning migration to:
  - StatefulSets
  - PVCs
  - AWS EBS (via CSI driver on EKS)

Goal: persistent, production-grade database storage

---

## Next Steps

- Add AWS Load Balancer Controller (IRSA-based)
- Migrate storage to EBS + StatefulSets
- Introduce RBAC + ServiceAccounts
- Add observability stack (Prometheus/Grafana)
- Add service mesh (Istio)
- Chaos testing + security testing

---

## Goal of the Project

To simulate a real-world **SRE + Security engineering environment** for a microservices system running on Kubernetes, covering:

- Deployment
- Scaling
- Security
- Infrastructure
- Observability
- Resilience

---

##  Note

This repository is actively evolving and reflects a learning-driven, incremental improvement approach.