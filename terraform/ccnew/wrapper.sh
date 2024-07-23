source setlocalvars.sh

git pull

tagcheck=$(git tag -l | grep $iac_terraform_modules_tag)

if [[ "$tagcheck" == "$iac_terraform_modules_tag" ]]; then
echo "tag exist"
else
exit -1
fi

terragrunt run-all apply --terragrunt-non-interactive