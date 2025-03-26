BRANCH=$1
ROOT_TOKEN=$2
GIT_HOST=$3
CURRENT_PROJECT_FULL_PATH=$4
git config --global user.email "root@${gitlab_hostname}"
git config --global user.name "root"
git remote set-url origin https://root:${ROOT_TOKEN}@${GIT_HOST}/$CURRENT_PROJECT_FULL_PATH
git checkout $BRANCH
git add $CONFIG_PATH
git diff --cached --exit-code || git commit -m "update merged configs"
git push