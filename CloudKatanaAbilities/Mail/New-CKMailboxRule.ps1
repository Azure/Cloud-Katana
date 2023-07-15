function New-CKMailboxRule {
    <#
    .SYNOPSIS
    Creates a new mail inbox rule.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    New-CKMailboxRule is a simple PowerShell wrapper to create a new mail inbox rule in JSON format.

    .PARAMETER userPrincipalName
    Specific user to create the new message rule for. (e.g wardog@domain.com)

    .PARAMETER ruleName
    Name of inbox rule.

    .PARAMETER conditions
    Conditions that when fulfilled, will trigger the corresponding actions for that rule.

    .PARAMETER actions
    Actions to be taken on a message when the corresponding conditions, if any, are fulfilled.

    .PARAMETER accessToken
    Access token used to access the API.

    .LINK
    https://learn.microsoft.com/en-us/graph/api/mailfolder-post-messagerules?view=graph-rest-1.0&tabs=http
    https://learn.microsoft.com/en-us/previous-versions/office/office-365-api/api/beta/mail-rest-operations-beta#ManageRules

    .EXAMPLE
    $conditions = @{
        "BodyOrSubjectContains" = @('invoice','payment','wire','iban','remittance','synthetic_test') 
    }
    $actions = @{
        "MoveToFolder" = "$($userName):\Archive"
        "MarkAsRead" = $true
    }
    New-CKMailboxRule -userPrincipalName 'pgustavo@peanutrecords.com' -ruleName "OWATest" -conditions $conditions -actions $actions -accessToken $accessToken
    #>

    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $false)]
        [String]$userPrincipalName,

        [parameter(Mandatory = $true)]
        [String]$ruleName,

        [parameter(Mandatory = $false)]
        [Int]$sequence = 1,

        [parameter(Mandatory = $true)]
        [Hashtable]$conditions,

        [parameter(Mandatory = $true)]
        [Hashtable]$actions,
        
        [parameter(Mandatory = $true)]
        [String]$accessToken
        
    )

    if ($userPrincipalName) {
        $resourceUrl = "users/$userPrincipalName/mailFolders/inbox/messageRules"
    }
    else {
        $resourceUrl = "me/mailfolders/inbox/messagerules"
    }

    # Define Inbox Rule
    $body = @{
        "DisplayName" = "$ruleName"
        "Sequence" = $sequence
        "IsEnabled" =  $true
        "Conditions" = $conditions
        "Actions" = $actions
    }
    
    $parameters = @{
        Resource = $resourceUrl
        HttpMethod = "Post"
        Body = $body
        AccessToken = $accessToken
    }

    # Validate Audience and Invoke API
    $response = Switch ((Read-CKAccessToken -Token $accessToken).aud) {
        'https://graph.microsoft.com'   { Invoke-CKMSGraphAPI @parameters }
        'https://outlook.office365.com' { Invoke-CKOutlookAPI @parameters }
    }

    # Return Response
    $response
}