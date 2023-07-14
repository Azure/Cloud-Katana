function Get-CKAzResourceGroups {
    <#
    .SYNOPSIS
    Invoke the Azure Resource Management API to list Azure Resource Groups.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    Get-CKAzResourceGroups is a simple PowerShell wrapper to list Azure Resource Groups via the Azure Resource Management API.

    .PARAMETER name
    Specific resource group to retrieve via the API.

    .PARAMETER subscriptionId
    The Microsoft Azure subscription ID.

    .PARAMETER filter
    Filter results by using the $filter query parameter to retrieve just a subset of a collection.

    .PARAMETER accessToken
    Access token used to access the API.

    .LINK
    https://learn.microsoft.com/en-us/rest/api/resources/resource-groups/list

    .EXAMPLE

    #>

    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $false)]
        [String]$name,
        
        [parameter(Mandatory = $True)]
        [String]$subscriptionId,

        [parameter(Mandatory = $false)]
        [String]$filter,

        [parameter(Mandatory = $true)]
        [String]$accessToken
    )

    # Variables
    $resourceString = "resourcegroups$(if(![String]::IsNullOrEmpty($name)){"/$name"})"
    $version = "2021-04-01"
    $scope = "subscriptions/$subscriptionId"

    # Validate
    $parameters = @{
        Resource = $resourceString
        HttpMethod = "Get"
        Scope = $scope
        Filter = $filter
        Version = $version
        AccessToken = $accessToken
    }
    $response = Invoke-CKAzResourceMgmtAPI @parameters
    $response
}