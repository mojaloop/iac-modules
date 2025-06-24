export IAC_TEMPLATES_TAG=$IAC_TERRAFORM_MODULES_TAG
export CONTROL_CENTER_CLOUD_PROVIDER=aws
yq eval '.' environment.yaml -o=json > environment.json
for var in $(jq -r 'to_entries[] | "\(.key)=\(.value)\n"' ./environment.json); do export $var; done
export destroy_ansible_playbook="mojaloop.iac.control_center_post_destroy"
export d_ansible_collection_url="git+https://github.com/kirgene/iac-ansible-collection-roles.git#/mojaloop/iac"
export destroy_ansible_inventory="$ANSIBLE_BASE_OUTPUT_DIR/control-center-post-config/inventory"
export destroy_ansible_collection_complete_url=$d_ansible_collection_url,$ansible_collection_tag