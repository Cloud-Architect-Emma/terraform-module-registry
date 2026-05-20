package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestVPC(t *testing.T) {
	t.Parallel()

	awsRegion := "us-east-1"

	terraformOptions := &terraform.Options{
		TerraformDir: "../../examples/aws",
		Vars: map[string]interface{}{
			"name":   "terratest-vpc",
			"region": awsRegion,
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	vpcID := terraform.Output(t, terraformOptions, "vpc_id")
	require.NotEmpty(t, vpcID, "VPC ID should not be empty")

	vpc := aws.GetVpcById(t, vpcID, awsRegion)
	assert.Equal(t, "10.0.0.0/16", vpc.CidrBlock)

	publicSubnetIDs := terraform.OutputList(t, terraformOptions, "public_subnet_ids")
	assert.Equal(t, 3, len(publicSubnetIDs), "Expected 3 public subnets")

	privateSubnetIDs := terraform.OutputList(t, terraformOptions, "private_subnet_ids")
	assert.Equal(t, 3, len(privateSubnetIDs), "Expected 3 private subnets")

	// Verify subnets are in the right VPC
	for _, subnetID := range append(publicSubnetIDs, privateSubnetIDs...) {
		subnet := aws.GetSubnetById(t, subnetID, awsRegion)
		assert.Equal(t, vpcID, subnet.VpcId)
	}
}

func TestVPC_SingleNATGateway(t *testing.T) {
	t.Parallel()

	awsRegion := "us-east-1"

	terraformOptions := &terraform.Options{
		TerraformDir: "../../examples/aws",
		Vars: map[string]interface{}{
			"name":               "terratest-vpc-single-nat",
			"region":             awsRegion,
			"single_nat_gateway": true,
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	vpcID := terraform.Output(t, terraformOptions, "vpc_id")
	require.NotEmpty(t, vpcID)

	natGatewayIDs := terraform.OutputList(t, terraformOptions, "nat_gateway_ids")
	assert.Equal(t, 1, len(natGatewayIDs), "Single NAT gateway mode should create exactly 1 NAT gateway")
}
