targetScope = 'subscription'

@description('The name of the resource group to deploy the resources to.')
param resourceGroupName string

@description('The location to deploy the resources to.')
param location string = deployment().location

@description('The name of the Compute Gallery to deploy.')
param galleryName string

@description('The name of the image definition in the Compute Gallery.')
param computeGalleryImageDefinitionName string = 'myImage'

@description('The name of the managed identity to deploy.')
param msiName string

@description('The name of the image template to deploy. MUST be unique for each run.')
param imageTemplateName string

@description('The name of the deployment script to trigger the image build.')
param triggerBuildDeploymentScriptName string

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

module managedIdentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.4.1' = {
  scope: rg
  params: {
    name: msiName
  }
}

// MSI RG contributor assignment
resource contributorRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: 'b24988ac-6180-42a0-ab88-20f7382dd24c' // Contributor
  scope: tenant()
}

resource imageMSI_rg_rbac 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(rg.id, msiName, contributorRole.id)
  properties: {
    principalId: managedIdentity.outputs.principalId
    roleDefinitionId: contributorRole.id
    principalType: 'ServicePrincipal'
  }
}


module computeGallery 'br/public:avm/res/compute/gallery:0.9.2' = {
  scope: rg
  params: {
    name: galleryName
    images: [
      {
        name: 'myImage'
        hyperVGeneration: 'V2'
        identifier: {
          publisher: 'devops'
          offer: 'devops_linux'
          sku: 'devops_linux_az'
        }
        osState: 'Generalized'
        osType: 'Linux'
      }
    ]
  }
}

module imageTemplate 'br/public:avm/res/virtual-machine-images/image-template:0.5.2' = {
  scope: rg
  params: {
    name: imageTemplateName
    distributions: [
      {
        sharedImageGalleryImageDefinitionResourceId: computeGallery.outputs.imageResourceIds[0]
        type: 'SharedImage'
      }
    ]
    imageSource: {
      type: 'PlatformImage'
      publisher: 'canonical'
      offer: '0001-com-ubuntu-server-jammy'
      sku: '22_04-lts-gen2'
      version: 'latest'
    }
    managedIdentities: {
      userAssignedResourceIds: [
        managedIdentity.outputs.resourceId
      ]
    }
  }
}

module triggerBuildDeploymentScript 'br/public:avm/res/resources/deployment-script:0.5.1' = {
  scope: rg
  params: {
    name: triggerBuildDeploymentScriptName
    kind: 'AzurePowerShell'
    azPowerShellVersion: '12.0'
    managedIdentities: {
      userAssignedResourceIds: [
        managedIdentity.outputs.resourceId
      ]
    }
    scriptContent: imageTemplate.outputs.runThisCommand
  }
  dependsOn: [
    imageMSI_rg_rbac
  ]
}


// Alternative using the pattern module

module aib 'br/public:avm/ptn/virtual-machine-images/azure-image-builder:0.1.6' = {
  params: {
    computeGalleryName: galleryName
    
    computeGalleryImageDefinitionName: computeGalleryImageDefinitionName
    computeGalleryImageDefinitions: [
      {
        name: computeGalleryImageDefinitionName
        hyperVGeneration: 'V2'
        identifier: {
          publisher: 'devops'
          offer: 'devops_linux'
          sku: 'devops_linux_az'
        }
        osState: 'Generalized'
        osType: 'Linux'
      }
    ]
    imageTemplateImageSource: {
      type: 'PlatformImage'
      publisher: 'canonical'
      offer: '0001-com-ubuntu-server-jammy'
      sku: '22_04-lts-gen2'
      version: 'latest'
    }
  }
}
