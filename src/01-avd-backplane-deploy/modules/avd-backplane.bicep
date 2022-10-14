// Scope
targetScope = 'resourceGroup'

// Parameter 
param deploymentLocation string
param poolData array
param workspaceName string
param workspaceFriendlyName string
param customRDPProperties string = 'audiocapturemode:i:1;audiomode:i:0;camerastoredirect:s:;devicestoredirect:s:;videoplaybackmode:i:1;usbdevicestoredirect:s:;encode redirected video capture:i:0;redirectsmartcards:i:0;autoreconnection enabled:i:1;drivestoredirect:s:;redirectclipboard:i:1;redirectcomports:i:0;redirectprinters:i:1;use multimon:i:1;singlemoninwindowedmode:i:1;'
param baseTagSet object

// Variables

// var ref1 = union([for (pool, index) in poolData: hp[index].outputs.appGroupIds])
// var ref2 = concat([for (pool, index) in poolData: hp[index].outputs.appGroupIds])


// Resources

resource ws 'Microsoft.DesktopVirtualization/workspaces@2022-04-01-preview' = {
	name: workspaceName
  location: deploymentLocation
  properties: {
    friendlyName: workspaceFriendlyName
    // applicationGroupReferences: [for (appRef, i) in poolData:  hp[i].outputs.appGroupIds]
  }
  tags: baseTagSet
}

// Modules
module hp 'avd-backplane-pool.bicep' = [for pool in poolData: {
  name: 'deploy-${pool.name}'
  params: {
    deploymentLocation: deploymentLocation
    appGroupData: pool.applicationGroups
    customRdpProperties: customRDPProperties
    hostPoolName: pool.name
    hostPooltype: pool.type
    loadBalancer: pool.loadBalancer
    sessionLimit: pool.sessionLimit
    startVmOnConnect: pool.startVmOnConnect
    validationEnvironment: pool.validationEnvironment
    baseTagSet: baseTagSet
    description: pool.description
  }
}]

output appReferences array = [for (appRef, i) in poolData:  hp[i].outputs.appGroupIds]
