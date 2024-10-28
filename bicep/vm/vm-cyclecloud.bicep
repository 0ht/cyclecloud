param location string = resourceGroup().location

param vmName string
param vmSize string
param adminUsername string
@secure()
param adminPassword string
//param authenticationType string
//param securityType string
param vnetName string
param subnetName string
param isSpotVM bool

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing =  {
  name: vnetName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing =  {
  name: subnetName
  parent: vnet
}

//var publicIPAddressName = '${vmName}PublicIP'
var networkInterfaceName = '${vmName}NetInt'
var osDiskType = 'Standard_LRS'
/*
var linuxConfiguration = {
  disablePasswordAuthentication: true
  ssh: {
    publicKeys: [
      {
        path: '/home/${adminUsername}/.ssh/authorized_keys'
        keyData: adminPasswordOrKey
      }
    ]
  }
}

var securityProfileJson = {
  uefiSettings: {
    secureBootEnabled: true
    vTpmEnabled: true
  }
  securityType: securityType
}
*/

resource networkInterface 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: networkInterfaceName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnet.id
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: vmName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  plan: {
    name: 'cyclecloud8-gen2'
    publisher: 'azurecyclecloud'
    product: 'azure-cyclecloud'
  }
  properties: {
    priority: ((isSpotVM) ? 'Spot' : null)  // Enable spot instance
    evictionPolicy:  ((isSpotVM) ? 'Deallocate' : null) // Deallocate the VM on eviction

    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      osDisk: {
        osType: 'Linux'

        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: osDiskType
        }
        deleteOption: 'Detach'
      }
      dataDisks: [
        {
          caching: 'None'
          createOption: 'FromImage'
          diskSizeGB: 512
          managedDisk: {
            storageAccountType: osDiskType
          }
          lun: 0
          deleteOption: 'Detach'
        }
      ]
      imageReference: {
        publisher: 'azurecyclecloud'
        offer: 'azure-cyclecloud'
        sku: 'cyclecloud8-gen2'
        version: 'latest'
      }
    }

    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
      secrets: []
      allowExtensionOperations: true
      linuxConfiguration: {
        disablePasswordAuthentication: false
        provisionVMAgent: true
        patchSettings: {
          patchMode: 'ImageDefault'
          assessmentMode: 'ImageDefault'
        }
      }
    }
    
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
        }
      ]
    }

    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
    //securityProfile: ((securityType == 'TrustedLaunch') ? securityProfileJson : null)
  }
}

output vmName string = vm.name
output vmId string = vm.id
output vmPrincipalID string = vm.identity.principalId
