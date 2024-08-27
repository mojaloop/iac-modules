terragrunt run-all init
cd control-center-deploy
terragrunt apply -auto-approve --terragrunt-non-interactive

# Run Docker Compose
docker-compose up -d

cd ../ansible-cc-deploy
terragrunt apply -auto-approve --terragrunt-non-interactive
cd ../control-center-pre-config
terragrunt apply -auto-approve --terragrunt-non-interactive