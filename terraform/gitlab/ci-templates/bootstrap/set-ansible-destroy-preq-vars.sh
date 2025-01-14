
export destroy_ansible_playbook="mojaloop.iac.control_center_post_destroy"
export d_ansible_collection_url="git+https://github.com/mojaloop/iac-ansible-collection-roles.git#/mojaloop/iac"
export destroy_ansible_inventory="$ANSIBLE_BASE_OUTPUT_DIR/control-center-post-config/inventory"
export destroy_ansible_collection_complete_url=$d_ansible_collection_url,$ansible_collection_tag