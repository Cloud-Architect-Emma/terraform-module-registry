# Real-World Gotchas

These are the actual problems I hit while building and testing these modules.
Documenting them here so you don't lose the same hours I did.

---

## AWS

### VPC

**NAT gateway in the wrong subnet**
First version of the module put the NAT gateway in a private subnet.
It silently failed, the gateway provisioned fine but no traffic routed through it.
NAT gateways must live in a **public** subnet. Obvious in hindsight.
The fix: `subnet_id = aws_subnet.public[count.index].id` not private.

**Route table associations silently doing nothing**
If your private subnet has no route to the NAT gateway and you `curl` from an EC2
instance, you get a timeout, not a routing error. Took 45 minutes to realise
the route table association had the wrong subnet ID because of a `count.index`
off-by-one when mixing public and private subnet lists.
The fix: separate `count` indexes for public and private subnets, never share them.

**`enable_dns_hostnames` and `enable_dns_support` both required for EKS**
EKS will provision but node groups will fail to join the cluster if either is false.
The error message says nothing about DNS, it just says nodes are not joining.
Both default to `true` in this module for this reason.

**Elastic IP limit**
AWS default EIP limit per region is 5. A VPC with 3 AZs and one NAT gateway
per AZ uses 3 EIPs. If you already have EIPs in the account you will hit this
limit and get a cryptic `AddressLimitExceeded` error.
Solution: request a limit increase before running in a shared account,
or use `single_nat_gateway = true` in dev.

---

### EKS

**OIDC thumbprint changes without warning**
The TLS thumbprint for the EKS OIDC provider is fetched at apply time using
the `tls` provider. If AWS rotates the certificate (they do), a subsequent
`terraform apply` will show a diff on the thumbprint and try to recreate
the OIDC provider. This will break all IRSA roles until they are re-attached.
Watch for this in production, add the OIDC provider to your change notification alerts.

**Node groups failing to join with no useful error**
Three separate causes I hit:
1. Nodes in public subnets with no route to the EKS endpoint
2. Missing `AmazonEKS_CNI_Policy` on the node IAM role
3. Security group blocking port 443 between nodes and control plane
The module attaches all three required policies by default and puts nodes
in private subnets. If you override `subnet_ids` make sure they are private.

**`kubectl` commands failing after apply**
The cluster endpoint and CA certificate are marked `sensitive` in outputs.
If you pipe them into a kubeconfig script using `terraform output` you need
`terraform output -raw cluster_endpoint` not `terraform output cluster_endpoint`
or you get JSON-wrapped values that break the kubeconfig.

**Spot node groups and `desired_size`**
Setting `desired_size = 0` on a Spot node group causes the AWS API to return
a validation error during creation. Set `desired_size = 1` for the initial
apply, then scale down if needed. This is an AWS API quirk, not Terraform.

**Control plane log delivery delay**
Enabling `cluster_log_types` does not mean logs appear in CloudWatch immediately.
There is a 5–10 minute delay after the cluster is created before log delivery starts.
Do not assume logging is broken if you do not see logs right after apply.

---

### IAM

**IRSA condition keys are case-sensitive**
The OIDC condition key `sub` must match exactly:
`system:serviceaccount:NAMESPACE:SERVICE_ACCOUNT_NAME`
A single character wrong and the assume-role silently fails with
`AccessDenied` and no useful message. Always test IRSA bindings with
`aws sts assume-role-with-web-identity` before deploying the workload.

**`aud` condition required since 2023**
AWS now requires the `aud` condition set to `sts.amazonaws.com` on IRSA
trust policies. Older examples online omit it and they no longer work.
This module includes it by default.

**Max session duration ignored by some services**
Setting `max_session_duration = 43200` (12 hours) has no effect when the
role is assumed by EKS service accounts — the token lifetime is controlled
by the pod's projected service account token, not the IAM role.
Default token lifetime is 1 hour. Configure it in the `ServiceAccount`
annotation if you need longer.

---

## GCP

### VPC

**Secondary IP ranges must be unique across the project**
GKE pods and services secondary ranges must not overlap with any other
subnet in the project. If you have multiple clusters, plan your secondary
ranges carefully from the start. Changing them later requires destroying
and recreating the subnet, which means destroying the cluster.

**Cloud NAT takes 2–3 minutes to become active**
After `terraform apply` completes, Cloud NAT is provisioned but not
immediately routing traffic. Pods on private nodes will fail to reach
the internet for 2–3 minutes. This is a GCP propagation delay, not a config error.

**Private Google Access is not the same as Cloud NAT**
`private_ip_google_access = true` allows VMs without external IPs to reach
Google APIs (Cloud Storage, Container Registry, etc.) without a NAT gateway.
It does NOT allow general internet access. You need Cloud NAT for that.
Both are enabled in this module by default for private node GKE clusters.

**Firewall rules are at the network level, not subnet level**
Unlike AWS security groups, GCP firewall rules apply to the whole VPC network
with target filtering by tags or service accounts. If you are used to AWS,
this catches you out — adding a rule to a specific subnet does not exist in GCP.

---

### GKE

**`remove_default_node_pool = true` requires `initial_node_count = 1`**
GKE requires at least one node to create a cluster, even if you immediately
delete the default node pool. Setting `initial_node_count = 0` returns
a validation error. This is a GCP API requirement, not a Terraform bug.

