export CONFIG_PATH=merged-config
SCRIPTS_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
$SCRIPTS_DIR/mergeconfigs.sh
yq eval '.' $CONFIG_PATH/cluster-config.yaml -o=json > $CONFIG_PATH/cluster-config.json
for var in $(jq -r 'to_entries[] | "\(.key)=\(.value)\n"' $CONFIG_PATH/cluster-config.json); do export $var; done
export destroy_ansible_playbook="mojaloop.iac.cc${k8s_cluster_type}_cluster_destroy"
export d_ansible_collection_url="git+https://github.com/mojaloop/iac-ansible-collection-roles.git#/mojaloop/iac"
export destroy_ansible_inventory="$ANSIBLE_BASE_OUTPUT_DIR/k8s-deploy/inventory"
export destroy_ansible_collection_complete_url=$d_ansible_collection_url,$ansible_collection_tag
export movek8s_output_dir="$ANSIBLE_BASE_OUTPUT_DIR/k8s-deploy"
export KUBECONFIG_LOCATION=$movek8s_output_dir/kubeconfig
export K8S_STATE_NAMESPACE=kube-system