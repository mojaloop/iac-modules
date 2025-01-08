FROM ubuntu:24.04
ARG TERRAFORM_VERSION=1.3.2
ARG TERRAGRUNT_VERSION=0.57.0
ARG VAULT_VERSION=1.13.4
ARG YTT_VERSION=0.48.0
ARG KAPP_VERSION=0.60.0
ARG KUBECTL_VERSION=1.24.6

RUN apt-get update && apt install curl gnupg software-properties-common -y \ 
    && curl -sSL https://pkgs.netbird.io/debian/public.key | gpg --yes --dearmor --output /usr/share/keyrings/netbird-archive-keyring.gpg \
    && echo 'deb [signed-by=/usr/share/keyrings/netbird-archive-keyring.gpg] https://pkgs.netbird.io/debian stable main' | tee /etc/apt/sources.list.d/netbird.list \
    && apt update && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y \
    tzdata \
    dnsutils \
    git \
    jq \
    libssl-dev \
    openvpn \
    python3 \
    python3-pip \
    python3-venv \
    screen \
    vim \
    wget \
    zip \
    mysql-client \
    && rm -rf /var/lib/apt/lists/*

# Install tools and configure the environment
RUN  wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 \
    && chmod +x /usr/local/bin/yq
RUN wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -O /tmp/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && unzip /tmp/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /bin/ \
    && rm /tmp/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
RUN wget -q https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 -O /bin/terragrunt \
    && chmod +x /bin/terragrunt
RUN wget -q https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip -O /tmp/vault_${VAULT_VERSION}_linux_amd64.zip \
    && unzip /tmp/vault_${VAULT_VERSION}_linux_amd64.zip -d /bin/ \
    && rm /tmp/vault_${VAULT_VERSION}_linux_amd64.zip
RUN wget -q https://github.com/carvel-dev/ytt/releases/download/v${YTT_VERSION}/ytt-linux-amd64 -O /tmp/ytt-linux-amd64 \
    && mv /tmp/ytt-linux-amd64 /bin/ytt \
    && chmod +x /bin/ytt
RUN wget -q https://github.com/carvel-dev/kapp/releases/download/v${KAPP_VERSION}/kapp-linux-amd64 -O /tmp/kapp-linux-amd64 \
    && mv /tmp/kapp-linux-amd64 /bin/kapp \
    && chmod +x /bin/kapp
RUN wget -q https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl -O /bin/kubectl \
    && chmod +x /bin/kubectl   

RUN python3 -m venv /opt/venv \
    && /opt/venv/bin/pip3 install --upgrade pip \
    && /opt/venv/bin/pip3 install ansible==10.0.1 netaddr kubernetes awscli "openshift>=0.6" "setuptools>=40.3.0" \
    && /opt/venv/bin/ansible-galaxy collection install community.kubernetes

ENV PATH="/opt/venv/bin:$PATH"

ARG GITLAB_TF_REPO_VERSION=1.0.0
RUN curl -sL https://gitlab.com/gitlab-org/terraform-images/-/raw/v${GITLAB_TF_REPO_VERSION}/src/bin/gitlab-terraform.sh -o /usr/bin/gitlab-terraform \
    && chmod +x /usr/bin/gitlab-terraform