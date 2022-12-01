@description('The SKU of App Service Plan.')
param sku string

@description('The Runtime stack of current web app')
param linuxFxVersion string

@description('App Service Plan Resource Group')
param appServicePlanRG string

@description('App Service Plan Name')
param appServicePlanName string

resource WebApp1 './app-service-tmpl.bicep' = {
  name: 'WebApp1'
  parameters: {
    webAppName: value: 'webApp1-${uniqueString(resourceGroup().id)}'
    appServicePlanRG: appServicePlanRG
    appServicePlanName: appServicePlanName
    timezone: 'Australia/Brisbane'
  }
}

resource WebApp2 './app-service-tmpl.bicep' = {
  name: 'WebApp2'
  parameters: {
    webAppName: value: 'webApp2-${uniqueString(resourceGroup().id)}'
    appServicePlanRG: appServicePlanRG
    appServicePlanName: appServicePlanName
  }
}

resource WebApp3 './app-service-tmpl.bicep' = {
  name: 'WebApp3'
  parameters: {
    webAppName: value: 'webApp3-${uniqueString(resourceGroup().id)}'
    appServicePlanRG: appServicePlanRG
    appServicePlanName: appServicePlanName
  }
}