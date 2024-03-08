export destroy_ansible_playbook="mojaloop.iac.argo${k8s_cluster_type}_cluster_destroy"
export d_ansible_collection_url="git+https://github.com/mojaloop/iac-ansible-collection-roles.git#/mojaloop/iac"
export destroy_ansible_inventory="$ANSIBLE_BASE_OUTPUT_DIR/k8s-deploy/inventory"
export destroy_ansible_collection_complete_url=$d_ansible_collection_url,$ansible_collection_tag