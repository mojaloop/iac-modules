CC_TMP_GIT_REPO=$1
CC_TMP_TEMPLATE_DIR=$2
ROOT_TOKEN=$3
WORKING_DIR=$PWD
BASE_GITLAB_URL=https://root:${ROOT_TOKEN}@${CI_SERVER_HOST}/iac
IAC_MODULES_TAG=$4

# checking out IAC-MODULES
rm -rf $CC_TMP_GIT_REPO
mkdir -p $CC_TMP_GIT_REPO
git clone ${TEMPLATE_REPO_URL} $CC_TMP_GIT_REPO
cd $CC_TMP_GIT_REPO && git checkout ${IAC_MODULES_TAG}

rm -rf $CC_TMP_TEMPLATE_DIR
mkdir -p $CC_TMP_TEMPLATE_DIR
cp -r ${CC_CI_TEMPLATE_PATH}/. ${CC_TEMPLATE_PATH}/. $CC_TMP_TEMPLATE_DIR/

#checking out bootstrap repo
CC_TMP_REPO_DIR=/tmp/gitclone-bootstrap
mkdir -p $CC_TMP_REPO_DIR
git clone ${BASE_GITLAB_URL}/bootstrap $CC_TMP_REPO_DIR
cd $CC_TMP_REPO_DIR

#copying necessary files to local git repo
cp -r $CC_TMP_TEMPLATE_DIR/control-center-deploy/ $CC_TMP_TEMPLATE_DIR/control-center-pre-config/ $CC_TMP_TEMPLATE_DIR/control-center-post-config/ $CC_TMP_TEMPLATE_DIR/ansible-cc-deploy/ $CC_TMP_TEMPLATE_DIR/ansible-cc-post-deploy/  $CC_TMP_TEMPLATE_DIR/.gitlab  $CC_TMP_TEMPLATE_DIR/.gitlab-ci.yml  .

git config --global user.email "root@${gitlab_hostname}"
git config --global user.name "root"
git add .
git commit -m "refreshing templates from release ${IAC_MODULES_TAG} to project"
git push