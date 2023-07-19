function New-CKAzResourceGroup {
    <#
    .SYNOPSIS
    Invoke the Azure Resource Management API to create an Azure Resource Group.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    New-CKAzResourceGroup is a simple PowerShell wrapper to create an Azure Resource Group via the Azure Resource Management API.

    .PARAMETER name
    Specific resource group to retrieve via the API.

    .PARAMETER location
    Specific location to create the resource group at.

    .PARAMETER subscriptionId
    The Microsoft Azure subscription ID.

    .PARAMETER accessToken
    Access token used to access the API.

    .LINK
    https://learn.microsoft.com/en-us/rest/api/resources/resource-groups/create-or-update?tabs=HTTP

    .EXAMPLE
    New-CKAzResourceGroup -name Roberto-ResourceGroupTest -location eastus -subscriptionId XXXXX -accessToken $AccessToken

    id         : /subscriptions/XXXXX/resourceGroups/Roberto-ResourceGroupTest
    name       : Roberto-ResourceGroupTest
    type       : Microsoft.Resources/resourceGroups
    location   : eastus
    properties : @{provisioningState=Succeeded}
    #>

    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $True)]
        [String]$name,

        [parameter(Mandatory = $True)]
        [String]$location,
        
        [parameter(Mandatory = $True)]
        [String]$subscriptionId,

        [parameter(Mandatory = $true)]
        [String]$accessToken
    )

    # Variables
    $resourceString = "resourcegroups/$name"
    $version = "2021-04-01"
    $scope = "subscriptions/$subscriptionId"
    $body = @{
        location = $location
    }
    # Validate
    $parameters = @{
        Resource = $resourceString
        HttpMethod = "Put"
        Scope = $scope
        Body = $body
        Version = $version
        AccessToken = $accessToken
    }
    $response = Invoke-CKAzResourceMgmtAPI @parameters
    $response
}