#!/usr/bin/env bash
# This script gathers the required credentials from vault.
VAULT_URL="https://secret.ops.agile.example.co.uk/v1/"
VAULT_NS="notprod/hubs/ndap"
VAULT_ROLE="jenkins-read"
KEY_LOC="jenkins/GITHUB_CCOE"
API_LOC="jenkins/GITHUB_CCOE"
JQ_BIN_LOC="https://stedolan.github.io/jq/download/linux64/jq"
ACCOUNT_ID=`cat ${ACCOUNT_PATH}/_account_id 2>/dev/null`

#Setup jq to parse reponse from vault
curl ${JQ_BIN_LOC} > /usr/bin/jq && chmod +x /usr/bin/jq

mkdir -p /root/.ssh
KUBE_TOKEN=`cat /var/run/secrets/kubernetes.io/serviceaccount/token`
VAULT_TOKEN=$(curl -H "X-Vault-Namespace: ${VAULT_NS}" --request POST\
        --data '{"jwt": "'"$KUBE_TOKEN"'", "role": "'"$VAULT_ROLE"'"}' \
        ${VAULT_URL}auth/kubernetes/login -k | jq -r '.auth.client_token')

curl --header "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: ${VAULT_NS}" ${VAULT_URL}${KEY_LOC} -k | jq -r '.data.id_rsa' > /root/.ssh/id_rsa
chmod 400 /root/.ssh/id_rsa
echo "Host *" > /root/.ssh/config
echo "   StrictHostKeyChecking no" >>/root/.ssh/config

##Get AWS temp creds and store into a file
# ACCOUNT_ID - numeric account ID
mkdir -p /root/.aws
CALLERID=$(aws sts get-caller-identity --output json)
AWSUSER=$(echo "${CALLERID}" | jq -r .Arn | awk -F/ '{print $2}')
CREDS=$(aws sts assume-role \
            --role-arn "arn:aws:iam::${ACCOUNT_ID}:role/infra-creator" \
            --role-session-name "${AWSUSER}" --output json)

export AWS_ACCESS_KEY_ID=$(echo "${CREDS}" | jq .Credentials.AccessKeyId | xargs)
export AWS_SECRET_ACCESS_KEY=$(echo "${CREDS}" | jq .Credentials.SecretAccessKey | xargs)
export AWS_SESSION_TOKEN=$(echo "${CREDS}" | jq .Credentials.SessionToken | xargs)

# use CREDENTIALS_PATH if passed in, otherwise use TF_PATH
#CREDENTIALS_PATH="/root/.aws"
#CREDENTIALS_FILE="/root/.aws/credentials"

#echo "Creating ${CREDENTIALS_FILE}" >&2
#cat <<EOF > "${CREDENTIALS_FILE}"
#[default]
#aws_access_key_id = ${AWS_ACCESS_KEY_ID}
#aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}
#aws_session_token = ${AWS_SESSION_TOKEN}
#[${AWS_PROFILE-unset}]
#aws_access_key_id = ${AWS_ACCESS_KEY_ID}
#aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}
#aws_session_token = ${AWS_SESSION_TOKEN}
#EOF