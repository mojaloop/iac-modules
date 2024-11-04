FROM ghcr.io/mojaloop/control-center-util:6.0.2
ARG GITLAB_TF_REPO_VERSION=1.0.0
RUN curl -sL https://gitlab.com/gitlab-org/terraform-images/-/raw/v${GITLAB_TF_REPO_VERSION}/src/bin/gitlab-terraform.sh -o /usr/bin/gitlab-terraform \
    && chmod +x /usr/bin/gitlab-terraform