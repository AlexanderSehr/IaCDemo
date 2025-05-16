using '../main.bicep'

param resourceGroupName =  'rg-dev-image'
param location =  'uksouth'

param computeGalleryName = 'sigmygallery'
param imageTemplateName = 'it-aib'
param managedIdentityName = 'mi-image-build'
param triggerBuildDeploymentScriptName = 'ds-triggerBuild'
