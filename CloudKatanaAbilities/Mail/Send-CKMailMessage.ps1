function Send-CKMailMessage {
    <#
    .SYNOPSIS
    Sends a Mail Message.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None
    
    .DESCRIPTION
    Send-CKMailMessage is a simple PowerShell wrapper to send a specific mail message in JSON or MIME format.

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
    https://learn.microsoft.com/en-us/previous-versions/office/office-365-api/api/version-2.0/mail-rest-operations#SendMessages
    https://learn.microsoft.com/en-us/graph/api/user-sendmail?view=graph-rest-1.0&tabs=http
    https://learn.microsoft.com/en-us/previous-versions/office/office-365-api/api/version-2.0/mail-rest-operations#SendMessages
    https://github.com/Gerenios/AADInternals/blob/master/OutlookAPI.ps1

    .EXAMPLE
    Send-CKMailMessage -subject 'NewEmail' -recipients 'pgustavo@domain.com' -message 'Hola' -saveToSentItems -accessToken $accessToken

    .EXAMPLE
    Send-CKMailMessage -userPrincipalName 'wardog@domain.com' -subject 'NewEmail' -recipients 'pgustavo@domain.com' -message 'Hola' -saveToSentItems -accessToken $accessToken
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
    # Define Message
    $body = @{
        "Message" = @{
            "Subject" = "$subject"
            "Body" = @{
                "ContentType" = "$messageType"
                "Content" = $message
            }
            "ToRecipients" = @($recipients | ForEach-Object {@{"EmailAddress" = @{"Address" = $_}}})
        }
        "SaveToSentItems" = $save
    }
    # Process CCRecipients
    if ($ccRecipients){
        $body["Message"]["CcRecipients"] = @($ccRecipients | ForEach-Object {@{"EmailAddress" = @{"Address" = $_}}})
    }

    $parameters = @{
        Resource = $resourceUrl
        HttpMethod = "Post"
        Body = $body
        AccessToken = $accessToken
    }

    # Validate Audience
    $response = Switch ((Read-CKAccessToken -Token $accessToken).aud) {
        'https://graph.microsoft.com'   { Invoke-CKMSGraphAPI @parameters }
        'https://outlook.office365.com' { Invoke-CKOutlookAPI @parameters }
    }

    # Return Response
    $response
}
