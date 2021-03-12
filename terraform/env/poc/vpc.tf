provider "aws" {
  region = "us-east-1"
}

resource "aws_eip" "nat" {
  count = 1
   tags = {
        BU = "IAMS"
        CostCenter = "6465"
        Owner = "Perumal Varadharajulu"
        Email = "perumal.varadharajulu@hidglobal.com"
        Env = "POC"
        Product = "AuthEngine"
        Terraform = "True"
    }  
}
module "authengine_poc_vpc" {
    source      = "../../modules/vpc"
    aws_region = "us-east-1"
    name = "authengine-poc"
    vpcname ="authengine-poc-vpc"
    cidr    = "10.7.248.0/24"
    enable_dns_hostnames             = true
    enable_dns_support               = true
    azs = ["us-east-1a","us-east-1b","us-east-1c"]
    public_subnets = ["10.7.248.0/27","10.7.248.32/27","10.7.248.64/27"]
    private_subnets = ["10.7.248.96/27","10.7.248.128/27","10.7.248.160/27"]

    enable_nat_gateway = true
    single_nat_gateway = true
    one_nat_gateway_per_az = false
    reuse_nat_ips = true
    external_nat_ip_ids = "${aws_eip.nat.*.id}"
    business_tags = {
        BU = "IAMS"
        CostCenter = "6465"
        Owner = "Perumal Varadharajulu"
        Email = "perumal.varadharajulu@hidglobal.com"
    }
    technical_tags = {
        Env = "POC"
        Product = "AuthEngine"
        Terraform = "True"
    }
}