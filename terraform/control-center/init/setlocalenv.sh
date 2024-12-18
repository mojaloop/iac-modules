export IAC_TEMPLATES_TAG=$IAC_TERRAFORM_MODULES_TAG
export CONTROL_CENTER_CLOUD_PROVIDER=aws
yq '.' environment.yaml > environment.json
for var in $(jq -r 'to_entries[] | "\(.key)=\(.value)"' ./environment.json); do export $var; done
export destroy_ansible_playbook="mojaloop.iac.control_center_post_destroy"
export d_ansible_collection_url="git+https://github.com/thitsax/iac-ansible-collection-roles.git#/mojaloop/iac"
export destroy_ansible_inventory="$ANSIBLE_BASE_OUTPUT_DIR/control-center-post-config/inventory"
export destroy_ansible_collection_complete_url=$d_ansible_collection_url,$ansible_collection_tag
export IAC_TERRAFORM_MODULES_TAG=v5.3.8-on-premise
export ANSIBLE_BASE_OUTPUT_DIR=$PWD/output
export PRIVATE_REPO_TOKEN=nullvalue
export PRIVATE_REPO_USER=nullvalue
export PRIVATE_REPO=example.com
export GITLAB_URL=gitlab.yourdomain.com
export GITLAB_SERVER_TOKEN=yourtoken
export DOMAIN=yourdomain.com
export PROJECT_ID=1