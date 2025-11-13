#!/bin/bash
set -e
shopt -s nullglob globstar extglob

ENV_TYPE=${ENV_TYPE:-dev}

mkdir -p $CONFIG_PATH

# Merge app-yamls first to determine enabled addons
python3 .gitlab/scripts/dictmerge.py \
    default-config/app-yamls.yaml \
    addons/*/app-yamls/.config/app-yamls.yaml \
    addons/*/app-yamls/.config/+(*-)app-yamls.yaml \
    addons/*/app-yamls/.config/app-yamls.$ENV_TYPE.yaml \
    addons/*/app-yamls/.config/+(*-)app-yamls.$ENV_TYPE.yaml \
    profiles/**/app-yamls.yaml \
    profiles/**/+(*-)app-yamls.yaml \
    profiles/**/app-yamls.$ENV_TYPE.yaml \
    profiles/**/+(*-)app-yamls.$ENV_TYPE.yaml \
    custom-config/app-yamls.yaml \
    custom-config/+(*-)app-yamls.yaml $CONFIG_PATH;

ENABLED_ADDONS=""
for addon in $(find addons -mindepth 2 -maxdepth 2 -type d ! -name '.*'); do
    if [ "$(yq eval ".${addon}Enabled // false" "$CONFIG_PATH/app-yamls.yaml")" == "true" || "$(yq eval ".${addon}.enabled // false" "$CONFIG_PATH/app-yamls.yaml")" == "true" ]; then
        if [ -z "$ENABLED_ADDONS" ]; then
            ENABLED_ADDONS="${addon}.yaml"
        else
            ENABLED_ADDONS="${ENABLED_ADDONS} ${addon}.yaml"
        fi
    fi
done
echo -e "Enabled addons: $ENABLED_ADDONS"

for configFile in $({ ls default-config/; ls custom-config/; echo $ENABLED_ADDONS; } | sort -u)
do
    # skip app-yamls
    [[ "$configFile" == "app-yamls.yaml" ]] && continue
    echo
    echo -n $configFile " ➡️ "
    ENV_CONFIG=${configFile/%.yaml/.$ENV_TYPE.yaml}
    ENV_CONFIG=${ENV_CONFIG/%.json/.$ENV_TYPE.json}
    # merge configurations in the following order (later files override earlier ones):
    # default-config/*.(yaml|json)
    # addons/*/*/.config/*.(yaml|json)
    # addons/*/*/.config/xxx-*.(yaml|json) sorted by name
    # addons/*/*/.config/*.<env>.(yaml|json)
    # addons/*/*/.config/xxx-*.<env>.(yaml|json) sorted by name
    # profiles/**/*.(yaml|json)
    # profiles/**/xxx-*.(yaml|json) sorted by name
    # profiles/**/*.<env>.(yaml|json)
    # profiles/**/xxx-*.<env>.(yaml|json) sorted by name
    # custom-config/*.(yaml|json)
    # custom-config/xxx-*.(yaml|json) sorted by name
    python3 .gitlab/scripts/dictmerge.py \
        default-config/$configFile \
        addons/@(${ENABLED_ADDONS// /|})/*/.config/$configFile \
        addons/@(${ENABLED_ADDONS// /|})/*/.config/+(*-)$configFile \
        addons/@(${ENABLED_ADDONS// /|})/*/.config/$ENV_CONFIG \
        addons/@(${ENABLED_ADDONS// /|})/*/.config/+(*-)$ENV_CONFIG \
        profiles/**/$configFile \
        profiles/**/+(*-)$configFile \
        profiles/**/$ENV_CONFIG \
        profiles/**/+(*-)$ENV_CONFIG \
        custom-config/$configFile \
        custom-config/+(*-)$configFile $CONFIG_PATH;
done;
echo