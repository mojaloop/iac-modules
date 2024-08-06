if [ ! -n "$ENV_TO_UPDATE" ]
then
    echo "Please set ENV_TO_UPDATE CICD variable"
    exit 1
fi

if [ ! -n "$IAC_MODULES_VERSION_TO_UPDATE" ]
then
    echo "Please set IAC_MODULES_VERSION_TO_UPDATE CICD variable"
    exit 1
fi

ENV_NAME=$1
TMP_GIT_REPO=$2
TMP_TEMPLATE_DIR=$3
ROOT_TOKEN=$4
IAC_MODULES_TAG=$5
WORKING_DIR=$PWD
BASE_GITLAB_URL=https://root:${ROOT_TOKEN}@${CI_SERVER_HOST}/iac

# checking out IAC-MODULE
cd $TMP_GIT_REPO && git checkout $IAC_MODULES_TAG
mkdir -p $TMP_TEMPLATES_DIR/${ENV_NAME}
cp -r ${CI_TEMPLATE_PATH}/. ${K8S_TEMPLATE_PATH}/. $TMP_TEMPLATES_DIR/${ENV_NAME}
TMP_REPO_DIR=/tmp/gitclone${ENV_NAME}
mkdir -p $TMP_REPO_DIR

#Bootstrap repo
TMP_BOOTSTRAP_REPO=/tmp/data/bootstrap
git clone ${BASE_GITLAB_URL}/bootstrap.git $TMP_BOOTSTRAP_REPO

yq eval '.envs | .[] | select(.env == '\"$ENV_NAME\"')' $TMP_BOOTSTRAP_REPO/environment.yaml

# Cloning the gitlab env repo
git clone ${BASE_GITLAB_URL}/${ENV_NAME} $TMP_REPO_DIR
cd $TMP_REPO_DIR
cp -r $TMP_TEMPLATE_DIR/${ENV_NAME}/. .

# populating the cluster-config in custom-config
if  [ !  -d custom-config ]; then
   mkdir -p custom-config
   yq eval '.envs | .[] | select(.env == '\"$ENV_NAME\"')' $TMP_BOOTSTRAP_REPO/environment.yaml > custom-config/cluster-config.yaml
fi
git config --global user.email "root@${gitlab_hostname}"
git config --global user.name "root"
git add .
git commit -m "refreshing templates from release $IAC_MODULES_TAG to project"
git push
rm -rf $TMP_REPO_DIR
