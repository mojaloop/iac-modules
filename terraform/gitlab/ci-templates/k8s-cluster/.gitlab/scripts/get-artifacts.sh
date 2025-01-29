export SOURCE_GITLAB_TOKEN="$(vault kv get -field=token ${KV_SECRET_PATH}/mig-source-gitlab)"
curl --location --output artifacts.zip --header "Authorization: Bearer $SOURCE_GITLAB_TOKEN"  $MIG_SOURCE_GITLAB/api/v4/projects/$MIG_SOURCE_PROJECT_ID/jobs/$MIG_SOURCE_JOB_ID/artifacts
unzip -o artifacts.zip -d $TF_ROOT