**Workload Identity takes up to 5 minutes to propagate**
After binding a Kubernetes service account to a GCP service account via
Workload Identity, there is a propagation delay before the binding takes effect.
If your pod starts immediately after `terraform apply` it may get
`permission denied` errors that resolve on their own within 5 minutes.

**Node pool recreation on `machine_type` change**
Changing `machine_type` on an existing node pool forces recreation.
GKE does not support in-place machine type changes. Plan for this
during maintenance windows, use `lifecycle { create_before_destroy = true }`
if you need zero-downtime replacement.

**Master authorised networks and private endpoint**
If you enable `enable_private_endpoint = true` you cannot reach the master
from outside the VPC, including from your local machine or GitHub Actions.
Only enable this if you have a VPN or bastion host in the VPC.
The default in this module is `false` for this reason.

**`gke_metadata` mode required for Workload Identity**
Node pools must have `workload_metadata_config { mode = "GKE_METADATA" }`.
Without this, Workload Identity does not work even if enabled at the cluster level.
This is easy to miss and the error message (`permission denied on GCS bucket`)
does not mention metadata config.

---

### IAM

**Service account email format**
GCP service account emails follow the format:
`ACCOUNT_ID@PROJECT_ID.iam.gserviceaccount.com`
The `account_id` must be 6–30 characters, lowercase letters, numbers, hyphens only.
If your cluster name is longer than 24 characters the generated SA name will
fail validation. The module truncates to 24 characters to avoid this.

**Workload Identity member string format**
The IAM binding for Workload Identity must use exactly:
`serviceAccount:PROJECT_ID.svc.id.goog[NAMESPACE/KSA_NAME]`
Quotes, brackets, and the `.svc.id.goog` suffix are all required.
A single character wrong and the binding silently has no effect.

---

## Azure

### VNet

**Subnet delegation conflicts with NSG on some services**
Azure Container Instances and some PaaS services that require subnet delegation
do not allow an NSG to be attached to the same subnet. If you delegate a subnet
and attach an NSG you get a `SubnetCannotHaveNSGForIntegration` error.
Set `create_nsg = false` for delegated subnets.

**Address space changes force subnet recreation**
Changing the VNet address space after creation requires destroying and
recreating all subnets. Plan your CIDR ranges carefully upfront.
A `/16` gives you plenty of room to carve subnets without this problem.

**Resource group must exist before VNet**
If `create_resource_group = false` the resource group must already exist.
Terraform will not give a clear error if it does not, it will just
fail with a `ResourceGroupNotFound` error deep in the plan output.

---

### AKS

**`ignore_changes` on `node_count` is required**
Without `lifecycle { ignore_changes = [default_node_pool[0].node_count] }`
every `terraform apply` after the cluster autoscaler changes the node count
will try to reset it to the `desired_size` value in the config.
This causes unnecessary node churn and was one of the first real bugs found
in testing.

**OIDC issuer takes time to become available**
After the cluster is created, the OIDC issuer URL is returned immediately
but the endpoint is not serving tokens for 2–5 minutes. Federated credential
bindings created immediately after apply may fail until the issuer warms up.

**System node pool cannot be scaled to zero**
AKS requires at least one node in the system node pool at all times.
Attempting to set `min_count = 0` on the system pool returns a validation error.
Use a separate user node pool for workloads that need to scale to zero.

**`Standard_D2s_v3` not available in all regions**
The default VM size works in most regions but some regions (especially newer ones)
have quota restrictions. If you get a `SkuNotAvailable` error, check available
sizes with `az vm list-skus --location YOUR_REGION --output table`.

**Workload Identity requires both `oidc_issuer_enabled` and `workload_identity_enabled`**
Setting only one of these is a common mistake. Both must be `true` or
the federated credential binding silently fails. The AKS docs mention this
but it is easy to miss if you are following older tutorials.

---

## Terratest

**Test timeout must account for cluster creation time**
EKS, GKE and AKS all take 10–15 minutes to provision. The default Go test
timeout is 10 minutes. Always run with `-timeout 30m` minimum or your tests
will fail mid-provision and leave orphaned resources in your cloud account.

**Orphaned resources after failed tests**
If a test panics before `defer terraform.Destroy()` runs, resources are left
in your cloud account. Keep a script handy to clean up:
`terraform destroy -auto-approve` from the example directory.
Check your cloud console after any failed test run.

**Parallel tests and IAM propagation**
Running multiple Terratest tests in parallel with `t.Parallel()` can cause
IAM role creation to race with resource creation that depends on those roles.
Add `depends_on` explicitly in your test fixtures if you see intermittent
`AccessDenied` errors that pass on retry.

---

## CI / GitHub Actions

**Checkov soft_fail vs hard_fail**
The CI pipeline runs Checkov with `soft_fail: true` so it reports findings
without blocking the pipeline. Change this to `soft_fail: false` once you
have addressed the findings — otherwise the security scan is just noise.

**tflint provider plugins require network access**
`tflint --init` downloads provider-specific rulesets at runtime.
In a restricted network environment this will fail silently and tflint
will run with no provider rules. Make sure your CI runner has outbound
internet access or cache the plugins in your runner image.

**Terraform state in CI**
The CI pipeline uses `-backend=false` for validation jobs so no state
backend is needed. For the Terratest jobs, each test run creates a fresh
workspace and destroys it — no shared state required.
Do not add a remote backend to the example configurations or the
Terratest runs will conflict with each other.
