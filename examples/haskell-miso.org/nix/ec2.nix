let
  region = "us-east-1";
  accessKeyId = "dmj";
in
{
  require = [ ./deployment.nix ];
  resources = {
    ec2KeyPairs.my-key-pair = {
      inherit region accessKeyId;
    };
    elasticIPs.miso-ip = {
      inherit region accessKeyId;
      vpc = true;
    };
    vpcNatGateways.nat =
      { resources, ... }:{
        inherit region accessKeyId;
        allocationId = resources.elasticIPs.miso-ip;
        subnetId = resources.vpcSubnets.miso-subnet;
      };
    vpcSubnets =
      let
        subnet = { cidr, zone }:
          { resources, ... }:
          {
            inherit region zone accessKeyId;
            vpcId = resources.vpc.miso-vpc;
            cidrBlock = cidr;
            mapPublicIpOnLaunch = true;
            tags = {
              Source = "Miso";
            };
          };
      in
      { miso-subnet = subnet {
          cidr = "10.0.0.0/19";
	  zone = "us-east-1a";
	};
      };
  vpc.miso-vpc = {
    inherit region accessKeyId;
    cidrBlock = "10.0.0.0/16";
  };
  ec2SecurityGroups = {
    sg =
      { resources, lib, ... }:
      {
        inherit region accessKeyId;
        vpcId = resources.vpc.vpc-nixops;
        rules = [
          { toPort = 22; fromPort = 22; sourceIp = "41.231.120.171/32"; }
        ];
      };
    };
  vpcInternetGateways.igw =
    { resources, ... }:
    {
      inherit region accessKeyId;
      vpcId = resources.vpc.miso-vpc;
    };
  };
  webserver = { resources, ...}: {
    deployment = {
      targetEnv = "ec2";
      ec2 = {
        inherit region accessKeyId;
        instanceType = "t2.micro";
	elasticIPv4 = resources.elasticIPs.miso-ip;
        keyPair = resources.ec2KeyPairs.my-key-pair;
	vpc = resources.vpc.miso-vpc;
	subnetId = resources.vpcSubnets.miso-subnet;
	associatePublicIpAddress = true;
      };
    };
  };
}

