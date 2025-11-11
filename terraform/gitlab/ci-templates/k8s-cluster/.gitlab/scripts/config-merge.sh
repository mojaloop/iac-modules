#!/bin/bash
set -e
shopt -s nullglob globstar extglob

ENV_TYPE=${ENV_TYPE:-dev}

mkdir -p $CONFIG_PATH
for configFile in $({ ls default-config/; ls custom-config/; find addons -mindepth 2 -maxdepth 2 -type d -printf '%f.yaml\n'; } | sort -u)
do
    echo
    echo -n $configFile " ➡️ "
    ENV_CONFIG=${configFile/%.yaml/.$ENV_TYPE.yaml}
    ENV_CONFIG=${ENV_CONFIG/%.json/.$ENV_TYPE.json}
    # merge configurations in the following order (later files override earlier ones):
    # default-config/*.(yaml|json)
    # addons/*/.config/*.(yaml|json)
    # addons/*/.config/xxx-*.(yaml|json) sorted by name
    # addons/*/.config/*.<env>.(yaml|json)
    # addons/*/.config/xxx-*.<env>.(yaml|json) sorted by name
    # profiles/**/*.(yaml|json)
    # profiles/**/xxx-*.(yaml|json) sorted by name
    # profiles/**/*.<env>.(yaml|json)
    # profiles/**/xxx-*.<env>.(yaml|json) sorted by name
    # custom-config/*.(yaml|json)
    # custom-config/xxx-*.(yaml|json) sorted by name
    python3 .gitlab/scripts/dictmerge.py \
        default-config/$configFile \
        addons/*/.config/$configFile \
        addons/*/.config/+(*-)$configFile \
        addons/*/.config/$ENV_CONFIG \
        addons/*/.config/+(*-)$ENV_CONFIG \
        profiles/**/$configFile \
        profiles/**/+(*-)$configFile \
        profiles/**/@($ENV_CONFIG) \
        profiles/**/+(*-)@($ENV_CONFIG) \
        custom-config/$configFile \
        custom-config/+(*-)$configFile $CONFIG_PATH;
done;
echo