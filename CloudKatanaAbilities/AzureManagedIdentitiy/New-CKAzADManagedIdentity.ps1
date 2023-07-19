function New-CKAzADManagedIdentity {
    <#
    .SYNOPSIS
    Create a new user-assigned Azure AD Managed Identity.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    New-CKAzADManagedIdentity is a simple PowerShell wrapper to create a user-assigned Azure AD managed identity.

    .PARAMETER name
    Name of the user-assigned managed identity

    .PARAMETER subscriptionId
    The Microsoft Azure subscription ID.

    .PARAMETER resourceGroupName
    The name of the resource group to deploy the resources to. The name is case insensitive. The resource group must already exist.

    .PARAMETER deploymentName
    The name of the resource deployment.

    .PARAMETER accessToken
    Access token used to access the API.

    .LINK
    https://learn.microsoft.com/en-us/rest/api/resources/deployments/create-or-update?tabs=HTTP
    https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/how-manage-user-assigned-managed-identities?pivots=identity-mi-methods-arm#create-a-user-assigned-managed-identity
    https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/how-manage-user-assigned-managed-identities?pivots=identity-mi-methods-rest#create-a-user-assigned-managed-identity

    .EXAMPLE
    $identity = New-CKAzADManagedIdentity -name 'CKManagedIdentity' -subscriptionId XXXX -resourceGroupName XXXX -accessToken $accessToken
    $identity

    id         : /subscriptions/XXXXX/resourceGroups/XXXX/providers/Microsoft.Resources/deployments/Microsoft.ManagedIdentity-20230320221609
    name       : Microsoft.ManagedIdentity-20230320221609
    type       : Microsoft.Resources/deployments
    properties : @{templateHash=XXXX; parameters=; mode=Incremental; debugSetting=; provisioningState=Accepted; timestamp=3/21/2023 2:16:09 AM; duration=PT0.000838S;correlationId=bb030d4f-60e5-4305-8cde-1ebabee5357b; providers=System.Object[]; dependencies=System.Object[]}
    #>

    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $True)]
        [String]$name,

        [parameter(Mandatory = $True)]
        [String]$subscriptionId,

        [parameter(Mandatory = $True)]
        [String]$resourceGroupName,

        [parameter(Mandatory = $False)]
        [ValidateSet('Microsoft.ManagedIdentity', 'Microsoft.Resources')]
        [String]$providerName = "Microsoft.ManagedIdentity",

        [parameter(Mandatory = $False)]
        [String]$deploymentName,

        [parameter(Mandatory = $true)]
        [String]$accessToken
    )

    # Variables
    $scope = "subscriptions/$subscriptionId/resourcegroups/$resourceGroupName"

    if ($providerName -eq 'Microsoft.ManagedIdentity'){
        $resourceString = "userAssignedIdentities/$name"
        $version = "2022-01-31-preview"
        
        # Set Resource Group Location
        $location = (Get-CKAzResourceGroups -name $resourceGroupName -subscriptionId $subscriptionId -accessToken $accessToken).location
        $body = @{
            location = $location
        }
        # Create new identity via REST API
        $parameters = @{
            Resource = "$resourceString"
            HttpMethod = "Put"
            Scope = $scope
            Provider = "Microsoft.ManagedIdentity"
            Body = $body
            Version = $version
            AccessToken = $accessToken
        }
        $response = Invoke-CKAzResourceMgmtAPI @parameters
    } else {
        if (-Not $deploymentName){
            $deploymentName = "Microsoft.ManagedIdentity-$(get-date -format yyyyMMddHHmmss)"
        }
        # Parameters Input
        $parameters = @{
            name = @{
                value = $name
            }
        }
        # Template
        $template = @{
            "`$schema" = "http://schema.management.azure.com/schemas/2014-04-01-preview/deploymentTemplate.json#"
            contentVersion = "1.0.0.0"
            parameters = @{
                name = @{
                    type = "string"
                }
            }
            resources = @(
                @{
                    type = "Microsoft.ManagedIdentity/userAssignedIdentities"
                    name = "[parameters('name')]"
                    apiVersion = "2018-11-30"
                    location = "[resourceGroup().location]"
                }
            )
            outputs = @{
                identityName = @{
                    type = "string"
                    value = "[parameters('name')]"
                }
            }
        }
        # Create new identity via ARM template
        if ($PSBoundParameters.ContainsKey('Verbose')){
            $response = New-CKAzResourceDeployment -name $deploymentName -scope $scope -template $template -parameters $parameters -accessToken $accessToken -verbose
        } else {
            $response = New-CKAzResourceDeployment -name $deploymentName -scope $scope -template $template -parameters $parameters -accessToken $accessToken
        }
    }
    $response
}