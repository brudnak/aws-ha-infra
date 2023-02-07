package hcl

import (
	"fmt"
	"github.com/hashicorp/hcl/v2/hclwrite"
	"github.com/zclconf/go-cty/cty"
	"os"
)

func GenAwsVar(
	accessKey,
	secretKey,
	awsPrefix,
	awsVpc,
	subnetA,
	subnetB,
	subnetC,
	awsAmi,
	subnetId,
	securityGroupId,
	pemKeyName,
	route53Fqdn string) {

	f := hclwrite.NewEmptyFile()

	tfVarsFile, err := os.Create("../modules/aws/terraform.tfvars")
	if err != nil {
		fmt.Println(err)
		return
	}

	rootBody := f.Body()

	rootBody.SetAttributeValue("aws_access_key", cty.StringVal(accessKey))
	rootBody.SetAttributeValue("aws_secret_key", cty.StringVal(secretKey))
	rootBody.SetAttributeValue("aws_prefix", cty.StringVal(awsPrefix))
	rootBody.SetAttributeValue("aws_vpc", cty.StringVal(awsVpc))
	rootBody.SetAttributeValue("aws_subnet_a", cty.StringVal(subnetA))
	rootBody.SetAttributeValue("aws_subnet_b", cty.StringVal(subnetB))
	rootBody.SetAttributeValue("aws_subnet_c", cty.StringVal(subnetC))
	rootBody.SetAttributeValue("aws_ami", cty.StringVal(awsAmi))
	rootBody.SetAttributeValue("aws_subnet_id", cty.StringVal(subnetId))
	rootBody.SetAttributeValue("aws_security_group_id", cty.StringVal(securityGroupId))
	rootBody.SetAttributeValue("aws_pem_key_name", cty.StringVal(pemKeyName))
	rootBody.SetAttributeValue("aws_route53_fqdn", cty.StringVal(route53Fqdn))

	_, err = tfVarsFile.Write(f.Bytes())
	if err != nil {
		fmt.Println(err)
		return
	}
}
