// Scope
targetScope = 'subscription'

// Parameters
param deploymentLocation string = 'West Europe'
param deploymentRg string = 'pbag-avd1-cwe-rg'

// Variables
var managementPlaneInformation = [
  {
    workspaceName: 'pbag-avd1-cwe-w1'
    workspaceFriendlyName: 'Baggenstos - Switzerland HQ'
    hostPools: [
      {
        name: 'pbag-avd1-cwe-w1-hp1-dev'
        type: 'pooled'
        loadBalancer: 'BreadthFirst'
        startVmOnConnect: true
        validationEnvironment: false
        sessionLimit: 15
        applicationGroups: [
          {
            name: 'pbag-avd1-cwe-w1-hp1-appg1-desktop'
            friendlyName: 'Development Desktop'
            groupType: 'Desktop'
          }
          {
            name: 'pbag-avd1-cwe-w1-hp1-appg2-devtools'
            friendlyName: 'Development Tools'
            groupType: 'RemoteApp'
          }
        ]
      }
      {
        name: 'pbag-avd1-cwe-w1-hp2-prod'
        type: 'pooled'
        loadBalancer: 'BreadthFirst'
        startVmOnConnect: true
        validationEnvironment: false
        sessionLimit: 35
        applicationGroups: [
          {
            name: 'pbag-avd1-cwe-w1-hp2-appg1-desktop'
            friendlyName: 'Desktop'
            groupType: 'Desktop'
          }
          {
            name: 'pbag-avd1-cwe-w1-hp2-appg2-erp'
            friendlyName: 'SAP App'
            groupType: 'RemoteApp'
          }
        ]
      }
    ]
  }
  {
    workspaceName: 'pbag-avd1-cwe-w2'
    workspaceFriendlyName: 'Baggenstos - United States Office'
    hostPools: [
      {
        name: 'pbag-avd1-cwe-w2-hp1-business'
        type: 'pooled'
        loadBalancer: 'BreadthFirst'
        startVmOnConnect: true
        validationEnvironment: false
        sessionLimit: 15
        applicationGroups: [
          {
            name: 'pbag-avd1-cwe-w2-hp1-appg1-sales'
            friendlyName: 'Sales Apps'
            groupType: 'RemoteApp'
          }
          {
            name: 'pbag-avd1-cwe-w2-hp1-appg2-finance'
            friendlyName: 'Finance Apps'
            groupType: 'RemoteApp'
          }
        ]
      }
      {
        name: 'pbag-avd1-cwe-w1-hp2-validation'
        type: 'pooled'
        loadBalancer: 'BreadthFirst'
        startVmOnConnect: true
        validationEnvironment: false
        sessionLimit: 35
        applicationGroups: [
          {
            name: 'pbag-avd1-cwe-w2-hp2-appg1-desktop'
            friendlyName: 'Desktop'
            groupType: 'Desktop'
          }
          {
            name: 'pbag-avd1-cwe-w1-hp2-appg2-finance'
            friendlyName: 'Finance Test'
            groupType: 'RemoteApp'
          }
        ]
      }
    ]
  }
]

// Resource Groups

resource rgMgPlane 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: deploymentRg 
  location: deploymentLocation
}

// Modules

module avdMgPlane 'modules/avd-backplane.bicep' = [for ws in managementPlaneInformation: {
  name: 'deploy-${ws.workspaceName}'
  scope: rgMgPlane
  params: {
    location: deploymentLocation
    poolData: ws.hostPools
    workspaceFriendlyName: ws.workspaceFriendlyName
    workspaceName: ws.workspaceName
  }
}]
