CURRENT_PROJECT_FULL_PATH=$1
GIT_HOST=$2
BRANCH=$3
SRC_DIR=$4
ROOT_TOKEN=$5
DEST_DIR_NAME=$6
WORKING_DIR=$PWD
TMP_REPO_DIR=/tmp/gitclone
git clone https://root:${ROOT_TOKEN}@${GIT_HOST}/$CURRENT_PROJECT_FULL_PATH $TMP_REPO_DIR
cd $TMP_REPO_DIR
git checkout $BRANCH
rm -rf $DEST_DIR_NAME
cp -r $SRC_DIR/. $DEST_DIR_NAME/
git config --global user.email "root@${gitlab_hostname}"
git config --global user.name "root"
git add $DEST_DIR_NAME/.
git commit -m "update generated configs to project"
git push
rm -rf $TMP_REPO_DIR