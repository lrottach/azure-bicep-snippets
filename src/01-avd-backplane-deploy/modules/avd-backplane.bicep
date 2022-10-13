// Scope
targetScope = 'resourceGroup'

// Parameter 
param location string
param poolData array
param workspaceName string
param workspaceFriendlyName string
param customRDPProperties string = 'audiocapturemode:i:1;audiomode:i:0;camerastoredirect:s:;devicestoredirect:s:;videoplaybackmode:i:1;usbdevicestoredirect:s:;encode redirected video capture:i:0;redirectsmartcards:i:0;autoreconnection enabled:i:1;drivestoredirect:s:;redirectclipboard:i:1;redirectcomports:i:0;redirectprinters:i:1;use multimon:i:1;singlemoninwindowedmode:i:1;'

// Resources

resource ws 'Microsoft.DesktopVirtualization/workspaces@2022-04-01-preview' = {
	name: workspaceName
  location: location
  properties: {
    friendlyName: workspaceFriendlyName
  }
}

// Modules
module hp 'avd-backplane-pool.bicep' = [for pool in poolData: {
  name: 'deploy-${pool.name}'
  params: {
    appGroupData: pool.applicationGroups
    customRdpProperties: customRDPProperties
    hostPoolName: pool.name
    hostPooltype: pool.type
    loadBalancer: pool.loadBalancer
    sessionLimit: pool.sessionLimit
    startVmOnConnect: pool.startVmOnConnect
    validationEnvironment: pool.validationEnvironment
  }
}]
