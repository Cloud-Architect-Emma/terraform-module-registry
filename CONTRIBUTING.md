# Contributing

Thank you for helping improve this registry! Here's everything you need to know.

## Adding a new module

Every module must follow this structure:

```
modules/<cloud>/<name>/
├── main.tf         # Resources
├── variables.tf    # Input variables with descriptions and types
├── outputs.tf      # Output values
└── versions.tf     # Provider version constraints
```

And must be accompanied by:

```
tests/<cloud>/<name>_test.go    # Terratest test
examples/<cloud>/               # Working example using the module
```

## Code style

- Run `terraform fmt` before committing
- All variables must have a `description`
- All outputs must have a `description`
- Use `merge(var.tags, { Name = "..." })` for resource tags — never hardcode tags
- Avoid `count` when `for_each` is cleaner
- Pin provider versions with `>= X.Y`, never exact pins

## Running tests locally

```bash
# AWS
cd tests/aws
go mod download
go test -v -run TestVPC -timeout 30m

# GCP
cd tests/gcp
go test -v -run TestVPC -timeout 30m

# Azure
cd tests/azure
go test -v -run TestVNet -timeout 30m
```

Tests create real cloud resources. Estimated cost per full run: ~$2–5.
Always run `terraform destroy` if a test fails mid-run.

## PR checklist

- [ ] `terraform fmt` applied
- [ ] `terraform validate` passes
- [ ] New module has a test in `tests/`
- [ ] New module has an example in `examples/`
- [ ] Variables and outputs all have descriptions
- [ ] README updated if adding a new module

## Reporting issues

Open a GitHub issue with:
- Cloud provider and module name
- Terraform version (`terraform version`)
- The error output
- Your module call (sanitise any sensitive values)
