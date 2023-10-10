ENVS=$1
TMP_GIT_REPO=$2
TMP_TEMPLATE_DIR=$3
ROOT_TOKEN=$4
WORKING_DIR=$PWD
BASE_GITLAB_URL=https://root:${ROOT_TOKEN}@${CI_SERVER_HOST}/iac

envarray=()
versionarray=()
for var in $(echo $ENVS | yq eval '.[].env' -); do 
    envarray+=("$var")
done
for var in $(echo $ENVS | yq eval '.[].iac_terraform_modules_tag' -); do 
    versionarray+=("$var")
done
for i in ${!envarray[*]}; do
    cd $TMP_GIT_REPO && git checkout ${versionarray[$i]}
    ENV_NAME=${envarray[$i]}
    mkdir -p $TMP_TEMPLATES_DIR/${ENV_NAME}
    cp -r ${CI_TEMPLATE_PATH}/. ${K8S_TEMPLATE_PATH}/. $TMP_TEMPLATES_DIR/${ENV_NAME}
    TMP_REPO_DIR=/tmp/gitclone${ENV_NAME}
    mkdir -p $TMP_REPO_DIR
    git clone ${BASE_GITLAB_URL}/${ENV_NAME} $TMP_REPO_DIR
    cd $TMP_REPO_DIR
    cp -r $TMP_TEMPLATE_DIR/${ENV_NAME}/. .
    cp $WORKING_DIR/environment.yaml .
    git config --global user.email "root@${gitlab_hostname}"
    git config --global user.name "root"
    git add .
    git commit -m "refreshing templates from release ${versionarray[$i]} to project"
    git push
    rm -rf $TMP_REPO_DIR
done