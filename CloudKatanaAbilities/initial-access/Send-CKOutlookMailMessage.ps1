function Send-CKOutlookMailMessage {
    <#
    .SYNOPSIS
    Sends a Mail Message.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    Send-CKOutlookMailMessage is a simple PowerShell wrapper that uses the Outlook Office v2 API to send a mail message on behalf of a user.

    .PARAMETER userPrincipalName
    Specific user to send the email on behalf of. (e.g wardog@domain.com)

    .PARAMETER subject
    email subject.

    .PARAMETER recipients
    list of recipients. @('wardog@domain.com').

    .PARAMETER message
    Message string. Text or HTML strings.

    .PARAMETER messageType
    Message content type. HTMLor text

    .PARAMETER accessToken
    Access token used to access the API.

    .LINK
    https://learn.microsoft.com/en-us/graph/api/user-sendmail?view=graph-rest-1.0&tabs=http
    https://github.com/Gerenios/AADInternals/blob/master/OutlookAPI.ps1

    .EXAMPLE
    Send-CKOutlookMailMessage -userPrincipalName 'wardog@domain.com' -subject 'NewEmail' -recipients 'pgustavo@domain.com' -message 'Hola' -saveToSentItems -accessToken $accessToken

    #>

    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $true)]
        [String]$userPrincipalName,

        [parameter(Mandatory = $true)]
        [String]$subject,

        [parameter(Mandatory = $true)]
        [object[]]$recipients,

        [parameter(Mandatory = $true)]
        [String]$message,

        [parameter(Mandatory = $false)]
        [ValidateSet('HTML','text')]
        [string]$messageType = 'HTML',

        [parameter(Mandatory = $false)]
        [switch]$saveToSentItems,

        [parameter(Mandatory = $true)]
        [String]$accessToken
        
    )

    $headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Accept" = "text/*, multipart/mixed, application/xml, application/json; odata.metadata=none"
        "Content-Type" = "application/json; charset=utf-8"
        "X-AnchorMailbox" = $userPrincipalName
        "Prefer" = 'exchange.behavior="ActivityAccess"'
    }

    $body = @{
        "Message" = @{
            "Subject" = "$subject"
            "Body" = @{
                "ContentType" = "$messageType"
                "Content" = $message
            }
            "ToRecipients" = @($recipients | ForEach-Object {@{"EmailAddress" = @{"Address" = $_}}})
        }
        "SaveToSentItems" = "$(if($SaveToSentItems){"true"}else{"false"})"
    }

    $parameters = @{
        Uri = "https://outlook.office.com/api/v2.0/me/sendmail"
        Method = "Post"
        Body = $body | ConvertTo-Json -Depth 10
        Headers = $headers
    }
    $response = Invoke-RestMethod @parameters -UseBasicParsing
    $response
}