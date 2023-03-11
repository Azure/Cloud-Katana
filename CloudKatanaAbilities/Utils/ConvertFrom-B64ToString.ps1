function ConvertFrom-B64ToString {
    <#
    .SYNOPSIS
    A PowerShell script to convert a base64 encoded string to a string.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None

    .DESCRIPTION
    Convert base64 encoded string to text. 

    .PARAMETER B64String
    Base64 encoded string.

    .LINK
    https://gist.github.com/obscuresec/82775093ad892ef5fd00
    https://github.com/Gerenios/AADInternals/blob/ab57903beda6d4030cedc2fd690d85caa2362b65/CommonUtils.ps1
    #>

    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [String] $B64String
    )

    # Replaced
    $Stripped = $B64String.Replace("_","/").Replace("-","+").TrimEnd(0x00,"=")
    
    # Append appropriate padding
    $ModulusValue = ($Stripped.length % 4)   
    Switch ($ModulusValue) {
        '0' {$Padded = $Stripped}
        '1' {$Padded = $Stripped.Substring(0,$Stripped.Length - 1)}
        '2' {$Padded = $Stripped + ('=' * (4 - $ModulusValue))}
        '3' {$Padded = $Stripped + ('=' * (4 - $ModulusValue))}
    }

    # Decode Base64 String
    $Decoded = [System.Text.Encoding]::UTF8.GetString([system.convert]::FromBase64String($Padded))
    $Decoded
}