function Invoke-CKMSGraph {
    <#
    .SYNOPSIS
    Invoke the Microsoft Graph RESTful web API to access Microsoft Cloud service resources. A wrapper around the Invoke-RestMethod to make requests to the Microsoft Graph API.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    Invoke-CKMSGraph is a simple PowerShell wrapper around the Invoke-RestMethod to make requests to the Microsoft Graph API.
    
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
        [Object]$Headers,

        [Parameter(Mandatory = $False)]
        [String]$ContentType = "application/json"

    )
    Process {
        if (-not ($Headers)) {
            $Headers = @{
                "Authorization" = "Bearer $AccessToken"
                "Content-Type"  = "$ContentType"
            }
        }

        $PredefinedParameters = @()
        # Process optional query parameters
        if(![String]::IsNullOrEmpty($SelectFields)){$PredefinedParameters += "`$select=$SelectFields"}
        if(![String]::IsNullOrEmpty($Filter)){$PredefinedParameters += "`$filter=$Filter"}
        if(![int]::Equals($PageSize,0)){$PredefinedParameters += "`$top=$PageSize"}
        if(![String]::IsNullOrEmpty($OrderBy) -and ![String]::IsNullOrEmpty($SortIn)){$PredefinedParameters += "`$orderby=$OrderBy $SortIn"}

        # Define HTTP request
        $Uri = "https://graph.microsoft.com/$Version/$Resource$(if($PredefinedParameters){"?$($PredefinedParameters -join '&')"}elseif(![String]::IsNullOrEmpty($QueryParameters)){"?$QueryParameters"})"
        $params = @{
            "Method"  = $HttpMethod
            "Uri"     = $Uri
            "Headers" = $Headers
        }
        if ($ContentType){
            switch ($ContentType.ToLower()) {
                "application/json" { $params['Body'] = $Body | ConvertTo-Json -Compress -Depth 20 }
            }
        }
        # Invoke MS Graph API
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
}