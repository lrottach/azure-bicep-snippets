// Scope
targetScope = 'resourceGroup'

// Parameter
param deploymentLocation string
param hostPoolName string
param hostPooltype string
param customRdpProperties string
param preferredAppGroupType string = 'RailApplications'
param loadBalancer string
param startVmOnConnect bool
param validationEnvironment bool
param sessionLimit int
param appGroupData array
param expirationTime string = utcNow('u')
param baseTagSet object
param description string

// Resources
resource hp 'Microsoft.DesktopVirtualization/hostPools@2022-04-01-preview' = {
  name: hostPoolName
  location: deploymentLocation
  properties: {
    hostPoolType: hostPooltype
    loadBalancerType: loadBalancer
    preferredAppGroupType: preferredAppGroupType
    customRdpProperty: customRdpProperties
    maxSessionLimit: sessionLimit
    startVMOnConnect: startVmOnConnect
    validationEnvironment: validationEnvironment
    registrationInfo: {
      expirationTime: dateTimeAdd(expirationTime, 'PT2H')
      registrationTokenOperation: 'Update'
    }
  }
  tags: union(baseTagSet, {
    ServiceDescription: description
  })
}

resource appGroup 'Microsoft.DesktopVirtualization/applicationGroups@2022-04-01-preview' = [for app in appGroupData: {
  name: app.name
  location: deploymentLocation
  properties: {
    applicationGroupType: app.groupType
    hostPoolArmPath: hp.id
    friendlyName: app.friendlyName
  } 
  tags: baseTagSet
}]

// Outputs
output appGroupIds array = [for (group, i) in appGroupData:  appGroup[i].id]
