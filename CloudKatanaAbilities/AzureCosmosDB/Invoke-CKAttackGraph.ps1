function Invoke-CKAttackGraph {
    <#
    .SYNOPSIS
    Collect information from Azure AD such as users, applications, service principals, groups and directory roles and send it to a cosmosDB graph database via the Gremlin API.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    Invoke-CKAttackGraph is a PowerShell wrapper to collect information from Azure AD such as users, applications, service principals, groups and directory roles and send it to a cosmosDB graph database via the Gremlin API.

    .PARAMETER gremlinHostname
    FQDN of Gremlin endpoint (e.g. cosmosxxxxxx.gremlin.cosmos.azure.com).

    .PARAMETER cosmosDBRWKey
    Azure CosmosDB Read-Write primary key.

    .PARAMETER cosmosDBName
    Azure CosmosDB database name.

    .PARAMETER cosmosDBGraphName
    Azure CosmosDB graph collection name.

    .PARAMETER partitionKey
    Azure CosmosDB graph partition key.

    .PARAMETER accessToken
    Access token used to access the API.

    .LINK
    https://docs.microsoft.com/en-us/graph/api/application-list-owners?view=graph-rest-1.0&tabs=http
    https://docs.microsoft.com/en-us/graph/api/serviceprincipal-list-owners?view=graph-rest-1.0&tabs=http
    https://docs.microsoft.com/en-us/graph/api/group-list-members?view=graph-rest-1.0&tabs=http
    https://docs.microsoft.com/en-us/graph/api/directoryrole-list-members?view=graph-rest-1.0&tabs=http

    .EXAMPLE
    Invoke-CKAttackGraph -accessToken $accessToken
    #>

    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $true)]
        [String]$gremlinHostname,

        [parameter(Mandatory = $true)]
        [String]$cosmosDBRWKey,

        [parameter(Mandatory = $true)]
        [String]$cosmosDBName,

        [parameter(Mandatory = $true)]
        [String]$cosmosDBGraphName,

        [parameter(Mandatory = $false)]
        [String]$partitionKey = 'pk',

        [parameter(Mandatory = $true)]
        [String]$accessToken
    )

    write-host "[ACTIVITY] Collecting Azure AD users, applications, service Principals, groups and directory roles"
    $users = Get-CKAzADUsers -selectFields "id,displayName" -accessToken $accessToken
    $users | ForEach-Object {Add-Member -InputObject $_ -MemberType NoteProperty -Name 'label' -Value 'user'}
    $applications = Get-CKAzADApplications -selectFields "id,displayName" -accessToken $accessToken
    $applications | ForEach-Object {Add-Member -InputObject $_ -MemberType NoteProperty -Name 'label' -Value 'application'}
    $serviceprincipals = Get-CKAzADServicePrincipals -selectFields "id,displayName" -accessToken $accessToken
    $serviceprincipals | ForEach-Object {Add-Member -InputObject $_ -MemberType NoteProperty -Name 'label' -Value 'serviceprincipal'}
    $groups = Get-CKAzADGroups -selectFields "id,displayName" -accessToken $accessToken
    $groups | ForEach-Object {Add-Member -InputObject $_ -MemberType NoteProperty -Name 'label' -Value 'group'}
    $directoryroles += Get-CKAzADDirectoryRoles -accessToken $accessToken
    $directoryroles | ForEach-Object {Add-Member -InputObject $_ -MemberType NoteProperty -Name 'label' -Value 'directoryrole'}

    # Graph Creation
    write-host "[ACTIVITY] Defining Graph object"
    $resourceList = $applications + $serviceprincipals + $groups + $directoryroles
    $edges = @()

    foreach ( $resource in $resourceList ) {
        $metadata = Switch ($resource.label) {
            'application' { @{ type = 'applications'; relationship = 'owner_of' } }
            'serviceprincipal' { @{ type = 'servicePrincipals'; relationship = 'owner_of' } }
            'group' { @{ type = 'groups'; relationship = 'member_of' } }
            'directoryrole' { @{ type = 'directoryRoles'; relationship = 'member_of' } }
        }
        Write-verbose "[ACTIVITY] >> Listing $($metadata.relationship) $label $($resource.displayName) .."
        $relationObjects = Switch ($metadata.relationship) {
            'owner_of' { Get-CKOwners -resourceType $metadata.type -objectId $resource.id -accessToken $accessToken }
            'member_of' { Get-CKMembers -resourceType $metadata.type -objectId $resource.id -accessToken $accessToken }
        }
        if ($relationObjects.value){
            $edges += @{
                objectName = $resource.displayName
                id = $resource.id
                relationship = $metadata.relationship
                relationObjects = $relationObjects
            }
        }
    }
    $vertices = $users + $resourceList

    # Add graph to CosmosDB graph
    write-host "[ACTIVITY] Adding vertices and edges to CosmosDB graph.."
    Import-Module PoshGremlin

    write-host "[ACTIVITY] Defining CosmosDB client connection.."
    $authKey = ConvertTo-SecureString -AsPlainText -Force -String "$cosmosDBRWKey"
    $gremlinParams = @{
        Hostname = $gremlinHostname
        Credential = New-Object System.Management.Automation.PSCredential "/dbs/$cosmosDBName/colls/$cosmosDBGraphName", $authKey
    }

    # Process vertices
    write-host "[ACTIVITY] Importing vertices.."
    foreach ($v in $vertices) {
        $label = $v.label
        Write-Verbose "[ACTIVITY] >> Creating $label vertex: $($v.displayName) - $($v.id)"
        "g.V().has('$label','id','$($v.id)').fold().coalesce(unfold(),addV('$label').property('id','$($v.id)').property('displayName','$($v.displayName)').property('$partitionKey', '$partitionKey'))" | Invoke-Gremlin @gremlinParams | Out-Null
    }

    Start-Sleep 10

    # Process Edges
    write-host "[ACTIVITY] Importing edges.."
    foreach ($e in $edges) {
        foreach ($m in $e.relationObjects) {
            Write-Verbose "[ACTIVITY] >> Creating Edge: From $($m.displayName) to $($e.objectName)"
            "g.V('$($m.id)').as('source').V('$($e.id)').as('target').not(__.in('$($e.relationship)').where(eq('source'))).addE('$($e.relationship)').from('source').to('target')" | Invoke-Gremlin @gremlinParams | Out-Null
        }
    }
}
