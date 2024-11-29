#!/bin/bash
LOCKFILE="/tmp/myscript.lock"

# Function to remove the lock file on exit
cleanup() {
    echo "cleaning up lockfile"
    rm -f "$LOCKFILE"
}

# Trap signals and remove lock file if script exits unexpectedly
trap cleanup EXIT

# Check if the lock file exists
if [ -e "$LOCKFILE" ]; then
    echo "Script is already running."
    exit 1
fi

# Create the lock file
touch "$LOCKFILE"

# actual script work below
source externalrunner.sh
source scripts/setlocalvars.sh

git pull

tagcheck=$(git tag -l | grep -E "(^|\\s)${iac_terraform_modules_tag}($|\\s)")

if [[ "$tagcheck" == "$iac_terraform_modules_tag" ]]; then
echo "tag exist"
else
exit -1
fi

LOG_TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

terragrunt run-all apply --terragrunt-non-interactive | tee /tmp/terragrunt-$LOG_TIMESTAMP.log

# no need to call cleanup manually. We are using trap function