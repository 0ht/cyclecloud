using './main.bicep'

// General Parameters
param resource_group_name = 'rg-cyclecloud'
param location = 'japaneast'
param clientIpAddress = 'XXX.XXX.XXX.XXX'

// Network Parameters
param vnetAddressPrefix = '10.10.0.0/16'
param vnetName = 'vnet-cyclecloud'
param subnet_admin_addressprefix = '10.10.1.0/24'
param subnet_admin_name = 'subnet-admin'
param subnet_anf_addressprefix = '10.10.2.0/24'
param subnet_anf_name = 'subnet-anf'
param subnet_compute_addressprefix = '10.10.3.0/24'
param subnet_compute_name = 'subnet-compute'
param subnet_pe_name = 'subnet-pe'
param subnet_pe_addressprefix = '10.10.4.0/24'


// Azure Netapp Files parameters
param anf_account_name = 'anf_account'
param anf_capacity_pool_name = 'anf_capacity_pool'
param anf_capacity_pool_service_level = 'Standard'
param anf_capacity_pool_size = 4398046511104
param anf_volume_name = 'vol01'
param anf_volume_size = 107374182400

//Storage Account parameters
param storageAccountName = 'XXXXXXXX'
param private = true
param isHnsEnabled  = false
param isNfsV3Enabled  = false

// Bastion parameters
param bastionName = 'bastion'
param bastionsku = 'Standard'
param bastionSubnetAddressPrefix = '10.10.5.0/24'

// VM parameters
param adminPassword = 'XXXXXXXX'
param adminUsername = 'cycleadmin'
param adminVMName = 'vm-admin' 
param adminVMSize = 'Standard_D2s_v4'
param adminisSpotVM = true
param ccVMName = 'vm-cyclecloud'
param ccVMSize  = 'Standard_D2s_v4'
param ccisSpotVM = true
param imageReference = {
  publisher: 'MicrosoftWindowsServer'
  offer: 'WindowsServer'
  sku: '2022-datacenter-g2'
  version: 'latest'
}

