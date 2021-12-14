terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      # version = "=2.46.0"
    }
  }
}

locals {
  ### App -> Region -> Instance List ###
  appregionvmlist = flatten([
    for app_key, app in var.azure_apps : [
      for reg_key, region in app.regions : [
        for vm_key, vm in region.instances : [
          for i in range(vm.instance_count) :
          {
            segment_name    = app.segment
            app_name        = app.name
            region_name     = region.name
            vpc_cidr        = region.vpc_cidr
            tier            = vm.tier
            subnet_cidr     = vm.subnet_cidr
            instance_name   = vm.instance_name
            instance_count  = vm.instance_count # Total instances
            instance_number = i # Specific instance number
          }
          // if site.type != "aci"
        ]
      ]
    ]
  ])

  appregionvmmap = {
    for val in local.appregionvmlist:
      lower(format("%s-%s-%s-%d", val["app_name"], val["region_name"], val["tier"], val["instance_number"])) => val
  }

  ### App-Region Map ###
  appregionlist = flatten([
    for app_key, app in var.azure_apps : [
      for reg_key, region in app.regions :
      {
        app_name        = app.name
        segment_name    = app.segment
        region_name     = region.name
        // vpc_cidr        = region.vpc_cidr
      }
    ]
  ])

  appregionmap = {
    for val in local.appregionlist:
      lower(format("%s-%s", val["app_name"], val["region_name"])) => val
  }

  ### Segment-Region Map ###
  segmentlist = distinct(flatten([
    for app_key, app in var.azure_apps : [
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

### Build New Resource Group for Apps ###
resource "azurerm_resource_group" "rg" {
  for_each = local.appregionmap

  name     = each.value.app_name
  location = each.value.region_name
}

### Build Lookup Data Source for VNETs a.k.a Segments ###
data "azurerm_virtual_network" "segment" {
  for_each = local.segmentmap

  resource_group_name = format("CAPIC_%s_%s_%s", var.tenant, each.value.segment_name, each.value.region_name )
  name = each.value.segment_name
}

### Build Lookup Data Source for Subnets ###
data "azurerm_subnet" "subnet" {
  for_each = local.appregionvmmap

  name                 = replace(format("subnet-%s", each.value.subnet_cidr), "/", "_")
  virtual_network_name = each.value.segment_name
  resource_group_name  = format("CAPIC_%s_%s_%s", var.tenant, each.value.segment_name, each.value.region_name )
}

### Build Lookup Data Source for Security Groups ###
# ?? Needed?

### Build New VM NICs  ###
resource "azurerm_network_interface" "nic" {
  for_each = local.appregionvmmap

  name                = format("nic-%s-%d", each.value.instance_name, each.value.instance_number)
  location            = azurerm_resource_group.rg[format("%s-%s", each.value.app_name, each.value.region)].location  ## RG for App, not VNET
  resource_group_name = azurerm_resource_group.rg[format("%s-%s", each.value.app_name, each.value.region)].name      ## RG for App, not VNET

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.subnet[each.key].id #azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}

### Build New VMs  ###
resource "azurerm_linux_virtual_machine" "vm" {
  for_each = local.appregionvmmap

  name                = format("%s-%d", each.value.instance_name, each.value.instance_number)
  resource_group_name = azurerm_resource_group.rg[format("%s-%s", each.value.app_name, each.value.region)].name      ## RG for App, not VNET
  location            = azurerm_resource_group.rg[format("%s-%s", each.value.app_name, each.value.region)].location  ## RG for App, not VNET
  size                = var.instance_type
  admin_username      = "ubuntu"
  network_interface_ids = [
    azurerm_network_interface.nic[each.key].id,
  ]

  admin_ssh_key {
    username   = "ubuntu"
    public_key = var.public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20.04-LTS"
    version   = "latest"
  }
}
