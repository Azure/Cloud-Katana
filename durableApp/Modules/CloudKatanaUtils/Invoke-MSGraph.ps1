function Invoke-MSGraph {
    <#
    .SYNOPSIS
    Invoke the Microsoft Graph RESTful web API to access Microsoft Cloud service resources. A wrapper around the Invoke-RestMethod to make requests to the Microsoft Graph API.
    
    Author: Robert Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    Invoke-MSGraph is a simple PowerShell wrapper around the Invoke-RestMethod to make requests to the Microsoft Graph API.
    
    .PARAMETER AccessToken
    Access token obtained with the right permissions (delegated/Application) to use the MS Graph API.

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

    .PARAMETER Version
    The version of the Microsoft Graph API your application is using.

    .PARAMETER Resource
    The resource in Microsoft Graph that you're referencing.

    .PARAMETER QueryParameters
    Optional OData query options or REST method parameters that customize the response.

    .PARAMETER Body
    HTTP body request.

    .PARAMETER Headers
    HTTP Header request.

    .LINK
    https://docs.microsoft.com/en-us/graph/api/overview?view=graph-rest-1.0&preserve-view=true
    https://docs.microsoft.com/en-us/graph/use-the-api
    #>

    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $True)]
        [String]$AccessToken,
        [Parameter(Mandatory = $False)]
        [ValidateSet('Put', 'Get', 'Post', 'Delete', 'Patch')]
        [String]$HttpMethod = "Get",
        [Parameter(Mandatory = $False)]
        [ValidateSet('v1.0', 'beta')]
        [String]$Version = "v1.0",
        [parameter(Mandatory = $True)]
        [String]$Resource,
        [Parameter(Mandatory = $False)]
        [String]$QueryParameters,
        [Parameter(Mandatory = $False)]
        [Object]$Body,
        [Parameter(Mandatory = $False)]
        [Object]$Headers
    )
    Process {
        if (!($Headers)) {
            $Headers = @{}
        }
        $Headers["Authorization"] = "Bearer $AccessToken"
        $Headers["Content-Type"] = "application/json"
        $params = @{
            "Method"  = $HttpMethod
            "Uri"     = "https://graph.microsoft.com/$Version/$Resource$(if(![String]::IsNullOrEmpty($QueryParameters)){"?$QueryParameters"})"
            "Body"    = $Body | ConvertTo-Json -Compress
            "Headers" = $Headers
        }
        $response = Invoke-RestMethod @params
        if ($response.'@odata.nextLink') {
            $results = @()
            # Search through the response until there are no more nextlinks
            do {
                # Getting the next set of results
                $params = @{
                    "Method"  = $HttpMethod
                    "Uri"     = $response.'@odata.nextLink'
                    "Headers" = $Headers
                }
                $response = Invoke-RestMethod @params
                $results += $response
            } until (-not $response.'@odata.nextLink')
            $results
        }
        else {
            if ($response.value) {
                $response.value
            }
            else {
                $response
            }
        }
    }
}