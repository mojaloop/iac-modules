export CONFIG_PATH=./default-config
yq eval '.' $CONFIG_PATH/cluster-config.yaml -o=json > cluster-config.json
for var in $(jq -r 'to_entries[] | "\(.key)=\(.value)\n"' ./cluster-config.json); do export $var; done
export destroy_ansible_playbook="mojaloop.iac.cc${k8s_cluster_type}_cluster_destroy"
export d_ansible_collection_url="git+https://github.com/mojaloop/iac-ansible-collection-roles.git#/mojaloop/iac"
export destroy_ansible_inventory="$ANSIBLE_BASE_OUTPUT_DIR/k8s-deploy/inventory"
export destroy_ansible_collection_complete_url=$d_ansible_collection_url,$ansible_collection_tag