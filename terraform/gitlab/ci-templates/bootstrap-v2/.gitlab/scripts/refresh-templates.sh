CC_TMP_GIT_REPO=$1
CC_TMP_TEMPLATE_DIR=$2
ROOT_TOKEN=$3
WORKING_DIR=$PWD
BASE_GITLAB_URL=https://root:${ROOT_TOKEN}@${CI_SERVER_HOST}/iac
IAC_MODULES_TAG=$4

# checking out bootstrap repo first to get old tag
CC_TMP_REPO_DIR=/tmp/gitclone-bootstrap
rm -rf $CC_TMP_REPO_DIR
mkdir -p $CC_TMP_REPO_DIR
git clone ${BASE_GITLAB_URL}/bootstrap $CC_TMP_REPO_DIR
cd $CC_TMP_REPO_DIR

# Get the old iac_terraform_modules_tag from current config
OLD_IAC_TAG=$(grep iac_terraform_modules_tag custom-config/cluster-config.yaml 2>/dev/null | awk '{print $2}' || echo "")
echo "Old IAC tag: $OLD_IAC_TAG"
echo "New IAC tag: $IAC_MODULES_TAG"

# checking out IAC-MODULES
rm -rf $CC_TMP_GIT_REPO
mkdir -p $CC_TMP_GIT_REPO
git clone ${TEMPLATE_REPO_URL} $CC_TMP_GIT_REPO
cd $CC_TMP_GIT_REPO && git checkout ${IAC_MODULES_TAG}

# Detect what changed in iac-modules between old and new tag
COMMIT_PREFIX="deploy-full"
if [ -n "$OLD_IAC_TAG" ] && [ "$OLD_IAC_TAG" != "$IAC_MODULES_TAG" ]; then
    # Get changed files in iac-modules between tags
    CHANGED_FILES=$(git diff --name-only "$OLD_IAC_TAG".."$IAC_MODULES_TAG" 2>/dev/null || echo "")
    if [ -n "$CHANGED_FILES" ]; then
        echo "Changed files in iac-modules:"
        echo "$CHANGED_FILES"
        # Gitops-only paths - changes here don't need full terraform apply
        GITOPS_ONLY_PATTERN="^(gitops/|terraform/gitlab/ci-templates/)"
        if echo "$CHANGED_FILES" | grep -qvE "$GITOPS_ONLY_PATTERN"; then
            echo "Infrastructure files changed - will trigger full deploy"
            COMMIT_PREFIX="deploy-full"
        else
            echo "Only gitops/CI files changed - no deploy needed"
            COMMIT_PREFIX="sync"
        fi
    fi
fi

rm -rf $CC_TMP_TEMPLATE_DIR
mkdir -p $CC_TMP_TEMPLATE_DIR
cp -r ${CC_CI_TEMPLATE_PATH}/. ${CC_TEMPLATE_PATH}/. $CC_TMP_TEMPLATE_DIR/

cd $CC_TMP_REPO_DIR

#copying necessary files to local git repo
cp -r $CC_TMP_TEMPLATE_DIR/k8s-deploy/ $CC_TMP_TEMPLATE_DIR/ansible-k8s-deploy/ $CC_TMP_TEMPLATE_DIR/gitops-build/ $CC_TMP_TEMPLATE_DIR/default-config $CC_TMP_TEMPLATE_DIR/.gitlab  $CC_TMP_TEMPLATE_DIR/.gitlab-ci.yml $CC_TMP_TEMPLATE_DIR/setcivars.sh  .

git config --global user.email "root@${gitlab_hostname}"
git config --global user.name "root"
git add .

# Only commit and push if there are changes
if ! git diff --cached --exit-code > /dev/null 2>&1; then
    git commit -m "${COMMIT_PREFIX}: sync templates from ${IAC_MODULES_TAG}"
    git push
    # Signal that templates changed - next pipeline will handle the actual deploy
    touch /tmp/templates-changed.txt
    echo "Templates updated and pushed with prefix: ${COMMIT_PREFIX}"
else
    echo "No template changes to push"
fi