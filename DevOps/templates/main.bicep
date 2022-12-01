@description('The SKU of App Service Plan.')
param sku string

@description('Location for all resources.')
param location string = 'westeurope'

@description('App Service Plan Name')
param appServicePlanName string

@description('Describes plan\'s pricing tier and instance size. Check details at https://azure.microsoft.com/en-us/pricing/details/app-service/')
@allowed([
  'F1'
  'D1'
  'B1'
  'B2'
  'B3'
  'S1'
  'S2'
  'S3'
  'P1'
  'P2'
  'P3'
  'P4'
])
param sku string = 'F1'

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: appServicePlanName
  location: location
  properties: {
    reserved: true
  }
  sku: {
    name: sku
  }
  kind: 'windows'

resource WebApp1 './app-service-tmpl.bicep' = {
  name: 'WebApp1'
  parameters: {
    webAppName: value: 'webApp1-${uniqueString(resourceGroup().id)}'
    serverFarmId: appServicePlan.id
  }
}