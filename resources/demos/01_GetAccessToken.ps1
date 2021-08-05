# Function Variables
$functionAppName = 'FUNCTION-APP-NAME'
$azureFunctionUrl = "https://$functionAppName.azurewebsites.net"
$cloudkatanaClientAPPId = 'NATIVE-CLIENT-APP-ID'
$tenantId = 'TENANT-ID'

# Get Acccess Token
$results = Get-FuncAppToken -AppId $cloudkatanaClientAPPId -FunctionAppUrl $azureFunctionUrl -TenantId $tenantId -verbose

$accessToken = $results.AccessToken
$accessToken