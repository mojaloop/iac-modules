terragrunt run-all init
cd control-center-deploy
terragrunt apply -auto-approve --terragrunt-non-interactive
cd ../ansible-cc-deploy
terragrunt apply -auto-approve --terragrunt-non-interactive
cd ../control-center-pre-config
terragrunt apply -auto-approve --terragrunt-non-interactive