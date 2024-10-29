targetScope = 'subscription'

@description('The name of the resource group to deploy the resources to.')
param resourceGroupName string

@description('The name of the network security group used to restrict network access in the workload\'s subnet.')
param networkSecurityGroupName string

@description('The name of the virtual network to deploy.')
param virtualNetworkName string

@description('The name of the key vault to deploy.')
param keyVaultName string

@description('The location to deploy the resources to.')
param location string

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

module networkSecurityGroup '../../modules/network/network-security-group/main.bicep' = {
  scope: rg
  name: '${uniqueString(deployment().name, location)}-nsg-${networkSecurityGroupName}'
  params: {
    name: networkSecurityGroupName
    location: location
  }
}

module virtualNetwork '../../modules/network/virtual-network/main.bicep' = {
  scope: rg
  name: '${uniqueString(deployment().name, location)}-vnet-${virtualNetworkName}'
  params: {
    name: virtualNetworkName
    location: location
    addressPrefixes: [ '10.0.0.0/16']
    subnets: [
      {
        name: 'default'
        addressPrefix: cidrSubnet('10.0.0.0/16', 24, 0)
      }
      {
        name: 'workload'
        addressPrefix: cidrSubnet('10.0.0.0/16', 24, 1)
        networkSecurityGroupResourceId: networkSecurityGroup.outputs.resourceId
      }
    ]
  }
}

module keyVault '../../modules/key-vault/vault/main.bicep' = {
  scope: rg
  name: '${uniqueString(deployment().name, location)}-kvlt-${keyVaultName}'
  params: {
    name: keyVaultName
    location: location
    privateEndpoints: [
      {
        subnetResourceId: virtualNetwork.outputs.subnetResourceIds[1]
      }
    ]
  }
}