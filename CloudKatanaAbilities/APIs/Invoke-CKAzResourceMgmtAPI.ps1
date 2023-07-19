function Invoke-CKAzResourceMgmtAPI {
    <#
    .SYNOPSIS
    Invoke the Azure Resource Management RESTful web API to deploy and manage the Azure infrastructure.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    Invoke-CKAzResourceMgmtAPI is a simple PowerShell wrapper around the Invoke-RestMethod to make requests to the Azure Resource Management API.
    
    .PARAMETER AccessToken
    Access token to use the Azure Resource Management API.

    .PARAMETER HttpMethod
    The HTTP method used on the request to Microsoft Graph.

    Method	Description
    ------  -----------
    GET	    Read data from a resource.
    POST	Create a new resource, or perform an action.
    PATCH	Update a resource with new values.
    PUT	    Replace a resource with a new one.
    DELETE	Remove a resource.
    
    For the CRUD methods GET and DELETE, no request body is required.
    The POST, PATCH, and PUT methods require a request body, usually specified in JSON format, that contains additional information, such as the values for properties of the resource.

    .PARAMETER Scope
    The specific scope to deploy a resource at.

    .PARAMETER Provider
    Name of Azure Resource Provider.

    .PARAMETER Resource
    The resource in the Azure Resource Management you're referencing.

    .PARAMETER QueryParameters
    Optional OData query options or REST method parameters that customize the response.

    .PARAMETER Filter
    Filter results by using the $filter query parameter to retrieve just a subset of a collection. The filter to apply on the operation.

    .PARAMETER Version
    The API version.

    .PARAMETER Body
    HTTP body request.

    .PARAMETER Headers
    HTTP Header request.

    .PARAMETER ContentType
    Content type to set the header object for the HTTP request.

    .LINK
    https://learn.microsoft.com/en-us/rest/api/resources/
    #>

    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $True)]
        [String]$AccessToken,

        [Parameter(Mandatory = $False)]
        [ValidateSet('Put', 'Get', 'Post', 'Delete', 'Patch')]
        [String]$HttpMethod = "Get",

        [Parameter(Mandatory = $False)]
        [String]$Scope,

        [Parameter(Mandatory = $False)]
        [String]$Provider,

        [Parameter(Mandatory = $True)]
        [String]$Resource,

        [Parameter(Mandatory = $False)]
        [String]$QueryParameters,

        [parameter(Mandatory = $false)]
        [String]$Filter,

        [Parameter(Mandatory = $True)]
        [String]$Version,

        [Parameter(Mandatory = $False)]
        [Object]$Body,
        
        [Parameter(Mandatory = $False)]
        [Object]$Headers,

        [Parameter(Mandatory = $False)]
        [String]$ContentType = "application/json"

    )

    # Validate Access Token
    if ((Read-CKAccessToken -Token $AccessToken).has_expired){
        throw "Token Has Expired"
    }
    
    if (-not ($Headers)) {
        $Headers = @{
            "Authorization" = "Bearer $AccessToken"
            "Content-Type"  = "$ContentType"
        }
    }

    # Process Body
    if ($Headers.ContainsKey('Content-Type')) {
        switch ($Headers['Content-Type'].ToLower()) {
            "application/json" { $Body = $Body | ConvertTo-Json -Compress -Depth 20 }
        }
    }

    # variables
    $VerParam = "api-version=$Version"
    $PredefinedParameters = @()
    # Process optional query parameters
    if(![String]::IsNullOrEmpty($Filter)){$PredefinedParameters += "`$filter=$Filter"}
    if($PredefinedParameters.count -gt 0){$PredefinedParameters += $VerParam}

    # Define HTTP request
    $OptParams = $(if($PredefinedParameters){"$($PredefinedParameters -join '&')"}elseif(![String]::IsNullOrEmpty($QueryParameters)){"$($QueryParameters)&$($VerParam)"}else{$VerParam})
    $Uri = "https://management.azure.com$(if($Scope){"/$Scope"})$(if($Provider){"/providers/$Provider"})/$($Resource)?$($OptParams)"

    $params = @{
        "Method"  = $HttpMethod
        "Uri"     = $Uri
        "Body"    = $Body
        "Headers" = $Headers
    }
    
    # Invoke Azure Manager API
    $Response = Invoke-RestMethod @params

    if ($Response.'@odata.nextLink') {
        $results = @()
        # Search through the response until there are no more nextlinks
        do {
            # Getting the next set of results
            $params = @{
                "Method"  = "Get"
                "Uri"     = $Response.'@odata.nextLink'
                "Headers" = @{"Authorization" = "Bearer $AccessToken"}
            }
            $Response = Invoke-RestMethod @params
            # Add response of current iteration to array
            $results += $Response
        } until (-not $Response.'@odata.nextLink')
        # return value from array
        $results.value
    }
    else {
        if ($Response.value) {
            $Response.value
        }
        else {
            $Response
        }
    }
}