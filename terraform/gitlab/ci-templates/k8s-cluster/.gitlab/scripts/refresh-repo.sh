CURRENT_ENV_NAME=$1
TMP_GIT_REPO=$2
TMP_TEMPLATE_DIR=$3
ROOT_TOKEN=$4
WORKING_DIR=$PWD
BASE_GITLAB_URL=https://root:${ROOT_TOKEN}@${CI_SERVER_HOST}/iac
IAC_MODULES_TAG=$5

cd $TMP_GIT_REPO && git checkout ${IAC_MODULES_TAG}
mkdir -p $TMP_TEMPLATES_DIR/${CURRENT_ENV_NAME}
cp -r ${CI_TEMPLATE_PATH}/. ${K8S_TEMPLATE_PATH}/. $TMP_TEMPLATES_DIR/${CURRENT_ENV_NAME}
TMP_REPO_DIR=/tmp/gitclone${CURRENT_ENV_NAME}
mkdir -p $TMP_REPO_DIR
git clone ${BASE_GITLAB_URL}/${CURRENT_ENV_NAME} $TMP_REPO_DIR
cd $TMP_REPO_DIR
cp -r $TMP_TEMPLATE_DIR/${CURRENT_ENV_NAME}/. .
cp $WORKING_DIR/environment.yaml .
git config --global user.email "root@${gitlab_hostname}"
git config --global user.name "root"
git add .
git commit -m "refreshing templates from release ${versionarray[$i]} to project"
git push
rm -rf $TMP_REPO_DIR
