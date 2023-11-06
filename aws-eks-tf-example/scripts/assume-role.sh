#!/usr/bin/env bash
set -euo pipefail
# for debug output but do not commmit this.
# set -euox pipefail
# This script expects the following vars to be set:
# ACCOUNT_NAME - name of the accont
# ACCOUNT_ID - numeric account ID
CALLERID=$(aws sts get-caller-identity --output json)
AWSUSER=$(echo "${CALLERID}" | jq -r .Arn | awk -F/ '{print $2}')
CREDS=$(aws sts assume-role \
            --role-arn "arn:aws:iam::${ACCOUNT_ID}:role/${ACCOUNT_NAME}-role-app-creator" \
            --role-session-name "${AWSUSER}" --output json)

AWS_ACCESS_KEY_ID=$(echo "${CREDS}" | jq .Credentials.AccessKeyId | xargs)
AWS_SECRET_ACCESS_KEY=$(echo "${CREDS}" | jq .Credentials.SecretAccessKey | xargs)
AWS_SESSION_TOKEN=$(echo "${CREDS}" | jq .Credentials.SessionToken | xargs)

# if it's a new account the directory structure won't exist
if [ ! -d "$TF_PATH" ]; then
  mkdir -p "$TF_PATH"
fi

  cat <<EOF > "${TF_PATH}/.credentials.aws"
[default]
aws_access_key_id = ${AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}
aws_session_token = ${AWS_SESSION_TOKEN}
[unset]
aws_access_key_id = ${AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}
aws_session_token = ${AWS_SESSION_TOKEN}
EOF

# uncomment for debug only if needed
# cat "${TF_PATH}/.credentials.aws"
