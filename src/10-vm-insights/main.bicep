// ----------------------------------------------------------
//
//  Type:         Main
//  Author:       Lukas Rottach
//  Description:  Azure VM deployment including insights
//  Target:       Resource Group (rg-lzc-mpn2-log1-we)
//
// ----------------------------------------------------------

// Deployment scope
targetScope = 'resourceGroup'

// ------------------------
// Parameter
// ------------------------

// Deployment Parameter
param deploymentLocation string = 'westeurope'

// Network Parameter
param vnetName string = 'vnet-mpn2-dev-net1-we'
param vnetRgName string = 'rg-mpn2-dev-net1-we'
param subnetName string = 'DevBoxSubnet'

// Log Parameter
param loganalyticsWorkspaceName string = 'log-mpn2-wl1'

// VM Parameter
param vmName string = 'vm-mpn2-wl1'

param adminuser string = 'azsuperuser'
param adminpassword string = 'SuperSave123!'

// // ------------------------
// // Resource Groups
// // ------------------------

// resource rgLog 'Microsoft.Resources/resourceGroups@2023-07-01' = {
//   name: logRgName
//   location: deploymentLocation
// }

// resource rrVm 'Microsoft.Resources/resourceGroups@2023-07-01' = {
//   name: vmRgName
//   location: deploymentLocation
// }

// ------------------------
// Variables
// ------------------------
var vnetId = resourceId(vnetRgName, 'Microsoft.Network/virtualNetworks', vnetName)
var subnetRef = '${vnetId}/subnets/${subnetName}'

// ------------------------
// Resources
// ------------------------

// Log Analytics Workspace
resource log 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: loganalyticsWorkspaceName
  location: deploymentLocation
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

// Virtual Maschine
resource vm 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: vmName
  location: deploymentLocation
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B4as_v2'
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminuser
      adminPassword: adminpassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2012-R2-Datacenter'
        version: 'latest'
      }
      osDisk: {
        name: '${vmName}-os'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: '${vmName}-nic'
  location: deploymentLocation
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetRef
          }
        }
      }
    ]
  }
}
