function Read-CKAccessToken {
    <#
    .SYNOPSIS
    A PowerShell script to pare an Azure AD access token in a JSON Web Signature (JWS) format.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None

    .DESCRIPTION
    Read-CKAccessToken is PowerShell script to pare an Azure AD access token in a JSON Web Signature (JWS) format to extract header and payload to access claims and calculate expiration context. 

    .PARAMETER Token
    An access token in JWT format.

    .LINK
    https://www.rfc-editor.org/rfc/rfc7519
    https://developer.okta.com/blog/2020/12/21/beginners-guide-to-jwt
    https://stackoverflow.com/questions/39926104/what-format-is-the-exp-expiration-time-claim-in-a-jwt
    #>

    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [String] $Token
    )

    # Extract sections
    $Sections = $token.Split('.')
    if ($Sections.Count -ne 3){
        throw "Wrong number of sections"
    }

    # Extact Header and validate it is a valid JWT Token
    $Header = (ConvertFrom-B64ToString -B64String $Sections[0] | ConvertFrom-Json)
    if ($Header.typ -ne 'JWT'){
        throw "Not a JWT token"
    }

    # Extract Payload
    $Payload = (ConvertFrom-B64ToString -B64String $Sections[1] | ConvertFrom-Json)

    # Define Output
    $Output = [ordered]@{}
    $Header, $Payload | ForEach-Object { $_.psobject.properties | ForEach-Object{ $Output[$_.Name] = $_.Value }}

    # Add expiration metadata
    $now=(Get-Date).ToUniversalTime()
    $exp = ([DateTime]('1970,1,1')).AddSeconds($Payload.exp)
    $Output['has_expired'] = $($now -gt $exp)
    
    # Return Output
    [PsCustomobject]$Output
}
