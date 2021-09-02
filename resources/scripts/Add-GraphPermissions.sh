# Get Application service principal if service principal name is provided
if [[ $AppSvcPrincipalName ]]; then
    SvcPrincipalId=$(az ad sp list --query "[?appDisplayName=='$($AppSvcPrincipalName)'].objectId" -o tsv --all)
    if [[ $SvcPrincipalId == null ]]; then
        >&2 echo "Error looking for Azure AD application service principal"
        exit 1
    fi
fi
echo "[+] Service principal ID: $SvcPrincipalId"
    
# Get Microsoft Graph service principal
roleSvcAppId=$(az ad sp list --query "[?appDisplayName=='Microsoft Graph'].objectId" -o tsv --all)
if [[ $roleSvcAppId == null ]]; then
    >&2 echo "Error looking for Service Principal to get roles from"
    exit 1
fi
echo "[+] Found Microsoft Graph service principal ID: $roleSvcAppId"

# Process MS Graph permissions
echo "[+] Found Microsoft Graph permissions.."
if [[ $PermissionsFile ]]; then
    permissions=$(curl $PermissionsFile|jq .)
    appPermissions=$(echo $permissions|jq '.application')
    delegatedPermissions=$(echo $permissions|jq '.delegated')
fi


roleAssignments=$(az ad sp show --id $roleSvcAppId --query "appRoles"|jq ".[]|select([.value]|inside($appPermissions))|.id")

for roleAssignment in $roleAssignments
do
    body=$(echo $roleAssignment|jq -c "{principalId:\"$SvcPrincipalId\", resourceId:\"$roleSvcAppId\", appRoleId:.}")
    az rest --method post --uri "https://graph.microsoft.com/v1.0/servicePrincipals/$SvcPrincipalId/appRoleAssignments" --body "$body" --headers "Content-Type=application/json"
done
token=$(az account get-access-token --resource-type ms-graph --query accessToken --output tsv)

body="{\"clientId\":\"$SvcPrincipalId\",\"consentType\":\"AllPrincipals\",\"principalId\":null,\"resourceId\":\"$roleSvcAppId\",\"scope\":\"delegated\"}"

curl 'https://graph.microsoft.com/v1.0/oauth2PermissionGrants' -H "Authorization: Bearer $token" -H "Content-Type: application/json" -d $body
