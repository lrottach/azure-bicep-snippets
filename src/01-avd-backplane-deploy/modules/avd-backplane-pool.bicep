// Scope
targetScope = 'resourceGroup'

// Parameter
param hostPoolName string
param hostPooltype string
param customRdpProperties string
param loadBalancer string
param startVmOnConnect bool
param validationEnvironment bool
param sessionLimit int
param appGroupData array
param expirationTime string = utcNow('u')

// Resources
resource hp 'Microsoft.DesktopVirtualization/hostPools@2022-04-01-preview' = {
  name: hostPoolName
  properties: {
    hostPoolType: hostPooltype
    loadBalancerType: loadBalancer
    preferredAppGroupType: hostPooltype
    customRdpProperty: customRdpProperties
    maxSessionLimit: sessionLimit
    startVMOnConnect: startVmOnConnect
    validationEnvironment: validationEnvironment
    registrationInfo: {
      expirationTime: dateTimeAdd(expirationTime, 'PT2H')
      registrationTokenOperation: 'Update'
    }
  }
}

resource appGroup 'Microsoft.DesktopVirtualization/applicationGroups@2022-04-01-preview' = [for app in appGroupData: {
  name: app.name
  properties: {
    applicationGroupType: app.groupType
    hostPoolArmPath: hp.id
    friendlyName: app.friendlyName
  } 
}]

// Outputs
output appGroupIds array = [for (group, i) in appGroupData:  appGroup[i].id]
