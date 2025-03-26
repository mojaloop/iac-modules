BRANCH=$1
git config --global user.email "root@${gitlab_hostname}"
git config --global user.name "root"
git checkout $BRANCH
git add $CONFIG_PATH
git diff --cached --exit-code || git commit -m "update merged configs"
git push