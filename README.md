# SecureSight – Cloud-Native Microservices SRE Platform

This repository contains a cloud-native microservices application based on the **Sock-Shop demo**, enhanced with Kubernetes best practices, security hardening, and infrastructure automation using Terraform.

The project is actively in progress as part of an SRE + Security engineering learning path.

---

## Project Context

We started from a standard microservices application and progressively improved it by applying:

- Kubernetes production best practices and security hardening
- Infrastructure as Code with modular Terraform on AWS
- Environment separation with Kustomize overlays (Minikube → EKS)
- Stateful database migration to PersistentVolumeClaims on EBS

---

## Stack

**Kubernetes** · **AWS EKS** · **Terraform** · **Linkerd** · **Kustomize** · **Helm** ·  **Prometheus** · **Grafana** 

---

## Kubernetes — What Was Applied

### Migration from OpenShift
The original application used OpenShift-specific resources that don't exist in vanilla Kubernetes. We replaced Routes with Ingress, removed SecurityContextConstraints, swapped Red Hat images for standard ones, and adapted storage configuration.

### Resource Management
Every container across all 14 services has explicit CPU and memory requests and limits — a prerequisite for autoscaling and intelligent scheduler placement. Java services (Spring Boot) have explicit JVM heap flags aligned with their container limits.

### Health Probes
All services have liveness and readiness probes. Java services additionally have startup probes that give the JVM enough time to initialise before liveness checks begin, preventing premature restarts.

### Autoscaling
HPA v2 is configured for all stateless services with CPU-based scaling. The front-end has custom scale-up and scale-down behavior to handle traffic spikes without thrashing. Databases are intentionally excluded — stateful workloads require different scaling strategies.

### Network Policies
A default-deny model is applied to the entire `sock-shop` namespace using Calico CNI. Every allowed connection is explicitly defined: which service can reach which other service, on which port. DNS egress is separately whitelisted. This reduces the blast radius of any compromised service to zero lateral movement.

### StatefulSets for Databases
All four databases (MongoDB × 3, MariaDB × 1) were migrated from Deployments to StatefulSets with `volumeClaimTemplates`. Each pod gets its own PersistentVolumeClaim, stable DNS identity, and survives restarts with data intact. On Minikube this uses the standard StorageClass; on EKS it is patched to encrypted EBS gp3 volumes.

---

## Environment Management — Kustomize

A base layer holds all shared manifests. Environment-specific differences are applied as patches via overlays — no duplication of files.

**Minikube overlay** — nginx Ingress with local hostname, standard StorageClass, local secrets.

**AWS EKS overlay** — ALB Ingress (internet-facing, direct pod IP routing), EBS gp3 StorageClass, NetworkPolicy patch for ALB traffic, production secrets.

```bash
kubectl apply -k manifests/overlays/minikube/   # local
kubectl apply -k manifests/overlays/aws-eks/     # AWS
```

---

## AWS Infrastructure — Terraform

Infrastructure is fully modular. Each module has a single responsibility and exposes typed outputs consumed by dependent modules. No circular dependencies — the IAM module is split into pre-EKS (cluster and node roles) and post-EKS (IRSA role for the ALB controller, which requires the EKS OIDC provider to exist first).

### Modules

| Module | What it provisions |
|---|---|
| `vpc` | VPC, Internet Gateway |
| `subnets` | Public subnets (ALB), private subnets (EKS nodes), NAT Gateways |
| `routes` | Route tables — public via IGW, private via NAT per AZ |
| `nsg` | Security groups for cluster, nodes, and ALB |
| `iam/pre-eks` | EKS cluster role, node group role |
| `eks` | EKS cluster, managed node group, OIDC provider, addons (CoreDNS, VPC CNI, EBS CSI) |
| `iam/post-eks` | IRSA role for ALB controller — scoped to a single Kubernetes ServiceAccount |
| `lb` | AWS Load Balancer Controller via Helm |

### State and Environments

Remote state is stored in S3 with versioning and state locking. Three environments (dev, test, prod) use identical modules — only `terraform.tfvars` differs. No code duplication across environments.

### Security Model

IRSA (IAM Roles for Service Accounts) gives the ALB controller pod time-limited AWS credentials without storing any access keys. The IAM role trust policy is scoped to exactly one Kubernetes ServiceAccount via OIDC subject condition — no other pod on the cluster can assume it.

---


## Planned

- Service mesh with automatic mTLS and traffic management
- Observability stack (Prometheus + Grafana)
- Load testing (Grafana K6)
- RBAC with IAM-to-Kubernetes user mapping
- Runtime security monitoring (eBPF)

---

## Note

This repository is actively evolving as part of a final year engineering project (PFA). It reflects an incremental, real-world approach to applying SRE and security principles to a production-like microservices environment.
