function Invoke-CKMSGraphAPI {
    <#
    .SYNOPSIS
    Invoke the Microsoft Graph RESTful web API to access Microsoft Cloud service resources. A wrapper around the Invoke-RestMethod to make requests to the Microsoft Graph API.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    Invoke-CKMSGraphAPI is a simple PowerShell wrapper around the Invoke-RestMethod to make requests to the Microsoft Graph API.
    
    .PARAMETER AccessToken
    Access token obtained with the right permissions (delegated/Application) to use the MS Graph API.

    .PARAMETER APIType
    Type of Graph API. Microsoft Graph (MSGraph) or Azure Active Directory Graph (AADGraph).

    .PARAMETER APIEndpoint
    Which Graph API service endpoint: ('Global','US Gov L4','DOD','Germany','China')

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

    .PARAMETER ContentType
    Content type to set the header object for the HTTP request.

    .PARAMETER InlineFilePath
    Path to a local file to pass through the HTTP request.

    .LINK
    https://docs.microsoft.com/en-us/graph/api/overview?view=graph-rest-1.0&preserve-view=true
    https://docs.microsoft.com/en-us/graph/use-the-api
    https://learn.microsoft.com/en-us/graph/migrate-azure-ad-graph-request-differences
    #>

    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $True)]
        [String]$AccessToken,

        [Parameter(Mandatory = $false)]
        [ValidateSet('MSGraph', 'AADGraph')]
        [String]$APIType = 'MSGraph',

        [Parameter(Mandatory = $false)]
        [ValidateSet('Global','US Gov L4','DOD','Germany','China')]
        [String]$APIEndpoint = 'Global',

        [Parameter(Mandatory = $False)]
        [ValidateSet('Put', 'Get', 'Post', 'Delete', 'Patch')]
        [String]$HttpMethod = "Get",
        
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
        [String]$ContentType = "application/json",

        [Parameter(Mandatory = $False)]
        [string]$InlineFilePath

    )

    DynamicParam {
        # Adding Dynamic parameters
        $parameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

        if ($APIType -eq 'MSGraph') {
            $ParamOptions = @(
                @{
                    'Name'                  = 'Version';
                    'ValidateSetOptions'    = @('v1.0', 'beta');
                    'Mandatory'             = $false
                }
            )
        }
        elseif ($APIType -eq 'AADGraph') {
            $ParamOptions = @(
                @{
                    'Name'                  = 'Version';
                    'ValidateSetOptions'    = @('api-version=1.6', 'api-version=1.61-internal');
                    'Mandatory'             = $false
                }
            )  
        }

        # Adding Dynamic parameter
        foreach ($NewParam in $ParamOptions) {
            $RuntimeParam = New-DynamicParam @NewParam
            $parameterDictionary.Add($NewParam.Name, $RuntimeParam)
        }
        return $parameterDictionary
    }

    Begin {
        #Clean up variables
        $Response = $null

        # Service Endpoints
        if ($APIType -eq 'MSGraph') {
            switch ($APIEndpoint){
                'Global'    { $EndpointUrl = 'https://graph.microsoft.com' }
                'US Gov L4' { $EndpointUrl = 'https://graph.microsoft.us' }
                'DOD'       { $EndpointUrl = 'https://dod-graph.microsoft.us' }
                'Germany'   { $EndpointUrl = 'https://graph.microsoft.de' }
                'China'     { $EndpointUrl = 'https://microsoftgraph.chinacloudapi.cn' }
            }
        }
        else {
            switch ($APIEndpoint){
                'Global'    { $EndpointUrl = 'https://graph.windows.net' }
                'US Gov L4' { $EndpointUrl = 'https://graph.microsoftazure.us' }
                'DOD'       { $EndpointUrl = 'https://graph.microsoftazure.us' }
                'Germany'   { $EndpointUrl = 'https://graph.cloudapi.de' }
                'China'     { $EndpointUrl = 'https://graph.chinacloudapi.cn' }
            }

        }

        # Process Dynamic parameters
        if (-not $PSBoundParameters.ContainsKey('Version')) {
            if ($APIType -eq 'MSGraph') {
                $PSBoundParameters.Add('Version','v1.0')
            } else {
                $PsBoundParameters.Add('Version', 'api-version=1.61-internal')
            }
        }
        $PsBoundParameters.GetEnumerator() | ForEach-Object { New-Variable -Name $_.Key -Value $_.Value -ea 'SilentlyContinue'}

        # Validate Access Token
        if ((Read-CKAccessToken -Token $AccessToken).has_expired){
            throw "Token Has Expired"
        }
    }

    Process {
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

        $PredefinedParameters = @()
        # Process optional query parameters
        if(![String]::IsNullOrEmpty($SelectFields)){$PredefinedParameters += "`$select=$SelectFields"}
        if(![String]::IsNullOrEmpty($Filter)){$PredefinedParameters += "`$filter=$Filter"}
        if(![int]::Equals($PageSize,0)){$PredefinedParameters += "`$top=$PageSize"}
        if(![String]::IsNullOrEmpty($OrderBy) -and ![String]::IsNullOrEmpty($SortIn)){$PredefinedParameters += "`$orderby=$OrderBy $SortIn"}

        # Define HTTP request
        # Reference: https://learn.microsoft.com/en-us/graph/migrate-azure-ad-graph-request-differences#basic-requests
        if ($APIType -eq 'MSGraph'){
            # https://graph.microsoft.com/{version}/{resource}?query-parameters
            $Uri = "$EndpointUrl/$Version/$Resource$(if($PredefinedParameters){"?$($PredefinedParameters -join '&')"}elseif(![String]::IsNullOrEmpty($QueryParameters)){"?$QueryParameters"})"
        }
        else {
            # https://graph.windows.net/{tenant_id}/{resource}?{version}&query-parameters
            $Uri = "$EndpointUrl/myorganization/$Resource`?$($Version)$(if($PredefinedParameters){"&$($PredefinedParameters -join '&')"}elseif(![String]::IsNullOrEmpty($QueryParameters)){"?$QueryParameters"})"
        }
        
        $params = @{
            "Method"  = $HttpMethod
            "Uri"     = $Uri
            "Body"    = $Body
            "Headers" = $Headers
        }
        if ($InlineFilePath){
            $params['InFile'] = $InlineFilePath
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

function New-DynamicParam {
    [CmdletBinding()]
    [OutputType('System.Management.Automation.RuntimeDefinedParameter')]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        [Parameter(Mandatory=$false)]
        [array]$ValidateSetOptions,
        [Parameter()]
        [switch]$Mandatory = $false,
        [Parameter()]
        [switch]$ValueFromPipeline = $false,
        [Parameter()]
        [switch]$ValueFromPipelineByPropertyName = $false
    )

    $Attrib = New-Object System.Management.Automation.ParameterAttribute
    $Attrib.Mandatory = $Mandatory.IsPresent
    $Attrib.ParameterSetName = "__AllParameterSets"
    $Attrib.ValueFromPipeline = $ValueFromPipeline.IsPresent
    $Attrib.ValueFromPipelineByPropertyName = $ValueFromPipelineByPropertyName.IsPresent

    # Create AttributeCollection object for the attribute
    $Collection = new-object System.Collections.ObjectModel.Collection[System.Attribute]
    # Add our custom attribute
    $Collection.Add($Attrib)
    # Add Validate Set
    if ($ValidateSetOptions)
    {
        $ValidateSet= new-object System.Management.Automation.ValidateSetAttribute($ValidateSetOptions)
        $Collection.Add($ValidateSet)
    }

    # Create Runtime Parameter
    $DynParam = New-Object System.Management.Automation.RuntimeDefinedParameter($Name, [string], $Collection)
    return $DynParam
}
