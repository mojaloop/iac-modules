cd /iac-run-dir
source setenv
cd -
source setlocalenv.sh
cd control-center-deploy
terragrunt run-all destroy --terragrunt-non-interactive