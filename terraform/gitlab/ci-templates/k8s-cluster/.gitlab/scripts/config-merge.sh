#!/bin/bash
set -e
shopt -s nullglob globstar extglob

ENV_TYPE=${ENV_TYPE:-dev}

mkdir -p $CONFIG_PATH

# Merge app-yamls first to determine enabled addon apps
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

ENABLED_APPS=""
for app in $(find addons -mindepth 2 -maxdepth 2 -type d ! -name '.*' -printf '%f '); do
    if [[ "$(yq eval ".${app}Enabled // false" "$CONFIG_PATH/app-yamls.yaml")" == "true" || "$(yq eval ".${app}.enabled // false" "$CONFIG_PATH/app-yamls.yaml")" == "true" ]]; then
        if [ -z "$ENABLED_APPS" ]; then
            ENABLED_APPS="${app}.yaml"
        else
            ENABLED_APPS="${ENABLED_APPS} ${app}.yaml"
        fi
    fi
done
echo -e "Enabled addon apps: $ENABLED_APPS"
ENABLED_APPS_FOLDERS="${ENABLED_APPS// /|}"
ENABLED_APPS_FOLDERS="${ENABLED_APPS_FOLDERS//.yaml/}"

for configFile in $({ ls default-config/; ls custom-config/; echo $ENABLED_APPS; } | sort -u)
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
        addons/*/@(${ENABLED_APPS_FOLDERS})/.config/$configFile \
        addons/*/@(${ENABLED_APPS_FOLDERS})/.config/$ENV_CONFIG \
        addons/*/@(${ENABLED_APPS_FOLDERS})/.config/+(*-)$configFile \
        addons/*/@(${ENABLED_APPS_FOLDERS})/.config/+(*-)$ENV_CONFIG \
        profiles/**/$configFile \
        profiles/**/+(*-)$configFile \
        profiles/**/$ENV_CONFIG \
        profiles/**/+(*-)$ENV_CONFIG \
        custom-config/$configFile \
        custom-config/+(*-)$configFile $CONFIG_PATH;
done;
echo