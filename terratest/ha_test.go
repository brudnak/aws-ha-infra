package test

import (
	"fmt"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"gopkg.in/yaml.v3"
	"log"
	"net"
	"os"
	"testing"

	"github.com/spf13/viper"
)

func TestRkeHa(t *testing.T) {

	viper.AddConfigPath("../../")
	viper.SetConfigName("tool-config")
	viper.SetConfigType("yml")
	err := viper.ReadInConfig()

	if err != nil {
		log.Println("error reading config:", err)
	}

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{

		TerraformDir: "../modules/aws",
		NoColor:      true,
	})

	terraform.InitAndApply(t, terraformOptions)

	// HA 1 section
	infra1Server1IPAddress := terraform.Output(t, terraformOptions, "ha_1_server1_ip")
	infra1Server2IPAddress := terraform.Output(t, terraformOptions, "ha_1_server2_ip")
	infra1Server3IPAddress := terraform.Output(t, terraformOptions, "ha_1_server3_ip")

	infra1Server1IPAddressPrivate := terraform.Output(t, terraformOptions, "ha_1_server1_private_ip")
	infra1Server2IPAddressPrivate := terraform.Output(t, terraformOptions, "ha_1_server2_private_ip")
	infra1Server3IPAddressPrivate := terraform.Output(t, terraformOptions, "ha_1_server3_private_ip")

	// HA 2 section
	infra2Server1IPAddress := terraform.Output(t, terraformOptions, "ha_2_server1_ip")
	infra2Server2IPAddress := terraform.Output(t, terraformOptions, "ha_2_server2_ip")
	infra2Server3IPAddress := terraform.Output(t, terraformOptions, "ha_2_server3_ip")

	infra2Server1IPAddressPrivate := terraform.Output(t, terraformOptions, "ha_2_server1_private_ip")
	infra2Server2IPAddressPrivate := terraform.Output(t, terraformOptions, "ha_2_server2_private_ip")
	infra2Server3IPAddressPrivate := terraform.Output(t, terraformOptions, "ha_2_server3_private_ip")

	// H1 Asserts
	assert.Equal(t, "valid", CheckIPAddress(infra1Server1IPAddress))
	assert.Equal(t, "valid", CheckIPAddress(infra1Server2IPAddress))
	assert.Equal(t, "valid", CheckIPAddress(infra1Server3IPAddress))
	assert.Equal(t, "valid", CheckIPAddress(infra1Server1IPAddressPrivate))
	assert.Equal(t, "valid", CheckIPAddress(infra1Server2IPAddressPrivate))
	assert.Equal(t, "valid", CheckIPAddress(infra1Server3IPAddressPrivate))

	// H2 Asserts
	assert.Equal(t, "valid", CheckIPAddress(infra2Server1IPAddress))
	assert.Equal(t, "valid", CheckIPAddress(infra2Server2IPAddress))
	assert.Equal(t, "valid", CheckIPAddress(infra2Server3IPAddress))
	assert.Equal(t, "valid", CheckIPAddress(infra2Server1IPAddressPrivate))
	assert.Equal(t, "valid", CheckIPAddress(infra2Server2IPAddressPrivate))
	assert.Equal(t, "valid", CheckIPAddress(infra2Server3IPAddressPrivate))

	infra1URL := terraform.Output(t, terraformOptions, "ha_1_rancher_url")
	infra2URL := terraform.Output(t, terraformOptions, "ha_2_rancher_url")

	WriteRkeConfig(
		infra1Server1IPAddress,
		infra1Server2IPAddress,
		infra1Server3IPAddress,
		infra1Server1IPAddressPrivate,
		infra1Server2IPAddressPrivate,
		infra1Server3IPAddressPrivate,
		"ha1.yml")

	WriteRkeConfig(
		infra2Server1IPAddress,
		infra2Server2IPAddress,
		infra2Server3IPAddress,
		infra2Server1IPAddressPrivate,
		infra2Server2IPAddressPrivate,
		infra2Server3IPAddressPrivate,
		"ha2.yml")

	log.Printf("HA 1 URL: %s", infra1URL)
	log.Printf("HA 2 URL: %s", infra2URL)
}

func TestHACleanup(t *testing.T) {
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../modules/aws",
		NoColor:      true,
	})
	terraform.Destroy(t, terraformOptions)
}

func CheckIPAddress(ip string) string {
	if net.ParseIP(ip) == nil {
		return "invalid"
	} else {
		return "valid"
	}
}

func WriteRkeConfig(ip1, ip2, ip3, ip1private, ip2private, ip3private, fileName string) {
	c1 := Config{
		SSHKeyPath: viper.GetString("local.pem_path"),
		Nodes: []ConfigNode{
			{
				Address:         ip1,
				InternalAddress: ip1private,
				User:            "ubuntu",
				Role:            []string{"etcd", "controlplane", "worker"},
			},
			{
				Address:         ip2,
				InternalAddress: ip2private,
				User:            "ubuntu",
				Role:            []string{"etcd", "controlplane", "worker"},
			}, {
				Address:         ip3,
				InternalAddress: ip3private,
				User:            "ubuntu",
				Role:            []string{"etcd", "controlplane", "worker"},
			},
		},
	}

	yamlData, err := yaml.Marshal(&c1)

	if err != nil {
		fmt.Printf("Error while Marshaling. %v", err)
	}

	err = os.WriteFile(fileName, yamlData, 0644)
	if err != nil {
		panic("Unable to write data into the file")
	}
}

type Config struct {
	SSHKeyPath string       `yaml:"ssh_key_path"`
	Nodes      []ConfigNode `yaml:"nodes"`
}

type ConfigNode struct {
	Address         string   `yaml:"address"`
	InternalAddress string   `yaml:"internal_address"`
	User            string   `yaml:"user"`
	Role            []string `yaml:"role"`
}
