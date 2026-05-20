package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestVNet(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../../examples/azure",
		Vars: map[string]interface{}{
			"name":     "terratest-vnet",
			"location": "uksouth",
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	vnetID := terraform.Output(t, terraformOptions, "vnet_id")
	require.NotEmpty(t, vnetID, "VNet ID should not be empty")

	subnetIDs := terraform.OutputMap(t, terraformOptions, "subnet_ids")
	assert.Equal(t, 3, len(subnetIDs), "Expected 3 subnets")
}

func TestAKS(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../../examples/azure",
		Vars: map[string]interface{}{
			"name":     "terratest-aks",
			"location": "uksouth",
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	clusterName := terraform.Output(t, terraformOptions, "cluster_name")
	require.NotEmpty(t, clusterName)

	oidcURL := terraform.Output(t, terraformOptions, "oidc_issuer_url")
	assert.Contains(t, oidcURL, "oic.prod-aks.azure.com", "OIDC issuer URL should be set")
}
