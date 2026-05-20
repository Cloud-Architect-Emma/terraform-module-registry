package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestEKS(t *testing.T) {
	t.Parallel()

	awsRegion := "us-east-1"

	terraformOptions := &terraform.Options{
		TerraformDir: "../../examples/aws",
		Vars: map[string]interface{}{
			"name":   "terratest-eks",
			"region": awsRegion,
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	clusterName := terraform.Output(t, terraformOptions, "cluster_name")
	require.NotEmpty(t, clusterName, "Cluster name should not be empty")

	clusterEndpoint := terraform.Output(t, terraformOptions, "cluster_endpoint")
	assert.Contains(t, clusterEndpoint, "eks.amazonaws.com", "Endpoint should be an EKS endpoint")

	oidcArn := terraform.Output(t, terraformOptions, "oidc_provider_arn")
	assert.Contains(t, oidcArn, "oidc-provider", "OIDC provider ARN should be set")
}
