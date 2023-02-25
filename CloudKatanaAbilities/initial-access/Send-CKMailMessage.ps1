function Send-CKMailMessage {
    <#
    .SYNOPSIS
    Sends a Mail Message.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    Send-CKMailMessage is a simple PowerShell wrapper that uses the Microsoft Graph API to send a specific mail message in JSON or MIME format.

    .PARAMETER userPrincipalName
    Specific user to send the email on behalf of. (e.g wardog@domain.com)

    .PARAMETER subject
    email subject.

    .PARAMETER recipients
    list of recipients. @('wardog@domain.com').

    .PARAMETER ccRecipients
    list of CC recipients.

    .PARAMETER message
    Message string. Text or HTML strings.

    .PARAMETER messageType
    Message content type. HTMLor text

    .PARAMETER accessToken
    Access token used to access the API.

    .LINK
    https://learn.microsoft.com/en-us/graph/api/user-sendmail?view=graph-rest-1.0&tabs=http

    .EXAMPLE
    $email = Send-CKMailMessage

    #>

    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $false)]
        [String]$userPrincipalName,

        [parameter(Mandatory = $true)]
        [String]$subject,

        [parameter(Mandatory = $true)]
        [object[]]$recipients,

        [parameter(Mandatory = $false)]
        [object[]]$ccRecipients,

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

    if ($userPrincipalName) {
        $resourceUrl = "users/$userPrincipalName/sendMail"
    }
    else {
        $resourceUrl = "me/sendMail"
    }

    $save = if ($saveToSentItems){$true} else{$false}
    $body = @{
        "message" = @{
            "subject" = "$subject"
            "body" = @{
                "contentType" = "$messageType"
                "content" = $message
            }
            "toRecipients" = @($recipients | ForEach-Object {@{"emailAddress" = @{"address" = $_}}})
            "ccRecipients"= @($ccRecipients | ForEach-Object {@{"emailAddress" = @{"address" = $_}}})
        }
        "saveToSentItems" = $save
    }

    $parameters = @{
        Resource = $resourceUrl
        HttpMethod = "Post"
        Body = $body
        AccessToken = $accessToken
    }
    $response = Invoke-CKMSGraph @parameters
    $response
}