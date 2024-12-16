source externalrunner.sh
source scripts/setlocalvars.sh
sh movestatefromk8s.sh
terragrunt run-all destroy --terragrunt-non-interactive