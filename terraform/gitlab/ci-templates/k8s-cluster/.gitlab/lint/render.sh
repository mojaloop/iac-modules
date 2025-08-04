#!/usr/bin/env bash

echo "Render all Apps..."

set -e

trap 'echo "Command failed...exiting. Please fix me!"' ERR

rm -rf test
mkdir test

if [ "$1" ]; then
    declare -a apps=("$1")
else
    # create list of all folders in GITOPS_BUILD_OUTPUT_DIR , which have a kustomization.yaml file
    declare -a apps=($(find "$GITOPS_BUILD_OUTPUT_DIR" -name kustomization.yaml -exec dirname {} \;))

    # sort the list
    IFS=$'\n' apps=($(sort <<<"${apps[*]}"))

    # for each app in the list, remove the GITOPS_BUILD_OUTPUT_DIR/ prefix
    for i in "${!apps[@]}"; do
        apps[i]=${apps[i]#"$GITOPS_BUILD_OUTPUT_DIR"/}
    done
fi

for app in "${apps[@]}"
do
    if [ -d "$GITOPS_BUILD_OUTPUT_DIR"/"$app" ]; then
        echo "---=== Rendering $app ===---"
        ./bin/kubectl kustomize --enable-helm --helm-command ./bin/helm "$GITOPS_BUILD_OUTPUT_DIR"/"$app" | ./bin/yq -s '"test/'"${app/\\/-}"'/" + .metadata.namespace + "-" + .kind + "-" + .metadata.name'
        # remove the files from the test/app directory which match the patterns in lint.ignore
        if [ -f "$GITOPS_BUILD_OUTPUT_DIR"/"$app"/lint.ignore ]; then
            echo "Removing ignored files from test/${app/\\/-}"
            while IFS= read -r pattern; do
                echo "Removing files matching pattern: $pattern"
                find test/"${app/\\/-}" -type f -name "$pattern" -delete
            done < "$GITOPS_BUILD_OUTPUT_DIR"/"$app"/lint.ignore
        fi
    fi
done
