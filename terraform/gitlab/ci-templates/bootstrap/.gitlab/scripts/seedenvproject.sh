ENV_NAME=$1
TMP_TEMPLATE_DIR=$2
ROOT_TOKEN=$3
WORKING_DIR=$PWD
TMP_REPO_DIR=/tmp/gitclone${ENV_NAME}
BASE_GITLAB_URL=https://root:${ROOT_TOKEN}@${CI_SERVER_HOST}/iac
git clone ${BASE_GITLAB_URL}/${ENV_NAME} $TMP_REPO_DIR
cd $TMP_REPO_DIR
cp -r $TMP_TEMPLATE_DIR/. .
cp $WORKING_DIR/environment.yaml .
git config --global user.email "root@${gitlab_hostname}"
git config --global user.name "root"
git add .
git commit -m "seeding templates to project"
git push
rm -rf $TMP_REPO_DIR