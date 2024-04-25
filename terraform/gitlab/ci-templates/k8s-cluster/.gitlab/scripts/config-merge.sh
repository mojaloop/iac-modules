mkdir -p $CONFIG_PATH
for configFile in {'aws-vars.yaml','cluster-config.yaml','common-vars.yaml','mojaloop-rbac-permissions.yaml','mojaloop-vars.yaml','pm4ml-vars.yaml','bare-metal-vars.yaml','pm4ml-rbac-permissions.yaml','mojaloop-stateful-resources.json','common-stateful-resources.json','mojaloop-rbac-api-resources.yaml','vnext-vars.yaml','vnext-stateful-resources.json','addons-vars.yaml','addons-stateful-resources.json','mojaloop-values-override.yaml'};
do
    echo $configFile
    python3 .gitlab/scripts/dictmerge.py default-config/$configFile custom-config/$configFile $CONFIG_PATH;
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