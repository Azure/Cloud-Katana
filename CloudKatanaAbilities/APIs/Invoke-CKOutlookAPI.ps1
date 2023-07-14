function Invoke-CKOutlookAPI {
    <#
    .SYNOPSIS
    Invoke the Microsoft Graph RESTful web API to access Microsoft Cloud service resources. A wrapper around the Invoke-RestMethod to make requests to the Outlook Office 365 API.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    Invoke-CKOutlookAPI is a simple PowerShell wrapper around the Invoke-RestMethod to make requests to the Outlook Office 365 API.
    
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

    .PARAMETER Resource
    The resource in Microsoft Graph that you're referencing.

    .PARAMETER Version
    API version.
    
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

    .PARAMETER ContentType
    Content type to set the header object for the HTTP request.

    .LINK
    https://learn.microsoft.com/en-us/previous-versions/office/office-365-api/api/version-2.0/mail-rest-operations
    https://github.com/Gerenios/AADInternals/blob/master/OutlookAPI.ps1
    https://github.com/Gerenios/AADInternals/blob/master/OutlookAPI_utils.ps1
    #>

    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $True)]
        [String]$AccessToken,

        [Parameter(Mandatory = $False)]
        [ValidateSet('Put', 'Get', 'Post', 'Delete', 'Patch')]
        [String]$HttpMethod = "Get",
        
        [parameter(Mandatory = $True)]
        [String]$Resource,
        
        [Parameter(Mandatory = $False)]
        [ValidateSet('v2.0', 'beta')]
        [String]$Version = "v2.0",

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
        [String]$ContentType = "application/json; charset=utf-8"

    )
    # Validate Access Token
    if ((Read-CKAccessToken -Token $AccessToken).has_expired){
        throw "Token Has Expired"
    }

    #Clean up variables
    $Response = $null
    
    if (-not ($Headers)) {
        $Headers = @{
            "Authorization" = "Bearer $AccessToken"
            "Accept" = "text/*, multipart/mixed, application/xml, application/json; odata.metadata=none"
            "Content-Type" = "$ContentType"
            "Prefer" = 'exchange.behavior="ActivityAccess"'
        }

        if ($ContentType -and $Body){
            switch ($ContentType.ToLower()) {
                "application/json; charset=utf-8" { $Body = $Body | ConvertTo-Json -Depth 20 }
            }
        }
    }

    $PredefinedParameters = @()
    # Process optional query parameters
    if(![String]::IsNullOrEmpty($SelectFields)){$PredefinedParameters += "`$select=$SelectFields"}
    if(![String]::IsNullOrEmpty($Filter)){$PredefinedParameters += "`$filter=$Filter"}
    if(![int]::Equals($PageSize,0)){$PredefinedParameters += "`$top=$PageSize"}
    if(![String]::IsNullOrEmpty($OrderBy) -and ![String]::IsNullOrEmpty($SortIn)){$PredefinedParameters += "`$orderby=$OrderBy $SortIn"}

    # Define HTTP request
    $Uri = "https://outlook.office.com/api/$Version/$Resource$(if($PredefinedParameters){"?$($PredefinedParameters -join '&')"}elseif(![String]::IsNullOrEmpty($QueryParameters)){"?$QueryParameters"})"
    
    $params = @{
        "Method"  = $HttpMethod
        "Uri"     = $Uri
        "Body"    = $Body
        "Headers" = $Headers
    }

    # Invoke Outlook Office 365 API
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
