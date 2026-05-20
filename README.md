# Terraform Module Registry

Production-ready, tested Terraform modules for AWS, GCP, and Azure. Copy, reference, and go.

## Why this exists

Every team rewrites the same Terraform modules. This registry gives you battle-tested, opinionated modules with real tests so you can stop copying snippets from Stack Overflow and start shipping infrastructure.

## Modules

### AWS
| Module | Description | Status |
|--------|-------------|--------|
| [aws/vpc](./modules/aws/vpc) | VPC with public/private subnets, NAT gateway, flow logs | ✅ Tested |
| [aws/eks](./modules/aws/eks) | EKS cluster with managed node groups, IRSA, add-ons | ✅ Tested |
| [aws/iam](./modules/aws/iam) | IAM roles, policies, OIDC provider for workload identity | ✅ Tested |

### GCP
| Module | Description | Status |
|--------|-------------|--------|
| [gcp/vpc](./modules/gcp/vpc) | VPC with subnets, secondary ranges, Private Google Access | ✅ Tested |
| [gcp/gke](./modules/gcp/gke) | GKE Autopilot/Standard cluster with Workload Identity | ✅ Tested |
| [gcp/iam](./modules/gcp/iam) | Service accounts, IAM bindings, Workload Identity mapping | ✅ Tested |

### Azure
| Module | Description | Status |
|--------|-------------|--------|
| [azure/vnet](./modules/azure/vnet) | VNet with subnets, NSGs, DDoS protection, flow logs | ✅ Tested |
| [azure/aks](./modules/azure/aks) | AKS cluster with RBAC, managed identity, add-ons | ✅ Tested |
| [azure/iam](./modules/azure/iam) | Managed identities, role assignments, Azure AD app registrations | ✅ Tested |

## Quick start

```bash
git clone https://github.com/YOUR_USERNAME/terraform-module-registry.git
cd terraform-module-registry/examples/aws
# configure credentials — see docs/getting-started.md
terraform init && terraform plan
```

### Reference a module

```hcl
module "vpc" {
  source = "github.com/YOUR_USERNAME/terraform-module-registry//modules/aws/vpc?ref=v1.0.0"

  name            = "my-vpc"
  cidr            = "10.0.0.0/16"
  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  enable_nat_gateway = true
}
```

## Testing

Modules are tested with [Terratest](https://terratest.gruntwork.io/) — real infrastructure is provisioned, validated, then destroyed.

```bash
# Prerequisites: Go 1.21+, cloud credentials configured
cd tests/aws
go test -v -run TestVPC -timeout 30m
```

See [docs/testing.md](./docs/testing.md) for the full guide.

## Design principles

- **Opinionated defaults, overridable everything** — secure by default, every option is a variable
- **Minimal dependencies** — no external module deps, only official provider resources
- **Real tests** — every module has a Terratest that provisions actual cloud resources
- **Multi-cloud parity** — equivalent concepts exist across all three providers

## Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| Terraform | >= 1.5.0 | [terraform.io](https://developer.hashicorp.com/terraform/install) |
| Go | >= 1.21 | [go.dev](https://go.dev/dl/) (for tests) |
| AWS CLI | >= 2.0 | [aws.amazon.com](https://aws.amazon.com/cli/) |
| gcloud CLI | >= 450.0 | [cloud.google.com](https://cloud.google.com/sdk/docs/install) |
| Azure CLI | >= 2.50 | [learn.microsoft.com](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) |

## Contributing

PRs welcome! See [CONTRIBUTING.md](./CONTRIBUTING.md). Each new module needs `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`, a README, and a Terratest.

## License

MIT
