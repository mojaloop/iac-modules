#!/bin/bash

CONFIG_FILE="submodules.yaml"

if [ ! -f "$CONFIG_FILE" ]; then
  git submodule update --remote
  exit 1
fi

readarray submodules < <(yq -o=j -I=0 eval 'to_entries | .[]' $CONFIG_FILE)

echo $submodules

# Loop through each submodule
for submodule in "${submodules[@]}"; do
  path=$(echo "$submodule" | yq eval '.key' -)
  ref=$(echo "$submodule" | yq eval '.value.ref' -)
  url=$(echo "$submodule" | yq eval '.value.url' -)

  # Check if the submodule directory exists
  if [ -d "$path" ]; then
    echo "Updating submodule $path to ref $ref"
  else
    echo "Adding new submodule $path with ref $ref"
    git submodule add "$url" "$path"
  fi
  (cd "$path" && git fetch && git checkout "$ref" && git pull)
done
