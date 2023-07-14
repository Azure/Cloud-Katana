function New-CKAzResourceDeployment {
    <#
    .SYNOPSIS
    Invoke the Azure Resource Management API to create a new Azure Resource deployment.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    New-CKAzResourceDeployment is a simple PowerShell wrapper to create a new Azure Resource deployment via the Azure Resource Management API.

    .PARAMETER scope
    Scope of the resource deployment. (i.e. subscriptions/<SUBSCRIPTION ID>/resourceGroups/<RESOURCE GROUP>)

    .PARAMETER name
    The name of the resource deployment.

    .PARAMETER debugSetting
    The debug setting of the deployment. Specifies the type of information to log for debugging.

    .PARAMETER deploymentMode
    The mode that is used to deploy resources. This value can be either Incremental or Complete. In Incremental mode, resources are deployed without deleting existing resources that are not included in the template. In Complete mode, resources are deployed and existing resources in the resource group that are not included in the template are deleted.

    .PARAMETER template
    template as a PowerShell Hashtable.

    .PARAMETER templateFile
    a template file.

    .PARAMETER templateLink
    a link to point to an external template file.

    .PARAMETER parameters
    parameters as a PowerShell Hashtable.

    .PARAMETER parametersFile
    a parameters file.

    .PARAMETER parametersLink
    a link to point to an external parameters file.

    .PARAMETER accessToken
    Access token used to access the API.

    .LINK
    https://learn.microsoft.com/en-us/rest/api/resources/deployments/create-or-update?tabs=HTTP

    .EXAMPLE

    #>

    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $True)]
        [String]$scope,

        [parameter(Mandatory = $True)]
        [String]$name,

        [parameter(Mandatory = $False)]
        [ValidateSet('Incremental','Complete')]
        [String]$deploymentMode = 'Incremental',

        [parameter(Mandatory = $False)]
        [ValidateSet('none','requestContent','responseContent')]
        [String]$debugSetting = 'none',

        [parameter(Mandatory = $True, ParameterSetName = 'Template')]
        [Hashtable]$template,

        [parameter(Mandatory = $True, ParameterSetName = 'TemplateFile')]
        [ValidateScript({Test-Path $_})]
        [String]$templateFile,

        [parameter(Mandatory = $True, ParameterSetName = 'TemplateLink')]
        [String]$templateLink,

        [parameter(Mandatory = $False)]
        [Hashtable]$parameters,

        [parameter(Mandatory = $False)]
        [ValidateScript({Test-Path $_})]
        [String]$parametersFile,

        [parameter(Mandatory = $False)]
        [String]$parametersLink,

        [parameter(Mandatory = $true)]
        [String]$accessToken
    )

    # Template Content
    $content = @{
        Properties = @{
            mode = "$deploymentMode"
            debugSetting = @{
                detailLevel = "$debugSetting"
            }
        }
    }

    switch ($PsCmdlet.ParameterSetName) {
        "Template" {
            $content.Properties.Add("template",$template)
        }
        "TemplateFile" {
            $content.Properties.Add("template", (Get-Content $template | ConvertFrom-Json))
        }
        "TemplateLink" {
            $templateContent = @{
                "uri" = "$templateLink"
                "contentVersion" = "1.0.0.0"
            }
            $content.Properties.Add("templateLink", $templateContent)
        }
    }

    # Add Parameters to payload
    if ($parameters){
        $content.Properties.Add("parameters",$parameters)
    }
    elseif ($parametersFile) {
        $content.Properties.Add("parameters", (Get-Content $parametersFile | ConvertFrom-Json))
    }
    elseif ($parametersLink) {
        $ParamsContent = @{
            "uri" = "$parametersLink"
            "contentVersion" = "1.0.0.0"
        }
        $content.Properties.Add("parametersLink", $ParamsContent)
    }

    # Variables
    $resourceString = "deployments/$name"
    $version = "2021-04-01"

    # Validate
    $parameters = @{
        Resource = "$resourceString/validate"
        HttpMethod = "Post"
        Scope = $scope
        Provider = "Microsoft.Resources"
        Body = $content
        Version = $version
        AccessToken = $accessToken
    }
    $response = Invoke-CKAzResourceMgmtAPI @parameters
    
    while ($response.Properties.provisioningState -ne 'Succeeded' -and $response.Properties.provisioningState -ne 'Failed'){
        write-verbose "[*] Validation in progress"
        Start-Sleep 2s
        $response = Invoke-CKAzResourceMgmtAPI -Resource $resourceString -HttpMethod "Get" -Scope $scope -Provider $Provider -Version $version -accessToken $accessToken
    }

    # Deploy Resource
    $parameters = @{
        Resource = "$resourceString"
        HttpMethod = "Put"
        Scope = $scope
        Provider = "Microsoft.Resources"
        Body = $content
        Version = $version
        AccessToken = $accessToken
    }
    $response = Invoke-CKAzResourceMgmtAPI @parameters
        
    while ($response.Properties.provisioningState -ne 'Succeeded' -and $response.Properties.provisioningState -ne 'Failed'){
        write-verbose "[*] Deployment in progress"
        Start-Sleep 2s
        $response = Invoke-CKAzResourceMgmtAPI -Resource $resourceString -HttpMethod "Get" -Scope $scope -Provider $Provider -Version $version -accessToken $accessToken
    }
    $response
}