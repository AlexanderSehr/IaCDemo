targetScope = 'subscription'

@description('The name of the resource group to deploy the resources to.')
param resourceGroupName string

@description('The location to deploy the resources to.')
param location string = deployment().location

@description('The name of the Compute Gallery to deploy.')
param computeGalleryName string

@description('The name of the image definition in the Compute Gallery.')
param computeGalleryImageDefinitionName string = 'myImage'

@description('The name of the managed identity to deploy.')
param managedIdentityName string

@description('The name of the image template to deploy. MUST be unique for each run.')
param imageTemplateName string

@description('The name of the deployment script to trigger the image build.')
param triggerBuildDeploymentScriptName string
