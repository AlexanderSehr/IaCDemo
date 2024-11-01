<#
.SYNOPSIS
Invoke a new, subscription-level deployment using a template and parameters file.

.DESCRIPTION
Invoke a new, subscription-level deployment using a template and parameters file.

.PARAMETER TemplateFilePath
Mandatory. The path to the template file.

.PARAMETER TemplateParameterFilePath
Mandatory. The path to the template parameters file.

.PARAMETER Environment
Mandatory. The environment to deploy to. Is used in the deployment name.

.PARAMETER MetadataLocation
Optional. The location to store the top-level deployment metadata in.

.PARAMETER WhatIf
Optional. Run a deployment in 'WhatIf' mode to get a preview of the changes.

.EXAMPLE
New-TemplateDeployment -TemplateFilePath 'C:\template.bicep' -TemplateParameterFilePath 'C:\sbx.bicepparams'

Deploy the template 'template.bicep' with the parameters file 'sbx.bicepparams'.
#>
function New-TemplateDeployment {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $TemplateFilePath,

        [Parameter(Mandatory)]
        [string] $TemplateParameterFilePath,

        [Parameter(Mandatory)]
        [string] $Environment,

        [Parameter(Mandatory = $false)]
        [switch] $WhatIf,

        [Parameter(Mandatory = $false)]
        [string] $MetadataLocation = 'uksouth'
    )

    $deploymentParameters = @{
        TemplateFile          = $TemplateFilePath
        TemplateParameterFile = $TemplateParameterFilePath
        Location              = $MetadataLocation
        Verbose               = $true
        DeploymentName        = "{0}-{1}-{2}" -f $Environment, (Split-Path (Split-Path $TemplateFilePath -Parent) -Leaf), (-join (Get-Date -Format 'yyyyMMddTHHMM')[0..63])
    }

    if ($WhatIf) {
        $deploymentParameters['WhatIf'] = $true
    }

    Write-Verbose "Invoking deployment with" -Verbose
    Write-Verbose ($deploymentParameters | ConvertTo-Json | Out-String) -Verbose

    New-AzSubscriptionDeployment @deploymentParameters
}