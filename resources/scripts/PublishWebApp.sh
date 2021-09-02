if [[ $githubUserName ]]; then
	git clone "https://$githubUserName:$githubPassword@github.com/$githubRepo" -n Cloud-Katana
else
	git clone "https://github.com/$githubRepo" -n Cloud-Katana
fi
cd Cloud-Katana
git checkout $githubBranch -f
git checkout $githubBranch -f
git checkout $githubBranch -f
echo "PUBLIC_CLIENT_APP_ID: $clientAppId
TENANT_ID: $tenantId
FUNCTION_APP_URL: https://$AppName.azurewebsites.net" > "$AZ_SCRIPTS_PATH_INPUT_DIRECTORY/Cloud-Katana/resources/notebooks/_config.yml"

python -m pip install --upgrade pip
pip install nbformat
pip install pyyaml
pip install Jinja2
cd "$AZ_SCRIPTS_PATH_INPUT_DIRECTORY/Cloud-Katana/resources/scripts"
python Create-KatanaFiles.py
cd "$AZ_SCRIPTS_PATH_INPUT_DIRECTORY/Cloud-Katana/durableApp"
zip -r func.zip *
az webapp deploy --resource-group $deploymentResourceGroupName --name $AppName --src-path func.zip