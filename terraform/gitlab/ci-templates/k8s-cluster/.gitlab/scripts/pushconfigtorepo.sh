set -e

CURRENT_PROJECT_FULL_PATH=$1
GIT_HOST=$2
BRANCH=$3
ROOT_TOKEN=$4
GIT_CREDENTIALS=$5

WORKING_DIR=$PWD
TMP_GITLAB_DIR=/tmp/gitlab_repo
TMP_GITHUB_DIR=/tmp/github_repo

cleanup() {
    log "Cleaning up temporary directories..."
    rm -rf "$TMP_GITLAB_DIR" "$TMP_GITHUB_DIR"
}

trap cleanup EXIT

ENV_NAME=$(yq eval '.env' custom-config/cluster-config.yaml)
DOMAIN=$(yq eval '.domain' custom-config/cluster-config.yaml)
log "ENV NAME = ${ENV_NAME}"
log "DOMAIN   = ${DOMAIN}"

git clone https://root:${ROOT_TOKEN}@${GIT_HOST}/$CURRENT_PROJECT_FULL_PATH $TMP_GITLAB_DIR
cd $TMP_GITLAB_DIR
git checkout $BRANCH

git clone ${GIT_CREDENTIALS}/infitx-org/environments-custom-config.git $TMP_GITHUB_DIR

cd $TMP_GITHUB_DIR
python3 -m src.main $ENV_NAME $DOMAIN

cp -r $TMP_GITHUB_DIR/custom-config/* $TMP_GITLAB_DIR/custom-config/

cd $TMP_GITLAB_DIR
git config --global user.email "root@${GIT_HOST}"
git config --global user.name "root"
git add custom-config/.
if ! git diff --cached --quiet; then
    git commit -m "Add custom config files"
    log "Pushing changes..."
    git push
else
    log "No changes to commit."
fi

log "Script completed successfully."