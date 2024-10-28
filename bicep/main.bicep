param resource_group_name string
param location string
param tags object = {}
param private bool = true
param clientIpAddress string

targetScope = 'subscription'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: resource_group_name
  location: location
}


// Virtual Network
param vnetAddressPrefix string
param vnetName string

module virtualNetwork './network/vnet.bicep' = {
  scope: resourceGroup
  name: 'virtualNetworkDeployment'
  params: {
    location: location
    vnetName: vnetName
    vnetAddressPrefix: vnetAddressPrefix
    tags: {}
  }
}

// NSG rules 
param defaultNSG array = [
  {
    name: 'AllowWebInBound'
    properties: {
      description: 'AllowClientInBound'
      protocol: 'TCP'
      sourcePortRange: '*'
      destinationPortRanges: ['80','443']
      sourceAddressPrefix: '*'
      destinationAddressPrefix: 'VirtualNetwork'
      access: 'Allow'
      priority: 1000
      direction: 'Inbound'
    }
  }
  {
    name: 'AllowManagementInBound'
    properties: {
      description: 'AllowManagementInBound'
      protocol: 'TCP'
      sourcePortRange: '*'
      destinationPortRanges: ['22','3389']
      sourceAddressPrefix: '*'
      destinationAddressPrefix: 'VirtualNetwork'
      access: 'Allow'
      priority: 1001
      direction: 'Inbound'
    }
  }
]

// NSG 
module nsg './network/nsg.bicep' = {
  scope: resourceGroup
  name: 'nsg-${location}'
  params: {
    nsgName: 'nsg-${location}'
    location: location
    tags: {}
    securityRules: defaultNSG
  }
  dependsOn: [
    virtualNetwork
  ]
}

// Subnets
param subnet_admin_name string
param subnet_admin_addressprefix string
param subnet_compute_name string
param subnet_compute_addressprefix string
param subnet_anf_name string
param subnet_anf_addressprefix string
param subnet_pe_name string
param subnet_pe_addressprefix string

module subnet_admin './network/subnet.bicep' = {
  scope: resourceGroup
  name: '${subnet_admin_name}-Deployment'
  params: {
    vnetName: vnetName
    subnetName: subnet_admin_name
    subnetAddressPrefix: subnet_admin_addressprefix
    nsgId: nsg.outputs.nsgId
  }
  dependsOn: [
    virtualNetwork
    nsg
  ]
}

module subnet_compute './network/subnet.bicep' = {
  scope: resourceGroup
  name: '${subnet_compute_name}-Deployment'
  params: {
    vnetName: vnetName
    subnetName: subnet_compute_name
    subnetAddressPrefix: subnet_compute_addressprefix
    nsgId: nsg.outputs.nsgId
  }
  dependsOn: [
    virtualNetwork
    subnet_admin // to prevent deployment confriction
    nsg
  ]
}

module subnet_anf './network/subnet.bicep' = {
  scope: resourceGroup
  name: '${subnet_anf_name}-Deployment'
  params: {
    vnetName: vnetName
    subnetName: subnet_anf_name
    subnetAddressPrefix: subnet_anf_addressprefix
    delegations: [
      {
        name: 'Microsoft.NetApp/volumes'
        properties: {
          serviceName: 'Microsoft.NetApp/volumes'
        }
      }
    ]
  }
  dependsOn: [
    virtualNetwork
    subnet_compute // to prevent deployment confriction
    nsg
  ]
}

module subnet_pe './network/subnet.bicep' = {
  scope: resourceGroup
  name: '${subnet_pe_name}-Deployment'
  params: {
    vnetName: vnetName
    subnetName: subnet_pe_name
    subnetAddressPrefix: subnet_pe_addressprefix
  }
  dependsOn: [
    virtualNetwork
    subnet_anf // to prevent deployment confriction
    nsg
  ]
}


// Azure NetApp Files
param anf_account_name string
param anf_capacity_pool_name string
param anf_capacity_pool_service_level string
param anf_capacity_pool_size int
param anf_volume_name string
param anf_volume_size int

