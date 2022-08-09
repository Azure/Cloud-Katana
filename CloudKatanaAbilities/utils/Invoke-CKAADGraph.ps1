function Invoke-CKAADGraph {
    <#
    .SYNOPSIS
    Invoke the AAD Graph RESTful web API to access Microsoft Cloud service resources. A wrapper around the Invoke-RestMethod to make requests to the AAD Graph API.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    Invoke-CKAADGraph is a simple PowerShell wrapper around the Invoke-RestMethod to make requests to the AAD Graph API.
    
    .PARAMETER AccessToken
    Access token obtained to use the AAD Graph API.

    .PARAMETER HttpMethod
    The HTTP method used on the request to AAD Graph.

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
    The version of the AAD Graph API your application is using.

    .PARAMETER Resource
    The resource in AAD Graph that you're referencing.

    .PARAMETER QueryParameters
    Optional OData query options or REST method parameters that customize the response.

    .PARAMETER SelectFields
    Specific properties/columns to return from objects using the $select query parameter.

    .PARAMETER Filter
    Filter results by using the $filter query parameter to retrieve just a subset of a collection.

    .PARAMETER PageSize
    Specific number of objects to return per page using the $top query parameter. $top sets the page size of results.

    .PARAMETER orderBy
    Order results by specific object properties using the $orderby query parameter. Sorting is defined by the parameter $sortIn in this function.

    .PARAMETER sortIn
    Sort results. This is used along with the $orderBy parameter in this function. Sort can be in ascensing and descening order. (e.g. desc or asc)

    .PARAMETER Body
    HTTP body request.

    .PARAMETER Headers
    HTTP Header request.

    .LINK
    https://docs.microsoft.com/en-us/graph/migrate-azure-ad-graph-request-differences
    #>

    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $True)]
        [String]$AccessToken,
        
        [Parameter(Mandatory = $False)]
        [ValidateSet('Put', 'Get', 'Post', 'Delete', 'Patch')]
        [String]$HttpMethod = "Get",

        [Parameter(Mandatory = $False)]
        [ValidateSet('api-version=1.6', 'api-version=1.61-internal')]
        [String]$Version = "api-version=1.61-internal",
        
        [parameter(Mandatory = $True)]
        [String]$Resource,
        
        [Parameter(Mandatory = $False)]
        [String]$QueryParameters,

        [parameter(Mandatory = $false)]
        [String]$SelectFields,

        [parameter(Mandatory = $false)]
        [String]$Filter,

        [parameter(Mandatory = $false)]
        [Int]$PageSize,

        [parameter(Mandatory = $false)]
        [String]$OrderBy,

        [parameter(Mandatory = $false)]
        [ValidateSet('desc','asc')]
        [String]$SortIn,

        [Parameter(Mandatory = $False)]
        [Object]$Body,
        
        [Parameter(Mandatory = $False)]
        [Object]$Headers
    )
    Process {
        if (!($Headers)) {
            $Headers = @{}
        }

        $PredefinedParameters = @()
        # Process optional query parameters
        if(![String]::IsNullOrEmpty($SelectFields)){$PredefinedParameters += "`$select=$SelectFields"}
        if(![String]::IsNullOrEmpty($Filter)){$PredefinedParameters += "`$filter=$Filter"}
        if(![int]::Equals($PageSize,0)){$PredefinedParameters += "`$top=$PageSize"}
        if(![String]::IsNullOrEmpty($OrderBy) -and ![String]::IsNullOrEmpty($SortIn)){$PredefinedParameters += "`$orderby=$OrderBy $SortIn"}

        # Define HTTP request
        $Uri = "https://graph.windows.net/myorganization/$Resource`?$($Version)$(if($PredefinedParameters){"&$($PredefinedParameters -join '&')"}elseif(![String]::IsNullOrEmpty($QueryParameters)){"?$QueryParameters"})"
        $Headers["Authorization"] = "Bearer $AccessToken"
        $Headers["Content-Type"] = "application/json"
        $params = @{
            "Method"  = $HttpMethod
            "Uri"     = $Uri
            "Body"    = $Body | ConvertTo-Json -Compress -Depth 20
            "Headers" = $Headers
        }
        # Invoke AAD Graph API
        $Response = Invoke-RestMethod @params

        if ($Response.'@odata.nextLink') {
            $results = @()
            # Search through the response until there are no more nextlinks
            do {
                # Getting the next set of results
                $params = @{
                    "Method"  = $HttpMethod
                    "Uri"     = $Response.'@odata.nextLink'
                    "Headers" = $Headers
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
}