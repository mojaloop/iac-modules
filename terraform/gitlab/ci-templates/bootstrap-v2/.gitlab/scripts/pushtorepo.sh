#!/bin/bash
set -e

# Push generated GitOps files to the bootstrap repo
# Usage: pushtorepo.sh <PROJECT_PATH> <GIT_HOST> <BRANCH> <SRC_DIR> <ROOT_TOKEN> <DEST_DIR_NAME>
#
# Arguments:
#   PROJECT_PATH - GitLab project path (e.g., iac/cc-bootstrap)
#   GIT_HOST     - GitLab host (e.g., gitlab.cc.example.com)
#   BRANCH       - Branch to push to
#   SRC_DIR      - Source directory containing generated files
#   ROOT_TOKEN   - GitLab token for authentication
#   DEST_DIR_NAME - Destination directory name in repo (e.g., apps)

CURRENT_PROJECT_FULL_PATH=$1
GIT_HOST=$2
BRANCH=$3
SRC_DIR=$4
ROOT_TOKEN=$5
DEST_DIR_NAME=$6

WORKING_DIR=$PWD
TMP_REPO_DIR=/tmp/gitclone

# Clean up any previous clone
rm -rf $TMP_REPO_DIR

# Clone the repo
git clone https://root:${ROOT_TOKEN}@${GIT_HOST}/$CURRENT_PROJECT_FULL_PATH $TMP_REPO_DIR
cd $TMP_REPO_DIR

# Checkout the target branch
git checkout $BRANCH

# Create destination directory if it doesn't exist
mkdir -p $DEST_DIR_NAME

# Remove old contents and copy new ones
rm -rf $DEST_DIR_NAME/*
cp -r $SRC_DIR/. $DEST_DIR_NAME/

# Configure git
git config --global user.email "root@${GIT_HOST}"
git config --global user.name "root"

# Add and commit
git add $DEST_DIR_NAME/.

# Only commit if there are changes
if ! git diff --cached --exit-code > /dev/null 2>&1; then
    git commit -m "deploy: update generated configs"
    git push
    echo "Changes committed and pushed successfully"
else
    echo "No changes to commit"
fi

# Cleanup
cd $WORKING_DIR
rm -rf $TMP_REPO_DIR
