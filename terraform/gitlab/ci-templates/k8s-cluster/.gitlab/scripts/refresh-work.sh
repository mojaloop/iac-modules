set -e
CURRENT_ENV_NAME=$1
TMP_GIT_REPO=$2
TMP_TEMPLATE_DIR=$3
ROOT_TOKEN=$4
WORKING_DIR=$PWD
BASE_GITLAB_URL=https://root:${ROOT_TOKEN}@${CI_SERVER_HOST}/iac
IAC_MODULES_TAG=$5
DIR="${0%/*}"

if [[ "$DIR" =~ ^(.*)\.sh$ ]];
then
    DIR="."
fi

mkdir -p $TMP_GIT_REPO
git clone ${TEMPLATE_REPO_URL} $TMP_GIT_REPO
cd $TMP_GIT_REPO && git checkout ${IAC_MODULES_TAG} && git pull
cp -r ${CI_TEMPLATE_PATH}/. ${K8S_TEMPLATE_PATH}/. .
$DIR/submodule-update.sh
git config --global user.email "root@${gitlab_hostname}"
git config --global user.name "root"
git add .
git commit -m "[skip-ci]refreshing templates from release ${IAC_MODULES_TAG} to project"
rm -rf $TMP_GIT_REPO
