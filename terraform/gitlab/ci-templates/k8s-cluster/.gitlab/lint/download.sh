#!/usr/bin/env bash

set -e

if [ ! -d "bin" ]; then mkdir bin; fi
if [ ! -f "bin/kubectl" ]; then
  curl -L --output bin/kubectl "https://dl.k8s.io/release/v1.32.1/bin/linux/amd64/kubectl";
  chmod +x bin/kubectl;
fi
if [ ! -f "bin/kubectl-validate" ]; then
  curl -L --output bin/kubectl-validate.tar.gz https://github.com/kubernetes-sigs/kubectl-validate/releases/download/v0.0.4/kubectl-validate_linux_amd64.tar.gz;
  tar -xvf bin/kubectl-validate.tar.gz -C bin;
  chmod +x bin/kubectl-validate;
fi
if [ ! -f "bin/yq" ]; then
  curl -L --output bin/yq https://github.com/mikefarah/yq/releases/download/v4.45.1/yq_linux_amd64
  chmod +x bin/yq
fi
if [ ! -f "bin/helm" ]; then
  curl -L --output bin/helm.tar.gz https://get.helm.sh/helm-v3.15.4-linux-amd64.tar.gz;
  tar -xvf bin/helm.tar.gz -C bin;
  chmod +x bin/linux-amd64/helm;
  mv bin/linux-amd64/helm bin/helm;
fi
