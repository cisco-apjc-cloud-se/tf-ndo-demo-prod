terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # version = "3.25.0"
    }
  }
}

locals {
  ### App -> Region -> Instance List ###
  appregionvmlist = flatten([
    for app_key, app in var.aws_apps : [
      for reg_key, region in app.regions : [
        for vm_key, vm in region.instances :
        {
          segment_name    = app.segment
          app_name        = app.name
          region_name     = region.name
          vpc_cidr        = region.vpc_cidr
          tier            = vm.tier
          subnet_cidr     = vm.subnet_cidr
          instance_name   = vm.instance_name
          instance_count  = vm.instance_count
        }
        // if site.type != "aci"
      ]
    ]
  ])
  ### App -> Region -> Instance Map ###
  appregionvmmap = {
    for val in local.appregionvmlist:
      lower(format("%s-%s-%s", val["app_name"], val["region_name"], val["tier"])) => val
  }

  ### Segment-Region Map ###
  segmentlist = distinct(flatten([
    for app_key, app in var.aws_apps : [
      for reg_key, region in app.regions :
      {
        segment_name    = app.segment
        region_name     = region.name
        vpc_cidr        = region.vpc_cidr
      }
    ]
  ]))

  segmentmap = {
    for val in local.segmentlist:
      lower(format("%s-%s", val["segment_name"], val["region_name"])) => val
  }

}


### Create new SSH key ###
resource "aws_key_pair" "ubuntu" {
  key_name   = "tf-ubuntu"
  public_key = var.public_key
}

### Lookup Ubuntu 20.04 AMI ###
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

### Build Lookup Data Source for VPCs a.k.a Segments ###
data "aws_vpc" "vpc" {
  for_each = local.segmentmap

  cidr_block = each.value.vpc_cidr
}

### Build Lookup Data Source for Subnets ###
data "aws_subnet" "subnet" {
  for_each = local.appregionvmmap

  vpc_id = data.aws_vpc.vpc[format("%s-%s",each.value.segment_name,each.value.region_name)].id
  cidr_block = each.value.subnet_cidr
}

### Build Lookup Data Source for Security Groups ###
data "aws_security_group" "sg" {
  for_each = local.appregionvmmap

  // name = format("sgroup-[uni/tn-%s/cloudapp-%s/cloudepg-%s]", var.tenant, each.value.app_name, each.value.tier)
  name = format("uni/tn-%s/cloudapp-%s/cloudepg-%s", var.tenant, each.value.app_name, each.value.tier)
  vpc_id = data.aws_vpc.vpc[format("%s-%s",each.value.segment_name,each.value.region_name)].id

}

### Build new EC2 instances ###
module "ec2" {
  for_each = local.appregionvmmap

  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "~> 2.0"

  name                   = each.value.instance_name
  instance_count         = each.value.instance_count
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type #"t3a.micro"
  key_name               = aws_key_pair.ubuntu.id
  monitoring             = true
  vpc_security_group_ids = [data.aws_security_group.sg[each.key].id]
  subnet_id              = data.aws_subnet.subnet[each.key].id

  tags = {
    EPG = each.value.tier
  }
}
