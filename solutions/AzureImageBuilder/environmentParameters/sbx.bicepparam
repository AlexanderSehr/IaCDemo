using '../main.bicep'

param resourceGroupName =  'rg-dev-image'
param location =  'uksouth'

param galleryName = 'sigmygallery'
param imageTemplateName = 'it-aib'
param  msiName = 'mi-image-build'
param triggerBuildDeploymentScriptName = 'ds-triggerBuild'
