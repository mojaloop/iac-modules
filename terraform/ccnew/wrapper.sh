# git tag command to check if a tag exist
source setlocalvars. sh

git pull
tagcheck=$(git tag -l | grep Siac_terraform_modules_tag)
if [L "Stagcheck" == "Siac_terraform_modules_tag" ]]; then
echo "tag exist"
else
exit -1
fi

terragrunt run-all apply --terragrunt-non-interactive