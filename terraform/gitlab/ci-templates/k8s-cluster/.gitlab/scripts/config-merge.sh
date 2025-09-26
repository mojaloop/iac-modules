#!/bin/bash
set -e
shopt -s nullglob globstar extglob

ENV_TYPE=${ENV_TYPE:-dev}

mkdir -p $CONFIG_PATH
for configFile in $({ ls default-config/; ls custom-config/; } | sort -u)
do
    echo $configFile
    ENV_CONFIG=${configFile/%.yaml/.$ENV_TYPE.yaml}
    ENV_CONFIG=${ENV_CONFIG/%.json/.$ENV_TYPE.json}
    ADDON_CONFIG=${configFile/%.yaml/.config.yaml}
    ADDON_CONFIG=${ADDON_CONFIG/%.json/.config.json}
    # merge configurations in the following order (later files override earlier ones):
    # default-config/*.(yaml|json)
    # addons/**/*.config.(yaml|json)
    # addons/**/xxx-*.config.(yaml|json) sorted by name
    # addons/**/*.<env>.(yaml|json)
    # addons/**/xxx-*.<env>.(yaml|json) sorted by name
    # profiles/**/*.(yaml|json)
    # profiles/**/xxx-*.(yaml|json) sorted by name
    # profiles/**/*.<env>.(yaml|json)
    # profiles/**/xxx-*.<env>.(yaml|json) sorted by name
    # custom-config/*.(yaml|json)
    # custom-config/xxx-*.(yaml|json) sorted by name
    echo \
        default-config/$configFile \
        addons/**/@($ADDON_CONFIG) \
        addons/**/+(*-)@($ADDON_CONFIG) \
        addons/**/@($ENV_CONFIG) \
        addons/**/+(*-)@($ENV_CONFIG) \
        profiles/**/$configFile \
        profiles/**/+(*-)$configFile \
        profiles/**/@($ENV_CONFIG) \
        profiles/**/+(*-)@($ENV_CONFIG) \
        custom-config/$configFile \
        custom-config/+(*-)$configFile $CONFIG_PATH;
done;
