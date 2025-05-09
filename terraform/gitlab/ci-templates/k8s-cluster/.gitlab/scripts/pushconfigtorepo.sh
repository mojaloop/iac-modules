set -e

CURRENT_PROJECT_FULL_PATH=$1
GIT_HOST=$2
BRANCH=$3
ROOT_TOKEN=$4
GIT_CREDENTIALS=$5

ENV_NAME=$(yq eval '.env' custom-config/cluster-config.yaml)
DOMAIN=$(yq eval '.domain' custom-config/cluster-config.yaml)
echo "ENV NAME = ${ENV_NAME}"
echo "DOMAIN = ${DOMAIN}"

WORKING_DIR=$PWD
TMP_GITLAB_DIR=/tmp/gitlab_repo
TMP_GITHUB_DIR=/tmp/github_repo

git clone https://root:${ROOT_TOKEN}@${GIT_HOST}/$CURRENT_PROJECT_FULL_PATH $TMP_GITLAB_DIR
cd $TMP_GITLAB_DIR
git checkout $BRANCH

git clone -b feature/automate-config-files ${GIT_CREDENTIALS}/infitx-org/environments-custom-config.git $TMP_GITHUB_DIR

cd $TMP_GITHUB_DIR
python3 -m src.main $ENV_NAME $DOMAIN

cp -r $TMP_GITHUB_DIR/custom-config/* $TMP_GITLAB_DIR/custom-config/

cd $TMP_GITLAB_DIR
git config --global user.email "root@${GIT_HOST}"
git config --global user.name "root"
git add custom-config/.
git diff --cached --exit-code || git commit -m "Add custom config files"

git push

rm -rf $TMP_GITLAB_DIR $TMP_GITHUB_DIR