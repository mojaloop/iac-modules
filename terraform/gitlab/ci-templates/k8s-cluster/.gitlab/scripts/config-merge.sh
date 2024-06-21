shopt -s nullglob globstar extglob

ENV_TYPE=${ENV_TYPE:-dev}
YAML_ENV_CONFIG=${configFile/%.yaml/.$ENV_TYPE.yaml}
JSON_ENV_CONFIG=${configFile/%.json/.$ENV_TYPE.json}

mkdir -p $CONFIG_PATH
for configFile in $(ls default-config/)
do
    echo $configFile
    python3 .gitlab/scripts/dictmerge.py \
        default-config/$configFile \
        profiles/**/?(*-)$configFile \
        profiles/**/?(*-)@($YAML_ENV_CONFIG|$JSON_ENV_CONFIG) \
        custom-config/$configFile $CONFIG_PATH;
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