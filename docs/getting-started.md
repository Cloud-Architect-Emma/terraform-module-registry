# Getting Started

## Install prerequisites

### Terraform

```bash
# macOS
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Ubuntu / Debian
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# Windows (winget)
winget install Hashicorp.Terraform

# Verify
terraform version
```

### Cloud CLIs

```bash
# AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip && sudo ./aws/install
aws configure

# GCP SDK
curl https://sdk.cloud.google.com | bash
gcloud init
gcloud auth application-default login

# Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az login
```

### Go (for tests)

```bash
# macOS
brew install go

# Ubuntu
sudo apt install golang-go

# Verify
go version  # needs >= 1.21
```

## Using a module

### Option A — Reference via GitHub (recommended)

```hcl
module "vpc" {
  source = "github.com/YOUR_USERNAME/terraform-module-registry//modules/aws/vpc?ref=main"

  name = "my-vpc"
  cidr = "10.0.0.0/16"
  azs  = ["us-east-1a", "us-east-1b", "us-east-1c"]

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}
```

### Option B — Clone and use locally

```bash
git clone https://github.com/YOUR_USERNAME/terraform-module-registry
cd terraform-module-registry/examples/aws

# Edit terraform.tfvars if needed
terraform init
terraform plan
terraform apply
```

## Environment setup for secrets

Never hardcode credentials. Use environment variables:

```bash
# AWS
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_DEFAULT_REGION="us-east-1"

# GCP
export GOOGLE_CREDENTIALS="$(cat path/to/service-account-key.json)"

# Azure
export ARM_CLIENT_ID="..."
export ARM_CLIENT_SECRET="..."
export ARM_SUBSCRIPTION_ID="..."
export ARM_TENANT_ID="..."
```

## Next steps

- Browse the [`examples/`](../examples) directory for complete working setups
- Read the module-level README in each `modules/<cloud>/<name>/` folder for inputs and outputs
- Run the tests — see [CONTRIBUTING.md](../CONTRIBUTING.md)
