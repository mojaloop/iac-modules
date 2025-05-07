shopt -s nullglob globstar extglob

ENV_TYPE=${ENV_TYPE:-dev}

# Automatically derive ENV_FOLDER and ENVIRONMENT from the repository name
REPO_NAME=${CI_PROJECT_NAME:-default-repo} # Use CI_PROJECT_NAME or a default value
ENV_FOLDER=${ENV_FOLDER:-${REPO_NAME%%-*}} # Strip everything after the first hyphen
ENVIRONMENT=${REPO_NAME#*-} # Extract everything after the first hyphen (e.g., "dev", "qa", etc.)

YAML_ENV_CONFIG=${configFile/%.yaml/.$ENV_TYPE.yaml}
JSON_ENV_CONFIG=${configFile/%.json/.$ENV_TYPE.json}

# Function to replace hardcoded environment values in profile files
replace_env_values() {
    local file=$1
    sed -i "s/\b$ENV_FOLDER-dev\b/$ENV_FOLDER-$ENVIRONMENT/g" "$file"
}

# Function to run dictmerge.py with fallback logic
run_dictmerge_with_fallback() {
    local configFile=$1
    shift
    for profilePattern in "$@"; do
        for file in $profilePattern; do
            [ -f "$file" ] && replace_env_values "$file" # Replace hardcoded values in matching files
        done
        python3 .gitlab/scripts/dictmerge.py \
            default-config/$configFile \
            $profilePattern \
            custom-config/$configFile $CONFIG_PATH && return
    done
}

mkdir -p $CONFIG_PATH
for configFile in $({ ls default-config/; ls custom-config/; } | sort -u)
do
    echo $configFile
    if [ -n "$ENV_FOLDER" ]; then
        # Try ENV_FOLDER-specific profiles first, then fallback to general profiles
        run_dictmerge_with_fallback "$configFile" \
            "profiles/$ENV_FOLDER/**/?(*-)$configFile" \
            "profiles/$ENV_FOLDER/**/?(*-)@($YAML_ENV_CONFIG|$JSON_ENV_CONFIG)" \
            "profiles/**/?(*-)$configFile" \
            "profiles/**/?(*-)@($YAML_ENV_CONFIG|$JSON_ENV_CONFIG)"
    else
        # No folder restriction, use general profiles
        run_dictmerge_with_fallback "$configFile" \
            "profiles/**/?(*-)$configFile" \
            "profiles/**/?(*-)@($YAML_ENV_CONFIG|$JSON_ENV_CONFIG)"
    fi
done;

# for configFile in {'mojaloop-stateful-resources.json','common-stateful-resources.json','mojaloop-rbac-api-resources.yaml'};
# do
#     if [ -f custom-config/$configFile ]; then
#             cp custom-config/$configFile $CONFIG_PATH
#             echo "custom-config/$configFile copied to $CONFIG_PATH"
#     else
#             cp default-config/$configFile $CONFIG_PATH
#             echo "default-config/$configFile copied to $CONFIG_PATH"
#      fi;
# done;