module anf 'br/public:avm/res/net-app/net-app-account:0.1.2' = {
  scope: resourceGroup
  name: 'anf-Deployment'
  params: {
    // Required parameters
    name: anf_account_name
    location: location
    tags: {}
    // Non-required parameters
    capacityPools: [
      {
        name: anf_capacity_pool_name
        serviceLevel: anf_capacity_pool_service_level
        size: anf_capacity_pool_size //4398046511104
        volumes: [
          {
            name: anf_volume_name
            exportPolicyRules: [
              {
                allowedClients: vnetAddressPrefix
                nfsv3: true
                nfsv41: false
                ruleIndex: 1
                unixReadOnly: false
                unixReadWrite: true
              }
            ]
            protocolTypes: [
              'NFSv3'
            ]
            subnetResourceId: subnet_anf.outputs.subnetId
            usageThreshold: anf_volume_size //107374182400
          }
        ]
      }
    ]
  }
}


param storageAccountName string = 'cyclecloudshare'
param isHnsEnabled bool  = true
param isNfsV3Enabled bool = true

// Storage Account
module storage './storage/storage-account.bicep' = {
  name: 'storage'
  scope: resourceGroup
  params: {
    storageAccountName: storageAccountName
    location: location
    tags: tags
    isHnsEnabled: isHnsEnabled
    isNfsV3Enabled: isNfsV3Enabled
    publicNetworkAccess: (private) ? 'Disabled' : 'Enabled'
    sku: {
      name: 'Standard_LRS'
    }
    deleteRetentionPolicy: {
      enabled: true
      days: 2
    }
    // for private environment
    private: private
    clientIpAddress: (private) ? clientIpAddress : ''
    vnetName: (private) ? vnetName : ''
    peSubnetName: (private) ? subnet_pe_name : ''
  }
  dependsOn: [
    virtualNetwork
    subnet_pe
  ]
}


// Bastion
param bastionName string
param bastionsku string
param bastionSubnetAddressPrefix string

module bastion './security/bastion.bicep' = {
  scope: resourceGroup
  name: 'bastion-${location}'
  params: {
    location: location
    bastionName: bastionName
    sku: bastionsku
    vnetName: vnetName
    bastionSubnetAddressPrefix: bastionSubnetAddressPrefix
  }
  dependsOn: [
    virtualNetwork
  ]
}


// CycleCloud VM
param ccVMName string
param ccVMSize string
param adminUsername string
@secure()
param adminPassword string
param ccisSpotVM bool

module ccVM './vm/vm-cyclecloud.bicep' = {
  scope: resourceGroup
  name: 'ccVM-${location}'
  params: {
    location: location
    vmName: ccVMName
    vmSize: ccVMSize
    adminUsername: adminUsername
    adminPassword: adminPassword
    vnetName: vnetName
    subnetName: subnet_admin_name
    isSpotVM: ccisSpotVM
  }
  dependsOn: [
    virtualNetwork
    subnet_admin
  ]
}

// RBAC
param roleDefinitionId string = 'b24988ac-6180-42a0-ab88-20f7382dd24c' // Contributor role ID

resource role 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, roleDefinitionId)
  properties: {
    principalId: ccVM.outputs.vmPrincipalID
    principalType: 'ServicePrincipal'
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
  }
  dependsOn: [
    ccVM
  ]
}

// Admin VM 
param adminVMName string
param adminVMSize string
param adminisSpotVM bool
param imageReference object

module adminVM './vm/vm-win.bicep' = {
  scope: resourceGroup
  name: 'adminVM-${location}'
  params: {
    location: location
    vmName: adminVMName
    vmSize: adminVMSize
    adminUsername: adminUsername
    adminPassword: adminPassword
    vnetName: vnetName
    subnetName: subnet_admin_name
    isSpotVM: adminisSpotVM
    imageReference: imageReference
  }
  dependsOn: [
    virtualNetwork
    subnet_admin
  ]
}

