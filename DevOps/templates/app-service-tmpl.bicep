@description('Web app name.')
@minLength(2)
param webAppName string = ''

@description('Location for all resources.')
param location string = 'westeurope'

@description('The Runtime stack of current web app')
param windowsFxVersion string = 'DOTNETCORE|6.0'

@description('App Service Plan Name')
param timezone string = ''

@description('App Service Plan ID')
param serverFarmId string 


resource webApp 'Microsoft.Web/sites@2021-02-01' = {
  name: webAppName
  location: location
  properties: {
    httpsOnly: true
    serverFarmId: serverFarmId
    siteConfig: {
      windowsFxVersion: windowsFxVersion
      minTlsVersion: '1.2'
      ftpsState: 'FtpsOnly'
      websiteTimeZone: timezone 
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}