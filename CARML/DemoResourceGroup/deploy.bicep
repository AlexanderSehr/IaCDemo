targetScope = 'subscription'

// ================ //
// Input Parameters //
// ================ //

@description('ResourceGroup input parameter')
param resourceGroupParameters object

@description('Network Security Group input parameter')
param networkSecurityGroupParameters object

@description('Virtual Network input parameter')
param vNetParameters object

// Shared
param location string = deployment().location

// =========== //
// Deployments //
// =========== //

// Resource Group
module rg 'br/modules:microsoft.resources.resourcegroups:0.4.735' = if(resourceGroupParameters.enabled) {
  name: '${uniqueString(deployment().name, location)}-rg'
  scope: subscription()
  params: {
    name: resourceGroupParameters.name
    location: location
  }
}

// Network Security Group
module nsg 'br/modules:microsoft.network.networksecuritygroups:0.4.735' = if(networkSecurityGroupParameters.enabled) {
  name: '${uniqueString(deployment().name, location)}-nsg'
  scope: resourceGroup(resourceGroupParameters.name)
  params: {
    name: networkSecurityGroupParameters.name
  }
  dependsOn: [
    rg
  ]
}

// Virtual Network
module vnet 'br/modules:microsoft.network.virtualnetworks:0.4.735' = if(vNetParameters.enabled) {
  name: '${uniqueString(deployment().name, location)}-vnet'
  scope: resourceGroup(resourceGroupParameters.name)
  params: {
    subnets: vNetParameters.subnets
    addressPrefixes: vNetParameters.addressPrefix
    name: vNetParameters.name
  }
  dependsOn: [
    rg
    nsg
  ]
}
