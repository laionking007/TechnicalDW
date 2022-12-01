@description('Web app name.')
@minLength(2)
param webAppName string = ''

@description('Location for all resources.')
param location string = resourceGroup().location

@description('The Runtime stack of current web app')
param linuxFxVersion string = 'DOTNETCORE|3.0'

@description('App Service Plan Resource Group')
param appServicePlanRG string

@description('App Service Plan Name')
param appServicePlanName string

@description('App Service Plan Name')
param timezone string = ''

resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01 existing = {
  name: 'appServicePlanPortalName'
  scope: resourceGroup(appServicePlanRG)
}

resource webApp 'Microsoft.Web/sites@2021-02-01' = {
  name: webAppName
  location: location
  properties: {
    httpsOnly: true
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      minTlsVersion: '1.2'
      ftpsState: 'FtpsOnly'
      websiteTimeZone: timezone 
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}