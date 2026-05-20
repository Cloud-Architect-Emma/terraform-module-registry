package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestVPC(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../../examples/gcp",
		Vars: map[string]interface{}{
			"name":       "terratest-vpc",
			"project_id": "YOUR_GCP_PROJECT_ID",
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	networkName := terraform.Output(t, terraformOptions, "network_name")
	require.NotEmpty(t, networkName, "Network name should not be empty")

	subnetIDs := terraform.OutputMap(t, terraformOptions, "subnet_ids")
	assert.Equal(t, 2, len(subnetIDs), "Expected 2 subnets")
}

func TestGKE(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../../examples/gcp",
		Vars: map[string]interface{}{
			"name":       "terratest-gke",
			"project_id": "YOUR_GCP_PROJECT_ID",
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	clusterName := terraform.Output(t, terraformOptions, "cluster_name")
	require.NotEmpty(t, clusterName)

	wiPool := terraform.Output(t, terraformOptions, "workload_identity_pool")
	assert.Contains(t, wiPool, "svc.id.goog", "Workload identity pool should be set")
}
